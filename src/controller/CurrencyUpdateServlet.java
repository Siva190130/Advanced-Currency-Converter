package controller;

import dao.CurrencyDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import org.json.JSONObject;

public class CurrencyUpdateServlet extends HttpServlet {

    private CurrencyDAO currencyDAO;
    private static final String API_KEY = "4f46f2e47709b38e03cc8236";

    @Override
    public void init() {
        currencyDAO = new CurrencyDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            URL currencyUrl = new URL("https://v6.exchangerate-api.com/v6/" + API_KEY + "/codes");
            HttpURLConnection currencyConn = (HttpURLConnection) currencyUrl.openConnection();
            currencyConn.setRequestMethod("GET");

            BufferedReader currencyReader = new BufferedReader(new InputStreamReader(currencyConn.getInputStream()));
            StringBuilder currencyJsonBuilder = new StringBuilder();
            String line;
            while ((line = currencyReader.readLine()) != null) {
                currencyJsonBuilder.append(line);
            }

            JSONObject currencyJson = new JSONObject(currencyJsonBuilder.toString());
            Map<String, String> currencyMap = new HashMap<>();

            if (currencyJson.has("supported_codes")) {
                for (Object item : currencyJson.getJSONArray("supported_codes")) {
                    if (item instanceof org.json.JSONArray) {
                        org.json.JSONArray arr = (org.json.JSONArray) item;
                        String code = arr.getString(0);
                        String name = arr.getString(1);
                        currencyMap.put(code, name);
                    }
                }
            }

            currencyDAO.saveCurrenciesFromAPI(currencyMap);

            URL ratesUrl = new URL("https://v6.exchangerate-api.com/v6/" + API_KEY + "/latest/USD");
            HttpURLConnection ratesConn = (HttpURLConnection) ratesUrl.openConnection();
            ratesConn.setRequestMethod("GET");

            BufferedReader ratesReader = new BufferedReader(new InputStreamReader(ratesConn.getInputStream()));
            StringBuilder ratesJsonBuilder = new StringBuilder();
            while ((line = ratesReader.readLine()) != null) {
                ratesJsonBuilder.append(line);
            }

            JSONObject ratesJson = new JSONObject(ratesJsonBuilder.toString());
            JSONObject rates = ratesJson.getJSONObject("conversion_rates");

            Map<String, Double> rateMap = new HashMap<>();
            for (String key : rates.keySet()) {
                rateMap.put(key, rates.getDouble(key));
            }

            currencyDAO.saveExchangeRatesFromAPI("USD", rateMap);

            request.setAttribute("message", "Currencies and exchange rates updated successfully!");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Update failed: " + e.getMessage());
        }

        request.getRequestDispatcher("convert").forward(request, response);
    }
}
