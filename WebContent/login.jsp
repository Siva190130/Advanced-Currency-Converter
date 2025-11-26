<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <!-- Bootstrap Bundle JS (includes Popper) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body {
            background: linear-gradient(135deg, #f6f9fc, #e0eafc);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .login-card {
            max-width: 460px;
            width: 100%;
            margin: 6.5rem auto 2.5rem auto;
            padding: 32px;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 10px 30px rgba(2,6,23,0.06);
        }

        .footer {
            background-color: #343a40;
            color: #ccc;
        }

        .footer a { color: #ffc107; }
        .footer a:hover { text-decoration: underline; }

        /* Slight hover polish for buttons */
        .btn-login:hover { background-color: #0056b3 !important; }
        .btn-back:hover  { background-color: #495057 !important; }

        /* Toast top-right container */
        .toast-container-top {
            position: fixed;
            top: 1rem;
            right: 1rem;
            z-index: 1100;
        }

        /* Ensure input-group icons don't shrink */
        .input-group .input-group-text { background: #f8f9fa; border-right: 0; }
        .input-group .form-control { border-left: 0; }
    </style>
</head>
<body>

<!-- Toast container for server messages -->
<div class="toast-container-top">
    <!-- Success toast (shown via JS only if message exists) -->
    <div id="serverSuccessToast" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="serverSuccessBody"></div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>

    <!-- Error toast (shown via JS only if error exists) -->
    <div id="serverErrorToast" class="toast align-items-center text-bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="serverErrorBody"></div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
</div>

<!-- Login Card -->
<div class="login-card">
    <h3 class="text-center mb-4 text-primary fw-bold">Login</h3>

    <form id="loginForm" action="LoginServlet" method="post" novalidate>
        <!-- Username with icon -->
        <div class="mb-3">
            <label for="username" class="form-label fw-semibold">Username</label>
            <div class="input-group">
                <span class="input-group-text" id="username-addon"><i class="bi bi-person-fill"></i></span>
                <input type="text" id="username" name="username" class="form-control" aria-describedby="username-addon" placeholder="Enter username" required>
                <div class="invalid-feedback">
                    Please enter your username.
                </div>
            </div>
        </div>

        <!-- Password with icon and show/hide toggle -->
        <div class="mb-3">
            <label for="password" class="form-label fw-semibold">Password</label>
            <div class="input-group">
                <span class="input-group-text" id="password-addon"><i class="bi bi-lock-fill"></i></span>
                <input type="password" id="password" name="password" class="form-control" aria-describedby="password-addon" placeholder="Enter password" required>
                <button type="button" class="btn btn-outline-secondary" id="togglePassword" aria-label="Show password" title="Show/Hide password">
                    <i class="bi bi-eye" id="togglePasswordIcon"></i>
                </button>
                <div class="invalid-feedback">
                    Please enter your password.
                </div>
            </div>
        </div>

        <!-- Submit -->
        <button type="submit" class="btn btn-primary w-100 btn-login mb-2">Login</button>
    </form>

    <!-- Back Button -->
    <a href="home.jsp" class="btn btn-secondary w-100 btn-back">← Back to Home</a>
</div>

<!-- Footer -->
<footer class="footer text-center py-3 mt-auto">
    &copy; 2025 Currency Converter System |
    Developed by <strong>Shiv</strong> 💻 |
    Powered by
    <a href="https://www.frankfurter.app" target="_blank">Frankfurter API</a>
</footer>

<script>
    (function () {
        // Bootstrap client-side validation
        const form = document.getElementById('loginForm');

        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);

        // Password show/hide toggle
        const pwdField = document.getElementById('password');
        const toggleBtn = document.getElementById('togglePassword');
        const toggleIcon = document.getElementById('togglePasswordIcon');

        toggleBtn.addEventListener('click', function () {
            const type = pwdField.getAttribute('type') === 'password' ? 'text' : 'password';
            pwdField.setAttribute('type', type);

            // update icon and accessible label
            if (type === 'text') {
                toggleIcon.className = 'bi bi-eye-slash';
                toggleBtn.setAttribute('aria-label', 'Hide password');
                toggleBtn.setAttribute('title', 'Hide password');
            } else {
                toggleIcon.className = 'bi bi-eye';
                toggleBtn.setAttribute('aria-label', 'Show password');
                toggleBtn.setAttribute('title', 'Show password');
            }
            // keep focus on the button for keyboard users
            toggleBtn.focus();
        });

        // Show server-side messages (JSP request attributes) as toasts
        // We extract values rendered into the page via JSP expressions and show toasts accordingly.
       const serverMessage = "<%= (request.getAttribute("message") != null) ? request.getAttribute("message") : "" %>";
	   const serverError   = "<%= (request.getAttribute("error") != null) ? request.getAttribute("error") : "" %>";


        if (serverMessage && serverMessage.trim().length > 0) {
            document.getElementById('serverSuccessBody').textContent = serverMessage;
            const toast = new bootstrap.Toast(document.getElementById('serverSuccessToast'), { delay: 4500 });
            toast.show();
        }

        if (serverError && serverError.trim().length > 0) {
            document.getElementById('serverErrorBody').textContent = serverError;
            const toast = new bootstrap.Toast(document.getElementById('serverErrorToast'), { delay: 6000 });
            toast.show();
        }

        // Optional: clear toasts when user navigates/clicks outside, handled by Bootstrap close buttons automatically
    })();
</script>

</body>
</html>
