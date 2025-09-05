<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <style>
        body {
            background-color: #eef2f3;
            font-family: Arial, sans-serif;
        }
        .container {
            width: 400px;
            margin: 80px auto;
            padding: 30px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0px 0px 12px rgba(0,0,0,0.2);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            font-weight: bold;
        }
        input[type="text"], input[type="email"], input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-top: 6px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
        }
        .msg {
            color: green;
            text-align: center;
        }
        .error {
            color: red;
            text-align: center;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Register</h2>
   <form action="RegisterServlet" method="post" onsubmit="return validateForm();">
    <div>
        <label>Username:</label>
        <input type="text" name="username" id="username" required>
        <small id="usernameError" style="color:red"></small>
    </div>

    <div>
        <label>Email:</label>
        <input type="email" name="email" id="email" required>
        <small id="emailError" style="color:red"></small>
    </div>

    <div>
        <label>Password:</label>
        <input type="password" name="password" id="password" required>
        <small id="passwordError" style="color:red"></small>
    </div>

    <button type="submit">Register</button>

    <% if (request.getAttribute("error") != null) { %>
        <p style="color:red;"><%= request.getAttribute("error") %></p>
    <% } %>
    <% if (request.getAttribute("message") != null) { %>
        <p style="color:green;"><%= request.getAttribute("message") %></p>
    <% } %>
</form>

<script>
function validateForm() {
    let valid = true;

    // Clear old errors
    document.getElementById("usernameError").innerText = "";
    document.getElementById("emailError").innerText = "";
    document.getElementById("passwordError").innerText = "";

    let username = document.getElementById("username").value.trim();
    let email = document.getElementById("email").value.trim();
    let password = document.getElementById("password").value.trim();

    if (username.length < 4 || !/^[a-zA-Z0-9_]+$/.test(username)) {
        document.getElementById("usernameError").innerText = "Min 4 chars, only letters/numbers/underscores.";
        valid = false;
    }

    if (!/^[\w.-]+@[\w.-]+\.[A-Za-z]{2,6}$/.test(email)) {
        document.getElementById("emailError").innerText = "Invalid email format.";
        valid = false;
    }

    if (password.length < 6 || !/\d/.test(password) || !/[A-Za-z]/.test(password)) {
        document.getElementById("passwordError").innerText = "Min 6 chars, must contain letters & numbers.";
        valid = false;
    }

    return valid;
}
</script> 
   
    <div class="msg">
        <%= request.getAttribute("message") != null ? request.getAttribute("message") : "" %>
    </div>
    <div class="error">
        <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
    </div>
</div>
</body>
</html>
