<%@ include file="header.jsp" %>
<%@ page import="model.Currency, java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    List<Currency> currencies = (List<Currency>) request.getAttribute("currencies");
    String successMessage = (String) request.getAttribute("successMessage");
    String popupMessage = (String) request.getAttribute("popupMessage");

    String role = (String) session.getAttribute("role");
    boolean isAdmin = "admin".equalsIgnoreCase(role);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Currencies</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            padding: 20px;
        }

        h2 {
            color: #333;
        }

        table {
            width: 60%;
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

        input[type="text"] {
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

<h2>Manage Currencies</h2>

<% if (successMessage != null) { %>
    <p class="success"><%= successMessage %></p>
<% } %>

<!-- Add Currency Form -->
<form 
    action="<%= isAdmin ? "currency" : "#" %>" 
    method="post"
    onsubmit="<%= isAdmin ? "" : "showPermissionAlert(); return false;" %>">
    
    <label>Currency Code:</label>
    <input type="text" name="code" required>

    <label>Currency Name:</label>
    <input type="text" name="name" required>

    <input type="submit" name="action" value="Add">
</form>
<form method="get" action="currency">
    <label>Search Currency Code or Name:</label>
    <input type="text" name="search" placeholder="e.g. USD or Dollar" 
           value="<%= request.getAttribute("searchTerm") != null ? request.getAttribute("searchTerm") : "" %>">
    <input type="submit" value="Search">
    <input type="button" value="Reset" onclick="window.location.href='currency'">
</form>
<br>


<% if (currencies != null && !currencies.isEmpty()) { %>
    <table>
        <thead>
            <tr>
                <th>Currency Code</th>
                <th>Currency Name</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (Currency currency : currencies) { %>
                <tr>
                    <td><%= currency.getCode() %></td>
                    <td><%= currency.getName() %></td>
                    <td>
                        <form 
                            action="<%= isAdmin ? "currency" : "#" %>" 
                            method="post"
                            style="display:inline;"
                            onsubmit="<%= isAdmin ? "" : "showPermissionAlert(); return false;" %>">
                            
                            <input type="hidden" name="code" value="<%= currency.getCode() %>">
                            <input type="submit" name="action" value="Delete">
                        </form>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
<% } else { %>
    <p>No currencies available.</p>
<% } %>

</body>
</html>
