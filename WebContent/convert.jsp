<%@ include file="header.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Currency Converter</title>
    <style>
        body {
            background: linear-gradient(to right, #74ebd5, #ACB6E5);
            font-family: 'Segoe UI', sans-serif;
        }
        .container {
            width: 500px;
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
        select, input[type="number"] {
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
        .result {
            text-align: center;
            font-size: 18px;
            color: green;
            margin-top: 20px;
        }
        .error {
            color: red;
            text-align: center;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Currency Converter</h2>
    <form method="post" action="convert">
        <label>Amount:</label>
        <input type="number" step="0.01" name="amount" required />

        <label>From Currency:</label>
        <select name="fromCurrency" required>
            <c:forEach var="entry" items="${currencies}">
                <option value="${entry.key}">${entry.key} - ${entry.value}</option>
            </c:forEach>
        </select>

        <label>To Currency:</label>
        <select name="toCurrency" required>
            <c:forEach var="entry" items="${currencies}">
                <option value="${entry.key}">${entry.key} - ${entry.value}</option>
            </c:forEach>
        </select>

        <button type="submit">Convert</button>
    </form>

    <c:if test="${not empty result}">
        <div class="result">${result}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="error">${error}</div>
    </c:if>
</div>
</body>
</html>
