package controller;

import dao.CurrencyDAO;
import model.Currency;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@SuppressWarnings("serial")
public class CurrencyServlet extends HttpServlet {

    private CurrencyDAO currencyDAO;

    @Override
    public void init() throws ServletException {
        currencyDAO = new CurrencyDAO(); // Instantiate DAO once during servlet init
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String status = "";

        System.out.println("Received POST action: " + action);

        if ("add".equalsIgnoreCase(action)) {
            String code = request.getParameter("code");
            String name = request.getParameter("name");

            if (code != null && name != null && !code.isEmpty() && !name.isEmpty()) {
                Currency currency = new Currency(code.trim().toUpperCase(), name.trim());
                try {
                    currencyDAO.addCurrency(currency);
                    System.out.println("Currency added: " + code + " - " + name);
                    status = "success";
                    HttpSession session = request.getSession();
                    session.setAttribute("popupMessage", "Currency added successfully!");

                } catch (SQLException e) {
                	if (e.getMessage().contains("Duplicate entry")) {
                        status = "duplicate";
                        HttpSession session = request.getSession();
                        session.setAttribute("popupMessage", "Duplicate Entries Found!");
                    } else {
                        status = "dberror"; // optional fallback
                    }
                    System.out.println("Add failed due to internal Error In Database please try after sometime ");
                }
            } else {
                System.out.println("Add action skipped - Missing code or name.");
                status = "invalid";
            }

        } else if ("delete".equalsIgnoreCase(action)) {
            String code = request.getParameter("code");

            if (code != null && !code.isEmpty()) {
                try {
                    boolean deleted = currencyDAO.deleteCurrency(code.trim().toUpperCase());
                    HttpSession session = request.getSession();

                    if (deleted) {
                        System.out.println("Currency deleted from DB: " + code);
                        status = "deleted";
                        session.setAttribute("popupMessage", "Currency deleted successfully");
                    } else {
                        System.out.println("No currency found with code: " + code);
                        status = "notfound";
                        session.setAttribute("popupMessage", "No currency found with code");
                    }

                } catch (Exception e) {
                    System.out.println("❌ Delete failed: " + e.getMessage());
                    status = "deletefail";
                    HttpSession session = request.getSession();
                    session.setAttribute("popupMessage", "Deletion Failed: check ManageExchange rates if the currency is mapped to any currency.");
                }
            }else {
                System.out.println("Delete action skipped - Missing code.");
                status = "invalid";
            }
        }

        // Redirect to GET with status
        response.sendRedirect(request.getContextPath() + "/currency?status=" + status);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        List<Currency> currencies;

        if (search != null && !search.trim().isEmpty()) {
            currencies = currencyDAO.searchCurrencies(search.trim());
        } else {
            currencies = currencyDAO.getAllCurrencies();
        }

        request.setAttribute("currencies", currencies);
        request.setAttribute("searchTerm", search != null ? search.trim() : "");

        RequestDispatcher dispatcher = request.getRequestDispatcher("manageCurrencies.jsp");
        dispatcher.forward(request, response);
    }

}
