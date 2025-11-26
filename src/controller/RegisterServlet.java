package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.regex.Pattern;

@SuppressWarnings("serial")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username").trim();
        String email = request.getParameter("email").trim();
        String password = request.getParameter("password").trim();

        // ===== SERVER-SIDE VALIDATION =====
        String errorMsg = null;

        if (username.length() < 4 || !username.matches("^[a-zA-Z0-9_]+$")) {
            errorMsg = "Username must be at least 4 characters and contain only letters, numbers, or underscores.";
        } else if (!Pattern.matches("^[\\w.-]+@[\\w.-]+\\.[A-Za-z]{2,6}$", email)) {
            errorMsg = "Please enter a valid email address.";
        } else if (password.length() < 6 || !password.matches(".*\\d.*") || !password.matches(".*[A-Za-z].*")) {
            errorMsg = "Password must be at least 6 characters long and contain both letters and numbers.";
        } else if (userDAO.isUsernameExists(username)) {
            errorMsg = "Username already exists.";
        } else if (userDAO.isEmailExists(email)) {
            errorMsg = "Email already registered.";
        }

        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // ===== CREATE NEW USER =====
        User newUser = new User(username, email, password, "user"); // Default role
        boolean isRegistered = userDAO.registerUser(newUser);

        if (isRegistered) {
            request.setAttribute("message", "Registration successful! Please login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
