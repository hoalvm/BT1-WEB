<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JPA Web Assignment 01</title>
    <c:url var="styleUrl" value="/assets/css/app.css" />
    <link rel="stylesheet" href="${styleUrl}">
</head>
<body>
<main class="landing">
    <section class="card hero">
        <h1>Category Manager</h1>
        <p class="muted">Ly Vo My Hoa</p>
        <c:url var="categoryUrl" value="/admin/categories" />
        <a class="button primary" href="${categoryUrl}">Get Started</a>
    </section>
</main>
</body>
</html>
