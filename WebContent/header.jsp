<!-- header.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!-- BOOTSTRAP CDN (remove if your app already loads Bootstrap) -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
      integrity="sha384-..." crossorigin="anonymous">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-..." crossorigin="anonymous"></script>

<nav class="navbar navbar-expand-lg" style="background-color: #007bff;">
  <div class="container-fluid">
    <!-- Brand / Logo -->
    <a class="navbar-brand d-flex align-items-center text-white" href="convert" style="gap:0.6rem;">
      <!-- Replace the src below with your logo path, e.g. ${pageContext.request.contextPath}/assets/images/logo.png -->
      <img src="logo.png" alt="Currency Converter logo" width="42" height="42"
           class="rounded" style="object-fit:contain; background: rgba(255,255,255,0.06); padding:4px;">
      <span class="fw-bold fs-5">Currency Converter</span>
    </a>

    <!-- Toggler / Hamburger (Bootstrap manages aria-expanded) -->
    <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#mainNavbar"
            aria-controls="mainNavbar" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon" style="filter: invert(1) brightness(2);"></span>
    </button>

    <!-- Navigation items -->
    <div class="collapse navbar-collapse justify-content-end" id="mainNavbar">
      <ul class="navbar-nav mb-2 mb-lg-0 align-items-lg-center">
        <li class="nav-item">
          <a class="nav-link text-white px-3" href="convert">Home</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white px-3" href="exchangeRate">Manage Rates</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white px-3" href="currency">Manage Currencies</a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white px-3" href="login.jsp">Back</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
<hr style="margin:0; border:0; height:1px; background: rgba(255,255,255,0.08);">

<!-- Small optional CSS for hover lift animation (keeps Bootstrap for structure) -->
<style>
  /* Only a tiny enhancement — Bootstrap handles layout & responsiveness */
  .nav-link {
    transition: transform 160ms ease, background-color 180ms ease, box-shadow 180ms ease;
    border-radius: 8px;
  }
  .nav-link:hover {
    transform: translateY(-3px);
    background: rgba(255,255,255,0.08);
    box-shadow: 0 6px 14px rgba(0,0,0,0.12);
  }

  /* Make the default navbar-toggler-icon visible on colored background */
  .navbar-toggler-icon {
    background-image: url("data:image/svg+xml;charset=utf8,%3Csvg viewBox='0 0 30 30' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='white' stroke-width='2' stroke-linecap='round' stroke-miterlimit='10' d='M4 7h22M4 15h22M4 23h22'/%3E%3C/svg%3E");
  }
</style>
