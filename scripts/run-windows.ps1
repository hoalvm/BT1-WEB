[CmdletBinding()]
param(
    [string]$TomcatServiceName = "Tomcat10",
    [string]$UploadDirectory = "C:\ProgramData\JPAWeb\uploads"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$applicationUrl = "http://localhost:8080/jpa-web-assignment-01/"
$warName = "jpa-web-assignment-01.war"
$databasePassword = "123456"

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Resolve-TomcatHome {
    $candidates = @(
        [Environment]::GetEnvironmentVariable("CATALINA_HOME", "Machine"),
        $env:CATALINA_HOME,
        "C:\Program Files\Apache Software Foundation\Tomcat 10.1"
    ) | Where-Object { $_ -and -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($candidate in $candidates) {
        $resolvedCandidate = [System.IO.Path]::GetFullPath($candidate.Trim())
        if ((Test-Path -LiteralPath (Join-Path $resolvedCandidate "webapps") -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $resolvedCandidate "bin") -PathType Container)) {
            return $resolvedCandidate
        }
    }

    throw "Không tìm thấy Tomcat 10.1. Hãy cài Tomcat bằng Windows Service Installer trước."
}

function Resolve-MySqlClient {
    $command = Get-Command "mysql.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $mysqlRoot = "C:\Program Files\MySQL"
    if (Test-Path -LiteralPath $mysqlRoot -PathType Container) {
        $client = Get-ChildItem -LiteralPath $mysqlRoot -Filter "mysql.exe" -File -Recurse -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($client) {
            return $client.FullName
        }
    }

    throw "Không tìm thấy mysql.exe. Hãy cài MySQL Server 8.x trước."
}

function Initialize-Database([string]$mysqlClient) {
    $sqlFile = Join-Path $projectRoot "database.sql"
    $sql = Get-Content -LiteralPath $sqlFile -Raw -Encoding UTF8

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $mysqlClient
    $startInfo.Arguments = "--protocol=TCP --host=localhost --port=3306 --user=root --password=$databasePassword --default-character-set=utf8mb4"
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    if ($startInfo.PSObject.Properties.Name -contains "StandardInputEncoding") {
        $startInfo.StandardInputEncoding = New-Object System.Text.UTF8Encoding($false)
    }

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $process.StandardInput.Write($sql)
    $process.StandardInput.Close()
    $standardOutput = $process.StandardOutput.ReadToEnd()
    $standardError = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -ne 0) {
        throw "Không thể khởi tạo database. MySQL trả về: $standardError"
    }

    if ($standardOutput) {
        Write-Host $standardOutput
    }
}

if (-not (Test-Administrator)) {
    throw "Hãy nhấp phải run.cmd và chọn Run as administrator."
}

if (-not (Get-Command "java.exe" -ErrorAction SilentlyContinue)) {
    throw "Không tìm thấy Java. Hãy cài JDK 17 và mở lại terminal."
}

$tomcatHome = Resolve-TomcatHome
$tomcatService = Get-Service -Name $TomcatServiceName -ErrorAction SilentlyContinue
if (-not $tomcatService) {
    throw "Không tìm thấy Windows service '$TomcatServiceName'. Hãy cài Tomcat 10.1 bằng Windows Service Installer."
}

$mysqlServices = @(Get-Service | Where-Object { $_.Name -like "MySQL*" })
if ($mysqlServices.Count -eq 0) {
    throw "Không tìm thấy Windows service của MySQL."
}
$runningMySqlService = $mysqlServices | Where-Object { $_.Status -eq "Running" } | Select-Object -First 1
if (-not $runningMySqlService) {
    $runningMySqlService = $mysqlServices | Select-Object -First 1
    Start-Service -Name $runningMySqlService.Name
    (Get-Service -Name $runningMySqlService.Name).WaitForStatus("Running", [TimeSpan]::FromSeconds(30))
}

[Environment]::SetEnvironmentVariable("CATALINA_HOME", $tomcatHome, "Machine")
[Environment]::SetEnvironmentVariable("JPAWEB_UPLOAD_DIR", $UploadDirectory, "Machine")
$env:CATALINA_HOME = $tomcatHome
$env:JPAWEB_UPLOAD_DIR = $UploadDirectory

New-Item -ItemType Directory -Force -Path $UploadDirectory | Out-Null
& icacls.exe $UploadDirectory /grant "*S-1-5-19:(OI)(CI)M" /T /C | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Không thể cấp quyền ghi thư mục upload cho Tomcat."
}

Write-Host "[1/4] Khởi tạo database jpa_web..."
Initialize-Database (Resolve-MySqlClient)

Write-Host "[2/4] Build WAR bằng Maven Wrapper..."
Push-Location $projectRoot
try {
    & (Join-Path $projectRoot "mvnw.cmd") clean package
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build thất bại."
    }
} finally {
    Pop-Location
}

$webappsRoot = [System.IO.Path]::GetFullPath((Join-Path $tomcatHome "webapps"))
$deployedWar = [System.IO.Path]::GetFullPath((Join-Path $webappsRoot $warName))
$explodedApplication = [System.IO.Path]::GetFullPath((Join-Path $webappsRoot "jpa-web-assignment-01"))
$expectedPrefix = $webappsRoot.TrimEnd('\') + '\'

if (-not $deployedWar.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
    -not $explodedApplication.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Đường dẫn deploy Tomcat không an toàn."
}

Write-Host "[3/4] Deploy WAR và khởi động Tomcat..."
if ((Get-Service -Name $TomcatServiceName).Status -ne "Stopped") {
    Stop-Service -Name $TomcatServiceName -Force
    (Get-Service -Name $TomcatServiceName).WaitForStatus("Stopped", [TimeSpan]::FromSeconds(30))
}

if (Test-Path -LiteralPath $explodedApplication) {
    Remove-Item -LiteralPath $explodedApplication -Recurse -Force
}
if (Test-Path -LiteralPath $deployedWar) {
    Remove-Item -LiteralPath $deployedWar -Force
}

Copy-Item -LiteralPath (Join-Path $projectRoot "target\$warName") -Destination $deployedWar -Force
Start-Service -Name $TomcatServiceName
(Get-Service -Name $TomcatServiceName).WaitForStatus("Running", [TimeSpan]::FromSeconds(30))

Write-Host "[4/4] Kiểm tra ứng dụng..."
$deadline = (Get-Date).AddSeconds(60)
do {
    try {
        $response = Invoke-WebRequest -Uri $applicationUrl -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "SUCCESS: $applicationUrl" -ForegroundColor Green
            Start-Process $applicationUrl
            exit 0
        }
    } catch {
        Start-Sleep -Seconds 2
    }
} while ((Get-Date) -lt $deadline)

throw "Tomcat đã chạy nhưng ứng dụng chưa trả HTTP 200 sau 60 giây."
