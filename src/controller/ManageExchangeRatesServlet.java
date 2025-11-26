package controller;

import dao.CurrencyDAO;
import dao.ExchangeRateDAO;
import model.Currency;
import model.ExchangeRate;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@SuppressWarnings("serial")
public class ManageExchangeRatesServlet extends HttpServlet {
    private ExchangeRateDAO exchangeRateDAO;
    private CurrencyDAO currencyDAO;

    public void init() {
        exchangeRateDAO = new ExchangeRateDAO();
        currencyDAO = new CurrencyDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        List<ExchangeRate> rates;
        if (search != null && !search.trim().isEmpty()) {
            rates = exchangeRateDAO.searchExchangeRates(search.trim().toUpperCase());
        } else {
            rates = exchangeRateDAO.getAllExchangeRates();
        }

        List<Currency> currencies = currencyDAO.getAllCurrencies();

        request.setAttribute("exchangeRates", rates);
        request.setAttribute("currencies", currencies);
        request.setAttribute("searchTerm", search != null ? search.trim().toUpperCase() : "");

        RequestDispatcher dispatcher = request.getRequestDispatcher("manageExchangeRates.jsp");
        dispatcher.forward(request, response);
    }


    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (!"admin".equalsIgnoreCase(role)) {
            request.setAttribute("successMessage", "You need admin privileges to modify exchange rates.");
            doGet(request, response);
            return;
        }

        String action = request.getParameter("action");
        String message = "";

        if ("add".equalsIgnoreCase(action)) {
            String fromCode = request.getParameter("from");
            String toCode = request.getParameter("to");
            double rate = Double.parseDouble(request.getParameter("rate"));

            Currency fromCurrency = new Currency(fromCode, "");
            Currency toCurrency = new Currency(toCode, "");
            ExchangeRate exRate = new ExchangeRate(fromCurrency, toCurrency, rate);

            try {
                exchangeRateDAO.addExchangeRate(exRate);
                request.setAttribute("popupMessage", "Exchange rate added successfully!");
            } catch (SQLException e) {
                if (e.getMessage().contains("Duplicate entry")) {
                    message = "Exchange rate already exists!";
                } else {
                    message = "You Must Currency codes in manage Currencies inorder to add exchange rates.";
                }
                e.printStackTrace();
            }
        }
        
        else if ("delete".equalsIgnoreCase(action)) {
            String fromCode = request.getParameter("from");
            String toCode = request.getParameter("to");

            try {
                exchangeRateDAO.deleteExchangeRate(fromCode, toCode);
                request.setAttribute("popupMessage", "Exchange rate deleted successfully!");
            } catch (Exception e) {
                message = "Error while deleting exchange rate.";
                e.printStackTrace();
            }
        }


        List<ExchangeRate> updatedRates = exchangeRateDAO.getAllExchangeRates();
        List<Currency> currencies = currencyDAO.getAllCurrencies();

        request.setAttribute("exchangeRates", updatedRates);
        request.setAttribute("currencies", currencies);
        request.setAttribute("successMessage", message);
        request.setAttribute("currentPage", "exchangeRate");
        RequestDispatcher dispatcher = request.getRequestDispatcher("manageExchangeRates.jsp");
        dispatcher.forward(request, response);
    }
}
