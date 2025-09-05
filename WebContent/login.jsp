<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <style>
        body {
            margin: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f6f9fc, #e0eafc);
        }

        .container {
            width: 400px;
            margin: 100px auto 40px auto;
            padding: 40px;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
        }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }

        label {
            font-weight: bold;
            display: block;
            margin-bottom: 6px;
            color: #444;
        }

        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 15px;
        }

        button, .back-btn {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
        }

        button {
            background-color: #007bff;
            color: white;
            margin-bottom: 10px;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #0056b3;
        }

        .back-btn {
            background-color: #6c757d;
            color: white;
            text-align: center;
            text-decoration: none;
            display: inline-block;
        }

        .back-btn:hover {
            background-color: #495057;
        }

        .msg, .error {
            text-align: center;
            margin-top: 10px;
            font-weight: bold;
        }

        .msg {
            color: green;
        }

        .error {
            color: red;
        }

        footer {
            text-align: center;
            padding: 20px 10px;
            background-color: #343a40;
            color: #ccc;
            font-size: 14px;
        }

        footer a {
            color: #ffc107;
            text-decoration: none;
        } 

        footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Login</h2>

    <div class="msg">
        <%= request.getAttribute("message") != null ? request.getAttribute("message") : "" %>
    </div>

    <form action="LoginServlet" method="post">
        <label>Username:</label>
        <input type="text" name="username" required />

        <label>Password:</label>
        <input type="password" name="password" required />

        <button type="submit">Login</button>
    </form>

    <!-- Back Button -->
    <a href="home.jsp" class="back-btn">← Back to Home</a>

    <div class="error">
        <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
    </div>
</div>

<footer>
    &copy; 2025 Currency Converter System | Developed by Shiv 💻 | Powered by 
    <a href="https://www.frankfurter.app" target="_blank">Frankfurter API</a>
</footer>

</body>
</html>
