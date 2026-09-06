<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm danh mục</title>
    <c:url var="styleUrl" value="/assets/css/app.css" />
    <link rel="stylesheet" href="${styleUrl}">
</head>
<body>
<c:url var="listUrl" value="/admin/categories" />
<main class="container narrow">
    <div class="page-heading">
        <div>
            <a class="back-link" href="${listUrl}"><span aria-hidden="true">←</span> Danh mục</a>
            <h1>Thêm danh mục</h1>
        </div>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert error" role="alert"><c:out value="${errorMessage}" /></div>
    </c:if>

    <section class="card form-card">
        <c:url var="insertUrl" value="/admin/category/insert" />
        <form method="post" action="${insertUrl}" enctype="multipart/form-data">
            <div class="form-group">
                <label for="categoryName">Tên danh mục <span aria-hidden="true">*</span></label>
                <input id="categoryName" name="categoryName" type="text" maxlength="255" required
                       value="${fn:escapeXml(category.categoryName)}"
                       placeholder="Ví dụ: Điện thoại" autofocus>
            </div>

            <div class="form-group">
                <label for="imageUrl">URL ảnh</label>
                <input id="imageUrl" name="imageUrl" type="url" maxlength="500"
                       value="${fn:escapeXml(imageUrl)}"
                       placeholder="https://example.com/image.jpg">
                <small>Tùy chọn · file tải lên được ưu tiên.</small>
            </div>

            <div class="form-group">
                <label for="imagesFile">Tải ảnh</label>
                <input id="imagesFile" name="imagesFile" type="file"
                       accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp">
                <small>JPG, PNG, WEBP · tối đa 5 MB.</small>
            </div>

            <div class="form-group">
                <label for="status">Trạng thái <span aria-hidden="true">*</span></label>
                <select id="status" name="status" required>
                    <option value="1" <c:if test="${category.status == 1}">selected</c:if>>Hoạt động</option>
                    <option value="0" <c:if test="${category.status == 0}">selected</c:if>>Khóa</option>
                </select>
            </div>

            <div class="form-actions">
                <button class="button primary" type="submit">Thêm</button>
                <a class="button secondary" href="${listUrl}">Hủy</a>
            </div>
        </form>
    </section>
</main>
</body>
</html>
