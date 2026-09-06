# Hướng dẫn cài đặt và chạy JPA Web Assignment 01

Tài liệu này hướng dẫn chạy project trên một máy Windows mới, bắt đầu từ lúc clone source code trên GitHub cho đến khi truy cập ứng dụng bằng trình duyệt.

## Cách nhanh nhất

Chỉ cần cài một lần:

1. Git for Windows.
2. JDK 17 và chọn tùy chọn thêm Java vào `PATH`.
3. MySQL Server 8.x, đặt tài khoản `root` với password `123456`.
4. Tomcat 10.1 bằng **Windows Service Installer**, giữ service name mặc định `Tomcat10` và port `8080`.

Project đã có Maven Wrapper nên **không cần cài Maven riêng**.

Sau khi clone, nhấp phải file `run.cmd` và chọn **Run as administrator**. Script sẽ tự động:

- thêm `CATALINA_HOME`;
- thêm `JPAWEB_UPLOAD_DIR=C:\ProgramData\JPAWeb\uploads`;
- tạo database và dữ liệu mẫu;
- chạy `mvnw.cmd clean package`;
- deploy WAR, khởi động Tomcat;
- mở <http://localhost:8080/jpa-web-assignment-01/>.

Nếu chạy bằng terminal thì chỉ cần:

```powershell
.\run.cmd
```

PowerShell hoặc Command Prompt phải được mở bằng quyền Administrator.

## 1. Thông tin ứng dụng

- Repository: `https://github.com/hoalvm/BT1-WEB.git`
- Database: `jpa_web`
- MySQL host: `localhost`
- MySQL port: `3306`
- MySQL user mặc định: `root`
- Tomcat port mặc định: `8080`
- Tên WAR: `jpa-web-assignment-01.war`
- Context path: `/jpa-web-assignment-01`

Các URL chính:

- Trang chủ: <http://localhost:8080/jpa-web-assignment-01/>
- Quản lý Category: <http://localhost:8080/jpa-web-assignment-01/admin/categories>
- Thêm Category: <http://localhost:8080/jpa-web-assignment-01/admin/category/add>
- Tìm kiếm ví dụ: <http://localhost:8080/jpa-web-assignment-01/admin/categories?keyword=Laptop>
- Trang thứ hai: <http://localhost:8080/jpa-web-assignment-01/admin/categories?page=2>

## 2. Công nghệ và phần mềm cần cài

Máy mới cần có:

1. Git for Windows
2. JDK 17
3. MySQL Server 8.x
4. Apache Tomcat 10.1.x
5. Một trình duyệt như Chrome, Edge hoặc Firefox

Maven cài riêng là tùy chọn vì repository đã có Maven Wrapper 3.9.14.

IDE là tùy chọn. Có thể dùng IntelliJ IDEA, Eclipse hoặc VS Code, nhưng toàn bộ project vẫn có thể build và chạy bằng PowerShell.

Các trang tải chính thức:

- Git: <https://git-scm.com/download/win>
- Eclipse Temurin JDK 17: <https://adoptium.net/temurin/releases/?version=17>
- Maven: <https://maven.apache.org/download.cgi>
- MySQL Installer: <https://dev.mysql.com/downloads/installer/>
- Tomcat 10: <https://tomcat.apache.org/download-10>

Không cần cài riêng Hibernate, Jakarta Servlet, JSTL, Hibernate Validator hoặc MySQL Connector/J. Maven sẽ tự tải các dependency được khai báo trong `pom.xml`.

Không cài Tomcat 9 vì project sử dụng package `jakarta.*`. Không cần Spring, Spring Boot, Node.js hoặc Docker.

## 3. Cài đặt JDK 17

Tải và cài Eclipse Temurin JDK 17 bản Windows x64.

Sau khi cài, cấu hình biến môi trường Windows:

```text
JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17...
```

Thêm vào biến `Path`:

```text
%JAVA_HOME%\bin
```

Đóng PowerShell cũ, mở cửa sổ PowerShell mới và kiểm tra:

```powershell
java -version
javac -version
```

Cả hai lệnh phải hiển thị phiên bản 17.

Nếu chưa muốn cấu hình vĩnh viễn, có thể thiết lập cho cửa sổ PowerShell hiện tại:

