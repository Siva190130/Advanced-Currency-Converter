package controller;

import dao.CurrencyDAO;
import dao.ExchangeRateDAO;
import model.ExchangeRate;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DecimalFormat;
import java.util.Map;


public class CurrencyConversionServlet extends HttpServlet {

    private CurrencyDAO currencyDAO;
    private ExchangeRateDAO exchangeRateDAO;
    private static final String API_KEY = "4f46f2e47709b38e03cc8236";

    @Override
    public void init() {
        currencyDAO = new CurrencyDAO();
        exchangeRateDAO = new ExchangeRateDAO();
    }

    private Map<String, String> fetchCurrenciesFromDB() {
        return currencyDAO.getAllCurrencyMap();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Map<String, String> currencies = fetchCurrenciesFromDB();
            request.setAttribute("currencies", currencies);
        } catch (Exception e) {
            request.setAttribute("error", "Could not load currencies: " + e.getMessage());
        }

        request.getRequestDispatcher("convert.jsp").forward(request, response);
    }

   
	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String result = null;
        String error = null;

        try {
            String amountStr = request.getParameter("amount");
            String fromCode = request.getParameter("fromCurrency");
            String toCode = request.getParameter("toCurrency");

            if (amountStr == null || fromCode == null || toCode == null ||
                    amountStr.isEmpty() || fromCode.isEmpty() || toCode.isEmpty()) {
                throw new IllegalArgumentException("All fields are required.");
            }

            double amount = Double.parseDouble(amountStr);
            DecimalFormat df = new DecimalFormat("#.##");

            if (fromCode.equals(toCode)) {
                result = df.format(amount) + " " + fromCode + " = " + df.format(amount) + " " + toCode;
            } else {
                Double rate = exchangeRateDAO.getRate(fromCode, toCode);

                if (rate == null) {
                    // Attempt indirect conversion via USD
                    Double fromToUSD = exchangeRateDAO.getRate(fromCode, "USD");
                    Double usdToTarget = exchangeRateDAO.getRate("USD", toCode);

                    if (fromToUSD != null && usdToTarget != null) {
                        // fromCode  USD  toCode
                        double intermediateUSD = amount * fromToUSD;
                        double convertedAmount = intermediateUSD * usdToTarget;
                        result = df.format(amount) + " " + fromCode + " = " + df.format(convertedAmount) + " " + toCode;
                    } else {
                        // Final fallback: API call
                        String apiUrl = "https://v6.exchangerate-api.com/v6/" + API_KEY + "/latest/" + fromCode;
                        URL url = new URL(apiUrl);
                        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                        conn.setRequestMethod("GET");

                        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                        StringBuilder responseText = new StringBuilder();
                        String inputLine;
                        while ((inputLine = in.readLine()) != null) {
                            responseText.append(inputLine);
                        }
                        in.close();

                        JSONObject json = new JSONObject(responseText.toString());
                        JSONObject rates = json.getJSONObject("conversion_rates");

                        if (!rates.has(toCode)) {
                            throw new Exception("No exchange rate found between " + fromCode + " and " + toCode + ".");
                        }

                        double apiRate = rates.getDouble(toCode);
                        double convertedAmount = amount * apiRate;
                        result = df.format(amount) + " " + fromCode + " = " + df.format(convertedAmount) + " " + toCode;
                    }
                } else {
                    double convertedAmount = amount * rate;
                    result = df.format(amount) + " " + fromCode + " = " + df.format(convertedAmount) + " " + toCode;
                }
            }

        } catch (NumberFormatException e) {
            error = "Invalid amount. Please enter a valid number.";
        } catch (Exception e) {
            error = "Conversion failed: " + e.getMessage();
        }

        try {
            Map<String, String> currencies = fetchCurrenciesFromDB();
            request.setAttribute("currencies", currencies);
        } catch (Exception e) {
            request.setAttribute("error", "Currency loading failed: " + e.getMessage());
        }

        request.setAttribute("result", result);
        request.setAttribute("error", error);
        request.setAttribute("currentPage", "convert");
        request.getRequestDispatcher("convert.jsp").forward(request, response);
    }
}
