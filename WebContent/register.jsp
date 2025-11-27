<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Bootstrap Bundle JS (Popper included) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body {
            background: linear-gradient(135deg, #eef2f3, #e8f0ff);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            font-family: Arial, Helvetica, sans-serif;
        }
        .card-register {
            max-width: 540px;
            margin: 5.5rem auto 2.5rem;
            padding: 1.75rem;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(2,6,23,0.06);
        }
        .toast-container-top { position: fixed; top: 1rem; right: 1rem; z-index: 1200; }
        .input-group .input-group-text { background: #f8f9fa; }
        .btn-register:hover { background-color: #0056b3 !important; }
        .btn-back:hover    { background-color: #495057 !important; }
        small.form-text.error { color: #d63384; }
    </style>
</head>
<body>

<!-- Toast container -->
<div class="toast-container-top">
    <div id="serverSuccessToast" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="serverSuccessBody"></div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>

    <div id="serverErrorToast" class="toast align-items-center text-bg-danger border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="serverErrorBody"></div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
</div>

<!-- Card -->
<div class="card card-register bg-white">
    <div class="card-body">
        <h3 class="card-title text-center text-primary fw-bold mb-4">Register</h3>

        <form id="registerForm" action="RegisterServlet" method="post" novalidate>
            <!-- Username -->
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold">Username</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person-fill"></i></span>
                    <input type="text" id="username" name="username" class="form-control" placeholder="Min 4 chars, letters/numbers/_" required>
                </div>
                <small id="usernameError" class="form-text error"></small>
            </div>

            <!-- Email -->
            <div class="mb-3">
                <label for="email" class="form-label fw-semibold">Email</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope-fill"></i></span>
                    <input type="email" id="email" name="email" class="form-control" placeholder="you@example.com" required>
                </div>
                <small id="emailError" class="form-text error"></small>
            </div>

            <!-- Password -->
            <div class="mb-3">
                <label for="password" class="form-label fw-semibold">Password</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                    <input type="password" id="password" name="password" class="form-control" placeholder="Min 6 chars, letters & numbers" required>
                    <button type="button" id="togglePassword" class="btn btn-outline-secondary" title="Show/Hide password">
                        <i class="bi bi-eye" id="togglePwdIcon"></i>
                    </button>
                </div>
                <small id="passwordError" class="form-text error"></small>
            </div>

            <!-- Confirm Password -->
            <div class="mb-3">
                <label for="confirmPassword" class="form-label fw-semibold">Confirm Password</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-shield-lock-fill"></i></span>
                    <input type="password" id="confirmPassword" class="form-control" placeholder="Re-type password" required>
                    <button type="button" id="toggleConfirm" class="btn btn-outline-secondary" title="Show/Hide password">
                        <i class="bi bi-eye" id="toggleConfirmIcon"></i>
                    </button>
                </div>
                <small id="confirmError" class="form-text error"></small>
            </div>

            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-primary btn-register">Register</button>
                <a href="login.jsp" class="btn btn-secondary btn-back">← Back to Login</a>
            </div>
        </form>

        <!-- Inline server messages as fallback (kept but toasts are primary) -->
        <div class="mt-3">
            <div class="text-success fw-semibold">
                <%= request.getAttribute("message") != null ? request.getAttribute("message") : "" %>
            </div>
            <div class="text-danger fw-semibold">
                <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
            </div>
        </div>
    </div>
</div>

<script>
(function(){
    const form = document.getElementById('registerForm');

    // Elements
    const username = document.getElementById('username');
    const email = document.getElementById('email');
    const pwd = document.getElementById('password');
    const confirmPwd = document.getElementById('confirmPassword');

    const usernameError = document.getElementById('usernameError');
    const emailError = document.getElementById('emailError');
    const passwordError = document.getElementById('passwordError');
    const confirmError = document.getElementById('confirmError');

    // Toggle password visibility
    function setupToggle(toggleId, inputEl, iconId) {
        const btn = document.getElementById(toggleId);
        const icon = document.getElementById(iconId);
        btn.addEventListener('click', function(){
            const type = inputEl.getAttribute('type') === 'password' ? 'text' : 'password';
            inputEl.setAttribute('type', type);
            icon.className = (type === 'text') ? 'bi bi-eye-slash' : 'bi bi-eye';
            btn.focus();
        });
    }
    setupToggle('togglePassword', pwd, 'togglePwdIcon');
    setupToggle('toggleConfirm', confirmPwd, 'toggleConfirmIcon');

    // Validation rules
    function clearErrors(){
        usernameError.textContent = '';
        emailError.textContent = '';
        passwordError.textContent = '';
        confirmError.textContent = '';
    }

    function validateAll(){
        clearErrors();
        let valid = true;

        const u = username.value.trim();
        const e = email.value.trim();
        const p = pwd.value;
        const cp = confirmPwd.value;

        // username: min 4 chars, only letters/numbers/_
        if (u.length < 4 || !/^[a-zA-Z0-9_]+$/.test(u)) {
            usernameError.textContent = "Min 4 chars; letters, numbers and underscores only.";
            valid = false;
        }

        // email basic pattern
        // NOTE: use single backslash sequences in regex literals (\w, \d)
        if (!/^[\w.\-]+@[\w.\-]+\.[A-Za-z]{2,6}$/.test(e)) {
            emailError.textContent = "Invalid email format.";
            valid = false;
        }

        // password: min 6, at least one letter and one number
        if (p.length < 6 || !/\d/.test(p) || !/[A-Za-z]/.test(p)) {
            passwordError.textContent = "Min 6 chars, must contain letters & numbers.";
            valid = false;
        }

        // confirm
        if (p !== cp) {
            confirmError.textContent = "Passwords do not match.";
            valid = false;
        }

        return valid;
    }

    // Prevent submission if validation fails
    form.addEventListener('submit', function(e){
        if (!validateAll()) {
            e.preventDefault();
            e.stopPropagation();
            return false;
        }
        // allow submit to server otherwise
    });

    // Live validation (optional)
    username.addEventListener('input', () => { if (usernameError.textContent) validateAll(); });
    email.addEventListener('input', () => { if (emailError.textContent) validateAll(); });
    pwd.addEventListener('input', () => { if (passwordError.textContent || confirmError.textContent) validateAll(); });
    confirmPwd.addEventListener('input', () => { if (confirmError.textContent) validateAll(); });

    // Server-side messages -> toasts
    // Use single-quoted JS strings and escape any single quotes coming from server
    const serverMessage = '<%= String.valueOf(request.getAttribute("message") == null ? "" : request.getAttribute("message")).replace("'", "\\'") %>';
    const serverError   = '<%= String.valueOf(request.getAttribute("error")   == null ? "" : request.getAttribute("error")).replace("'", "\\'") %>';

    if (serverMessage && serverMessage.trim().length > 0) {
        document.getElementById('serverSuccessBody').textContent = serverMessage;
        new bootstrap.Toast(document.getElementById('serverSuccessToast'), { delay: 4500 }).show();
    }
    if (serverError && serverError.trim().length > 0) {
        document.getElementById('serverErrorBody').textContent = serverError;
        new bootstrap.Toast(document.getElementById('serverErrorToast'), { delay: 6000 }).show();
    }
})();
</script>

</body>
</html>