```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17..."
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

## 4. Maven Wrapper

Không cần cài Maven. Sau khi clone repository, kiểm tra Maven Wrapper bằng:

```powershell
.\mvnw.cmd -version
```

Lần chạy đầu tiên cần Internet để Wrapper tải Maven 3.9.14. Kết quả phải hiển thị Maven 3.9.14 và Java 17.

## 5. Cài đặt MySQL

Dùng MySQL Installer và cài ít nhất:

- MySQL Server 8.x
- MySQL Command Line Client
- MySQL Workbench nếu muốn quản lý database bằng giao diện

Trong bước cấu hình MySQL:

- Chọn TCP/IP port `3306`.
- Tạo user `root`.
- Đặt một mật khẩu và ghi nhớ mật khẩu đó.
- Cho phép MySQL chạy dưới dạng Windows Service.
- Có thể giữ tên service mặc định là `MySQL80`.

Kiểm tra service:

```powershell
Get-Service -Name MySQL* | Select-Object Name, Status
```

Nếu service chưa chạy, mở PowerShell bằng quyền Administrator và chạy:

```powershell
Start-Service MySQL80
```

Kiểm tra MySQL client:

```powershell
mysql --version
mysql -u root -p -e "SELECT VERSION();"
```

Nếu PowerShell báo không tìm thấy lệnh `mysql`, thêm thư mục sau vào `Path`:

```text
C:\Program Files\MySQL\MySQL Server 8.0\bin
```

Hoặc thiết lập tạm:

```powershell
$env:Path = "C:\Program Files\MySQL\MySQL Server 8.0\bin;$env:Path"
```

## 6. Cài đặt Tomcat 10.1

Khuyến nghị tải bản ZIP của Tomcat 10.1 thay vì Windows Service Installer. Bản ZIP dễ cấu hình và không yêu cầu quyền Administrator mỗi lần deploy.

Giải nén Tomcat vào:

```text
C:\tools\apache-tomcat-10.1.x
```

Thiết lập trong PowerShell:

```powershell
$env:CATALINA_HOME = "C:\tools\apache-tomcat-10.1.x"
```

Kiểm tra file Tomcat:

```powershell
Test-Path "$env:CATALINA_HOME\bin\startup.bat"
Test-Path "$env:CATALINA_HOME\bin\shutdown.bat"
```

Cả hai lệnh phải trả về `True`.

Không đặt Tomcat trong thư mục source của project.

## 7. Clone project từ GitHub

Mở PowerShell tại thư mục muốn chứa source code:

```powershell
cd C:\Users\<YOUR_USERNAME>\Desktop
git clone https://github.com/hoalvm/BT1-WEB.git
cd BT1-WEB
```

Kiểm tra source đã clone đầy đủ:

```powershell
git status
Get-ChildItem
Test-Path .\pom.xml
Test-Path .\database.sql
Test-Path .\src\main\resources\META-INF\persistence.xml
```

Ba lệnh `Test-Path` phải trả về `True`.

Nếu không có `pom.xml` hoặc `src`, repository trên GitHub chưa được push đầy đủ.

## 8. Tạo database và dữ liệu mẫu

Project đã có file `database.sql`. File này tạo database, hai table `categories`, `videos` và 10 Category mẫu.

Tại thư mục gốc của project, chạy:

```powershell
$sqlFile = (Resolve-Path .\database.sql).Path.Replace('\', '/')
mysql -u root -p --default-character-set=utf8mb4 --execute="SOURCE $sqlFile"
```

MySQL sẽ yêu cầu nhập mật khẩu của user `root`.

Kiểm tra kết quả:

```powershell
mysql -u root -p --default-character-set=utf8mb4 `
  --database=jpa_web `
  --execute="SHOW TABLES; SELECT COUNT(*) AS total_categories FROM categories;"
```

Kết quả cần có:

```text
categories
videos
total_categories = 10
```

File `database.sql` có thể chạy lại. Dữ liệu mẫu sử dụng `INSERT IGNORE` nên không tạo trùng Category theo tên.

## 9. Cấu hình mật khẩu MySQL

Bản hiện tại được cấu hình sẵn cho môi trường bài tập:

```text
Username: root
Password: 123456
```

Password nằm trong `src/main/resources/META-INF/persistence.xml`, vì vậy máy clone mới chỉ cần tạo MySQL user `root` với password `123456`.

Nếu MySQL dùng password khác, có thể ghi đè trước khi khởi động Tomcat bằng biến môi trường `JPAWEB_DB_PASSWORD` hoặc sửa trực tiếp `persistence.xml` rồi build lại.

Lưu ý: hard-code password chỉ phù hợp để chạy bài tập local. Repository public nên đổi về placeholder hoặc dùng biến môi trường.

## 10. Cấu hình thư mục upload ảnh

Thiết lập thư mục upload nằm ngoài Tomcat để ảnh không mất khi redeploy:

```powershell
[Environment]::SetEnvironmentVariable(
    "JPAWEB_UPLOAD_DIR",
    "C:\ProgramData\JPAWeb\uploads",
    "Machine"
)
$env:JPAWEB_UPLOAD_DIR = "C:\ProgramData\JPAWeb\uploads"
```

Ứng dụng sẽ tự tạo thư mục khi khởi động. Có thể tạo trước để kiểm tra:

```powershell
New-Item -ItemType Directory -Force -Path $env:JPAWEB_UPLOAD_DIR
```

Tài khoản chạy Tomcat cần có quyền đọc và ghi thư mục này.

Nếu không cấu hình, ứng dụng sử dụng thư mục mặc định bên dưới `catalina.base`.

## 11. Build project

Đảm bảo PowerShell đang ở thư mục chứa `pom.xml`, sau đó chạy:

```powershell
.\mvnw.cmd clean package
```

Build thành công sẽ có:

```text
BUILD SUCCESS
```

Kiểm tra WAR:

```powershell
Get-Item .\target\jpa-web-assignment-01.war
```

WAR được tạo tại:

```text
target\jpa-web-assignment-01.war
```

Build không yêu cầu MySQL đang chạy, nhưng ứng dụng cần MySQL khi Tomcat phục vụ request Category.

## 12. Deploy WAR lên Tomcat

Đảm bảo các biến đã được đặt trong cùng cửa sổ PowerShell:

```powershell
$env:CATALINA_HOME = "C:\tools\apache-tomcat-10.1.x"
$env:JPAWEB_DB_PASSWORD = "<MẬT_KHẨU_MYSQL_CỦA_BẠN>"
$env:JPAWEB_UPLOAD_DIR = "$env:USERPROFILE\jpaweb-uploads"
```

Copy WAR vào Tomcat:

```powershell
Copy-Item `
  .\target\jpa-web-assignment-01.war `
  "$env:CATALINA_HOME\webapps\jpa-web-assignment-01.war" `
  -Force
```

Khởi động Tomcat:

```powershell
& "$env:CATALINA_HOME\bin\startup.bat"
```

Đợi khoảng 5 đến 10 giây. Tomcat sẽ tự giải nén WAR thành:

```text
%CATALINA_HOME%\webapps\jpa-web-assignment-01
```

Kiểm tra HTTP bằng PowerShell:

```powershell
Invoke-WebRequest `
  -UseBasicParsing `
  "http://localhost:8080/jpa-web-assignment-01/" `
  | Select-Object StatusCode
```

Kết quả mong đợi:

```text
StatusCode
----------
200
```

## 13. Truy cập bằng browser

Mở trang chủ:

```powershell
Start-Process "http://localhost:8080/jpa-web-assignment-01/"
```

Hoặc mở thẳng trang quản lý Category:

```powershell
Start-Process "http://localhost:8080/jpa-web-assignment-01/admin/categories"
```

Các URL kiểm thử:

| Chức năng | Method | URL |
|---|---:|---|
| Trang chủ | GET | `http://localhost:8080/jpa-web-assignment-01/` |
| Danh sách Category | GET | `http://localhost:8080/jpa-web-assignment-01/admin/categories` |
| Trang 2 | GET | `http://localhost:8080/jpa-web-assignment-01/admin/categories?page=2` |
| Tìm kiếm | GET | `http://localhost:8080/jpa-web-assignment-01/admin/categories?keyword=Laptop` |
| Form thêm | GET | `http://localhost:8080/jpa-web-assignment-01/admin/category/add` |
| Insert | POST | `/jpa-web-assignment-01/admin/category/insert` |
| Form sửa | GET | `/jpa-web-assignment-01/admin/category/edit?id=1` |
| Update | POST | `/jpa-web-assignment-01/admin/category/update` |
| Delete | GET | `/jpa-web-assignment-01/admin/category/delete?id=1` |
| Hiển thị ảnh local | GET | `/jpa-web-assignment-01/image?fname=<filename>` |

## 14. Dừng Tomcat

Chạy:

```powershell
& "$env:CATALINA_HOME\bin\shutdown.bat"
```

Kiểm tra cổng 8080 đã đóng:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 8080 -ErrorAction SilentlyContinue
```

Nếu không có kết quả, Tomcat đã dừng.

## 15. Quy trình chạy nhanh sau lần cài đặt đầu tiên

Sau khi JDK, MySQL và Tomcat đã được cài, mỗi lần chạy project chỉ cần:

```powershell
cd C:\Users\<YOUR_USERNAME>\Desktop\BT1-WEB

$env:CATALINA_HOME = "C:\tools\apache-tomcat-10.1.x"
$env:JPAWEB_DB_PASSWORD = "<MẬT_KHẨU_MYSQL_CỦA_BẠN>"
$env:JPAWEB_UPLOAD_DIR = "$env:USERPROFILE\jpaweb-uploads"

.\mvnw.cmd clean package

Copy-Item `
  .\target\jpa-web-assignment-01.war `
  "$env:CATALINA_HOME\webapps\jpa-web-assignment-01.war" `
  -Force

& "$env:CATALINA_HOME\bin\startup.bat"

Start-Process "http://localhost:8080/jpa-web-assignment-01/"
```

## 16. Chạy bằng Tomcat Windows Service

Nếu cài Tomcat bằng Windows Service Installer, thư mục thường nằm trong:

```text
C:\Program Files\Apache Software Foundation\Tomcat 10.1
```

Việc copy WAR hoặc restart service trong `Program Files` thường cần PowerShell chạy bằng quyền Administrator.

Ví dụ:

```powershell
Stop-Service Tomcat10

Copy-Item `
  .\target\jpa-web-assignment-01.war `
  "C:\Program Files\Apache Software Foundation\Tomcat 10.1\webapps\jpa-web-assignment-01.war" `
  -Force

Start-Service Tomcat10
```

Lưu ý: Windows Service không tự nhận biến môi trường chỉ được đặt trong một cửa sổ PowerShell thường. Với cách chạy service, cần cấu hình password ở cấp service hoặc sử dụng một bản `persistence.xml` dành riêng cho máy local. Không đưa mật khẩu đó lên GitHub.

Để tránh vấn đề quyền và biến môi trường, cách ZIP Tomcat ở phần trên dễ dùng hơn cho việc học và demo.

## 17. Deploy lại sau khi sửa code

Sau mỗi lần sửa source:

```powershell
& "$env:CATALINA_HOME\bin\shutdown.bat"

.\mvnw.cmd clean package

Copy-Item `
  .\target\jpa-web-assignment-01.war `
  "$env:CATALINA_HOME\webapps\jpa-web-assignment-01.war" `
  -Force

& "$env:CATALINA_HOME\bin\startup.bat"
```

Sau đó refresh browser bằng `Ctrl + F5`.

## 18. Kiểm tra log Tomcat

Nếu trang trả về lỗi 404 hoặc 500, tìm log mới nhất:

```powershell
$latestLog = Get-ChildItem "$env:CATALINA_HOME\logs" -File |
  Sort-Object LastWriteTime |
  Select-Object -Last 1

Get-Content $latestLog.FullName -Tail 200
```

Tìm các từ khóa lỗi:

```powershell
Select-String `
  -Path "$env:CATALINA_HOME\logs\*" `
  -Pattern "SEVERE|ERROR|Exception|Caused by" `
  -CaseSensitive:$false
```

## 19. Xử lý lỗi thường gặp

### Lỗi `git is not recognized`

Git chưa được cài hoặc chưa có trong `Path`. Cài Git for Windows và mở PowerShell mới.

### Lỗi `java is not recognized`

Kiểm tra `JAVA_HOME` và `%JAVA_HOME%\bin` trong `Path`.

```powershell
$env:JAVA_HOME
Get-Command java
```

### Maven Wrapper dùng sai Java

Chạy:

```powershell
.\mvnw.cmd -version
```

Nếu Maven Wrapper hiển thị Java khác 17, sửa `JAVA_HOME`, đóng PowerShell và mở lại.

### Lỗi `mvn is not recognized`

Kiểm tra `MAVEN_HOME` và `%MAVEN_HOME%\bin` trong `Path`.

### Lỗi không kết nối được MySQL

Kiểm tra lần lượt:

```powershell
Get-Service -Name MySQL*
mysql -u root -p -e "SELECT 1;"
[bool]$env:JPAWEB_DB_PASSWORD
```

Xác nhận:

- MySQL đang chạy.
- Port là `3306`.
- Database là `jpa_web`.
- User là `root`.
- Password đúng.
- Tomcat được khởi động từ cửa sổ PowerShell đã đặt `JPAWEB_DB_PASSWORD`.

### Lỗi `Unknown database 'jpa_web'`

Chạy lại phần tạo database:

```powershell
$sqlFile = (Resolve-Path .\database.sql).Path.Replace('\', '/')
mysql -u root -p --default-character-set=utf8mb4 --execute="SOURCE $sqlFile"
```

### Lỗi HTTP 404

Kiểm tra:

```powershell
Test-Path "$env:CATALINA_HOME\webapps\jpa-web-assignment-01.war"
Get-ChildItem "$env:CATALINA_HOME\webapps"
```

URL phải có đúng context path:

```text
http://localhost:8080/jpa-web-assignment-01/
```

Không truy cập nhầm `http://localhost:8080/` nếu muốn mở ứng dụng này.

### Lỗi port 8080 đã được sử dụng

Kiểm tra process đang giữ cổng:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 8080 |
  Select-Object LocalAddress, LocalPort, OwningProcess
```

Có thể dừng Tomcat cũ hoặc đổi cổng trong:

```text
%CATALINA_HOME%\conf\server.xml
```

Tìm:

```xml
<Connector port="8080" protocol="HTTP/1.1"
```

Ví dụ đổi thành `8081`, sau đó truy cập:

```text
http://localhost:8081/jpa-web-assignment-01/
```

### Lỗi upload ảnh

Kiểm tra thư mục upload:

```powershell
$env:JPAWEB_UPLOAD_DIR
Test-Path $env:JPAWEB_UPLOAD_DIR
```

Đảm bảo tài khoản chạy Tomcat có quyền đọc và ghi thư mục.

Ứng dụng chỉ chấp nhận:

- `.jpg`
- `.jpeg`
- `.png`
- `.webp`

Kích thước tối đa là 5 MB.

### Chữ tiếng Việt bị lỗi

Database phải dùng `utf8mb4`. Hãy chạy `database.sql` và không tự đổi JDBC URL trong `persistence.xml`.

## 20. Checklist sau khi chạy

Kiểm tra theo thứ tự:

- [ ] `java -version` là Java 17
- [ ] `.\mvnw.cmd -version` sử dụng Java 17
- [ ] MySQL đang chạy tại port 3306
- [ ] Database `jpa_web` tồn tại
- [ ] Có table `categories` và `videos`
- [ ] Có 10 Category mẫu
- [ ] `.\mvnw.cmd clean package` báo `BUILD SUCCESS`
- [ ] WAR tồn tại trong `target`
- [ ] WAR đã được copy vào `webapps`
- [ ] Tomcat đang chạy tại port 8080
- [ ] Trang chủ trả HTTP 200
- [ ] Danh sách Category hiển thị
- [ ] Thêm Category thành công
- [ ] Upload ảnh thành công
- [ ] Image URL hoạt động
- [ ] Sửa và xóa Category thành công
- [ ] Search hoạt động
- [ ] Pagination hoạt động
- [ ] Restart Tomcat không làm mất dữ liệu

## 21. Lưu ý trước khi commit hoặc nộp bài

Kiểm tra Git:

```powershell
git status
git diff --check
```

Theo cấu hình local hiện tại, `persistence.xml` chứa:

```text
123456
```

Nếu repository public, đổi password thành biến môi trường hoặc placeholder trước khi push. Ngoài ra không commit:

- Thư mục `target/`
- File log
- File cấu hình IDE không cần thiết
- Thư mục upload ảnh

Build cuối trước khi nộp:

```powershell
.\mvnw.cmd clean package
```

Sau đó kiểm tra lại:

```powershell
git status
Get-Item .\target\jpa-web-assignment-01.war
```
