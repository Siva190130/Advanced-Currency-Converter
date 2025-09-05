<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Home - Currency Converter</title>
    <style>
        body {
            background: linear-gradient(to right, #dbe6f6, #c5796d);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 700px;
            margin: 60px auto;
            text-align: center;
            padding: 50px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        h1 {
            font-size: 32px;
            color: #333;
            margin-bottom: 20px;
        }

        p.description {
            font-size: 17px;
            color: #555;
            line-height: 1.6;
            margin-bottom: 40px;
        }

        .btn {
            background-color: #007bff;
            color: white;
            padding: 12px 24px;
            margin: 10px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }

        .btn:hover {
            background-color: #0056b3;
        }

        footer {
            text-align: center;
            padding: 30px 10px;
            margin-top: 60px;
            background: #343a40;
            color: #ddd;
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
        <h1>Welcome to the Currency Converter App</h1>
        <p class="description">
            A modern web application built using <strong>Java</strong>, <strong>JSP/Servlets</strong>, and <strong>MySQL</strong> — this platform lets users convert real-time currencies powered by the <strong>Frankfurter API</strong>.  
            Designed with practical use in mind, this mirrors how global fintech services operate — from dynamic currency updates to user-specific sessions.
            <br/><br/>
            Whether you're a developer, traveler, or someone curious about exchange rates, this tool brings the world’s money closer — one conversion at a time. 💱🌎
        </p>
        <a href="register.jsp" class="btn">Register</a>
        <a href="login.jsp" class="btn">Login</a>
    </div>

    <footer>
        &copy; 2025 Currency Converter System by Shiv. Powered by <a href="https://www.frankfurter.app" target="_blank">Frankfurter API</a> | Built with 💙 in Java.
    </footer>

</body>
</html>
