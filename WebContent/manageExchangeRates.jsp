<%@ include file="header.jsp" %>
<%@ page import="model.ExchangeRate, model.Currency, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<ExchangeRate> rates = (List<ExchangeRate>) request.getAttribute("exchangeRates");
	String successMessage = (String) request.getAttribute("successMessage");
    String popupMessage = (String) request.getAttribute("popupMessage");
    List<Currency> currencies = (List<Currency>) request.getAttribute("currencies");

    String role = (String) session.getAttribute("role");
    boolean isAdmin = "admin".equalsIgnoreCase(role);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Exchange Rates</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f2f2f2;
            padding: 20px;
        }

        h2 {
            color: #333;
        }

        table {
            width: 70%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            border: 1px solid #999;
            padding: 10px;
            text-align: left;
        }

        form {
            margin-top: 20px;
        }

        input[type="text"], input[type="number"] {
            padding: 5px;
            margin-right: 10px;
        }

        input[type="submit"] {
            padding: 5px 10px;
            background-color: #007bff;
            color: white;
            border: none;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: #0056b3;
        }

        .success {
            color: green;
        }

        .error {
            color: red;
        }
        
		<% if (!isAdmin) { %>
		/* Grey out Add/Delete buttons for non-admins and disable pointer */
		form[onsubmit*="showPermissionAlert"] input[type="submit"] {
		    background-color: #a0a0a0 !important; /* grey color */
		    cursor: not-allowed !important;
		    color: #666 !important;
		    pointer-events: none; /* disable clicks */
		    opacity: 0.7;
		}
		<% } %>

        
    </style>

    <script>
        function showPermissionAlert() {
            alert("❌ You need permission from the team to perform this action.");
        }
        <% if (popupMessage != null) { %>
        window.onload = function() {
            alert("<%= popupMessage %>");
        };
    <% } %>
    </script>
</head>
<body>

<h2>Manage Exchange Rates</h2>

<% if (successMessage != null) { %>
    <p class="success"><%= successMessage %></p>
<% } %>

<form 
    action="<%= isAdmin ? "exchangeRate" : "#" %>" 
    method="post" 
    onsubmit="<%= isAdmin ? "" : "showPermissionAlert(); return false;" %>">

    <label>From Currency Code:</label>
    <input type="text" name="from" required>

    <label>To Currency Code:</label>
    <input type="text" name="to" required>

    <label>Rate:</label>
    <input type="number" step="0.0001" name="rate" required>

    <input type="submit" name="action" value="Add">
</form>
<form method="get" action="exchangeRate">
    <label>Search Currency Code:</label>
    <input type="text" name="search" placeholder="e.g. USD" value="<%= request.getAttribute("searchTerm") != null ? request.getAttribute("searchTerm") : "" %>">
    <input type="submit" value="Search">
    <input type="button" value="Reset" onclick="window.location.href='exchangeRate'">
</form>
<br>


<% if (rates != null && !rates.isEmpty()) { %>
    <table>
        <thead>
            <tr>
                <th>From</th>
                <th>To</th>
                <th>Rate</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (ExchangeRate rate : rates) { %>
                <tr>
                    <td><%= rate.getFromCurrency().getCode() %></td>
                    <td><%= rate.getToCurrency().getCode() %></td>
                    <td><%= rate.getRate() %></td>
                    <td>
                        <form 
                            action="<%= isAdmin ? "exchangeRate" : "#" %>" 
                            method="post" 
                            style="display:inline;" 
                            onsubmit="<%= isAdmin ? "" : "showPermissionAlert(); return false;" %>">
                            
                            <input type="hidden" name="from" value="<%= rate.getFromCurrency().getCode() %>">
                            <input type="hidden" name="to" value="<%= rate.getToCurrency().getCode() %>">
                            <input type="submit" name="action" value="Delete">
                        </form>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
<% } else { %>
    <p>No exchange rates available.</p>
<% } %>

</body>
</html>
