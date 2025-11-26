package controller;

import dao.CurrencyDAO;
import dao.ExchangeRateDAO;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DecimalFormat;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;


@SuppressWarnings("serial")
public class CurrencyConversionServlet extends HttpServlet {

    private CurrencyDAO currencyDAO;
    private ExchangeRateDAO exchangeRateDAO;
    private static final String API_KEY = "4f46f2e47709b38e03cc8236";

    // Context attribute key for cached iso map
    private static final String CTX_ISO_MAP_KEY = "currencyIsoMap";

    @Override
    public void init() {
        currencyDAO = new CurrencyDAO();
        exchangeRateDAO = new ExchangeRateDAO();

        // Build isoMap from DB at startup and cache in servlet context
        try {
            Map<String, String> currencies = fetchCurrenciesFromDB();
            Set<String> dbCodes = currencies != null ? currencies.keySet() : Collections.emptySet();
            Map<String, String> isoMap = buildIsoMapFromDbCodes(dbCodes);
            getServletContext().setAttribute(CTX_ISO_MAP_KEY, isoMap);
        } catch (Exception ex) {
            // fallback: build generic map without DB filter so we still have many mappings
            Map<String, String> isoMap = buildIsoMapFromDbCodes(null);
            getServletContext().setAttribute(CTX_ISO_MAP_KEY, isoMap);
        }
    }

    private Map<String, String> fetchCurrenciesFromDB() {
        return currencyDAO.getAllCurrencyMap();
    }

    /**
     * Build a currency -> ISO2 (lowercase) map using:
     *  1) Locale/Currency scanning for available locales
     *  2) Manual overrides for ambiguous or multi-country currencies
     *  3) Safe fallback for any DB codes still missing
     *
     * Returns an unmodifiable map.
     */
    private Map<String, String> buildIsoMapFromDbCodes(Set<String> dbCurrencyCodes) {
        Map<String, String> isoMap = new HashMap<>();

        // 1) Scan available Locales to populate initial mapping
        Locale[] locales = Locale.getAvailableLocales();
        for (Locale loc : locales) {
            try {
                String country = loc.getCountry();
                if (country == null || country.isEmpty()) continue;
                java.util.Currency cur = null;
                try {
                    cur = java.util.Currency.getInstance(loc);
                } catch (Exception ignore) {
                    // some locales don't have a currency
                }
                if (cur == null) continue;
                String code = cur.getCurrencyCode();
                if (code == null || code.isEmpty()) continue;

                // If dbCurrencyCodes is provided, restrict to only those codes
                if (dbCurrencyCodes != null && !dbCurrencyCodes.contains(code)) continue;

                // Don't overwrite an existing mapping (first useful locale wins)
                isoMap.putIfAbsent(code, country.toLowerCase());
            } catch (Exception e) {
                // ignore any locale-related edge cases
            }
        }

        // 2) Manual overrides for ambiguous/multi-country currencies.
        Map<String, String> overrides = new HashMap<>();
        overrides.put("USD", "us");
        overrides.put("EUR", "de");   // representative EU country (choose preferred)
        overrides.put("GBP", "gb");
        overrides.put("AUD", "au");
        overrides.put("NZD", "nz");
        overrides.put("CAD", "ca");
        overrides.put("CHF", "ch");
        overrides.put("CNY", "cn");
        overrides.put("INR", "in");
        overrides.put("JPY", "jp");
        overrides.put("SGD", "sg");
        overrides.put("HKD", "hk");
        overrides.put("KRW", "kr");
        overrides.put("BRL", "br");
        overrides.put("ZAR", "za");
        overrides.put("AED", "ae");
        overrides.put("SAR", "sa");
        overrides.put("TRY", "tr");
        overrides.put("MXN", "mx");
        overrides.put("RUB", "ru");
        overrides.put("NOK", "no");
        overrides.put("SEK", "se");
        overrides.put("DKK", "dk");
        overrides.put("PLN", "pl");
        overrides.put("IDR", "id");
        overrides.put("MYR", "my");
        overrides.put("PHP", "ph");
        overrides.put("THB", "th");
        overrides.put("VND", "vn");
        overrides.put("EGP", "eg");
        overrides.put("NGN", "ng");
        overrides.put("PKR", "pk");
        overrides.put("BDT", "bd");
        overrides.put("ILS", "il");
        overrides.put("HUF", "hu");
        overrides.put("CZK", "cz");
        overrides.put("COP", "co");
        overrides.put("CLP", "cl");
        // extend this overrides map with any other known currencies you need

        // Apply overrides (only for codes relevant or already present)
        for (Map.Entry<String, String> e : overrides.entrySet()) {
            String code = e.getKey();
            if (dbCurrencyCodes == null || dbCurrencyCodes.contains(code) || isoMap.containsKey(code)) {
                isoMap.put(code, e.getValue());
            }
        }

        // 3) For any DB currency still missing, provide a safe fallback:
        if (dbCurrencyCodes != null) {
            for (String code : dbCurrencyCodes) {
                if (isoMap.containsKey(code)) continue;
                boolean found = false;
                // second pass - try to find a matching locale
                for (Locale loc : locales) {
                    try {
                        java.util.Currency cur = java.util.Currency.getInstance(loc);
                        if (cur != null && code.equals(cur.getCurrencyCode())) {
                            String country = loc.getCountry();
                            if (country != null && !country.isEmpty()) {
                                isoMap.put(code, country.toLowerCase());
                                found = true;
                                break;
                            }
                        }
                    } catch (Exception ignore) {}
                }
                if (found) continue;
                // fallback: first two letters of currency code (not perfect, but safe)
                String fallback = (code != null && code.length() >= 2) ? code.substring(0, 2).toLowerCase() : "un";
                isoMap.put(code, fallback);
            }
        }

        return Collections.unmodifiableMap(isoMap);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Map<String, String> currencies = fetchCurrenciesFromDB();
            request.setAttribute("currencies", currencies);

            // try to read isoMap from servlet context (cached at init)
            Map<String, String> isoMap = (Map<String, String>) getServletContext().getAttribute(CTX_ISO_MAP_KEY);
            if (isoMap == null) {
                // build on the fly and cache
                Set<String> dbCodes = currencies != null ? currencies.keySet() : Collections.emptySet();
                isoMap = buildIsoMapFromDbCodes(dbCodes);
                getServletContext().setAttribute(CTX_ISO_MAP_KEY, isoMap);
            }
            request.setAttribute("isoMap", isoMap);
        } catch (Exception e) {
            request.setAttribute("error", "Could not load currencies: " + e.getMessage());
            Map<String, String> isoMap = (Map<String, String>) getServletContext().getAttribute(CTX_ISO_MAP_KEY);
            if (isoMap == null) {
                isoMap = buildIsoMapFromDbCodes(null);
                getServletContext().setAttribute(CTX_ISO_MAP_KEY, isoMap);
            }
            request.setAttribute("isoMap", isoMap);
        }

        request.getRequestDispatcher("convert.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String result = null;
        String error = null;
        Double numericResult = null;
        Double usedRate = null;
        double amount = 0.0;
        String fromCode = null;
        String toCode = null;
        DecimalFormat df = new DecimalFormat("#.##");

        try {
            String amountStr = request.getParameter("amount");
            fromCode = request.getParameter("fromCurrency");
            toCode = request.getParameter("toCurrency");

            if (amountStr == null || fromCode == null || toCode == null ||
                    amountStr.isEmpty() || fromCode.isEmpty() || toCode.isEmpty()) {
                throw new IllegalArgumentException("All fields are required.");
            }

            amount = Double.parseDouble(amountStr);

            if (fromCode.equals(toCode)) {
                numericResult = amount;
                result = df.format(amount) + " " + fromCode + " = " + df.format(numericResult) + " " + toCode;
                usedRate = 1.0;
            } else {
                Double rate = exchangeRateDAO.getRate(fromCode, toCode);

                if (rate == null) {
                    // Try indirect conversion through USD
                    Double fromToUSD = exchangeRateDAO.getRate(fromCode, "USD");
                    Double usdToTarget = exchangeRateDAO.getRate("USD", toCode);

                    if (fromToUSD != null && usdToTarget != null) {
                        double intermediateUSD = amount * fromToUSD;
                        numericResult = intermediateUSD * usdToTarget;
                        usedRate = fromToUSD * usdToTarget;
                        result = df.format(amount) + " " + fromCode + " = " + df.format(numericResult) + " " + toCode;

                    } else {
                        // External API fallback
                        String apiUrl = "https://v6.exchangerate-api.com/v6/" + API_KEY + "/latest/" + fromCode;
                        URL url = new URL(apiUrl);
                        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                        conn.setRequestMethod("GET");
                        conn.setConnectTimeout(5000);
                        conn.setReadTimeout(5000);

                        int status = conn.getResponseCode();
                        InputStream is = (status >= 200 && status < 400) ? conn.getInputStream() : conn.getErrorStream();

                        BufferedReader in = new BufferedReader(new InputStreamReader(is));
                        StringBuilder responseText = new StringBuilder();
                        String inputLine;
                        while ((inputLine = in.readLine()) != null) {
                            responseText.append(inputLine);
                        }
                        in.close();

                        JSONObject json = new JSONObject(responseText.toString());
                        if (!json.has("conversion_rates")) {
                            throw new Exception("Unexpected API response.");
                        }
                        JSONObject rates = json.getJSONObject("conversion_rates");

                        if (!rates.has(toCode)) {
                            throw new Exception("No exchange rate found between " + fromCode + " and " + toCode + ".");
                        }

                        double apiRate = rates.getDouble(toCode);
                        numericResult = amount * apiRate;
                        usedRate = apiRate;
                        result = df.format(amount) + " " + fromCode + " = " + df.format(numericResult) + " " + toCode;
                    }
                } else {
                    numericResult = amount * rate;
                    usedRate = rate;
                    result = df.format(amount) + " " + fromCode + " = " + df.format(numericResult) + " " + toCode;
                }
            }

        } catch (NumberFormatException e) {
            error = "Invalid amount. Please enter a valid number.";
        } catch (Exception e) {
            error = "Conversion failed: " + e.getMessage();
        }

        // Always load currencies for page fallback
        try {
            Map<String, String> currencies = fetchCurrenciesFromDB();
            request.setAttribute("currencies", currencies);
        } catch (Exception e) {
            request.setAttribute("error", "Currency loading failed: " + e.getMessage());
        }

        /* -----------------------------------------------------
           SESSION-BASED HISTORY (LAST 5 ITEMS)
           ----------------------------------------------------- */
        HttpSession session = request.getSession(true);

        // Timestamp format
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        String timeStamp = LocalDateTime.now().format(dtf);

        String historyEntry;
        if (result != null && error == null) {
            historyEntry = timeStamp + " — " + result;
        } else if (result != null) {
            historyEntry = timeStamp + " — " + result + " (note)";
        } else {
            historyEntry = timeStamp + " — Conversion failed: " + (error != null ? error : "Unknown error");
        }

        @SuppressWarnings("unchecked")
        List<String> history = (List<String>) session.getAttribute("conversionHistory");
        if (history == null) {
            history = new LinkedList<>();
        }

        // Add latest at top
        history.add(0, historyEntry);

        // Trim to last 5
        while (history.size() > 5) {
            history.remove(history.size() - 1);
        }

        session.setAttribute("conversionHistory", history);


        /* -----------------------------------------------------
           ENSURE FLAG ISO MAP AVAILABLE
           ----------------------------------------------------- */
        Map<String, String> isoMap =
                (Map<String, String>) getServletContext().getAttribute(CTX_ISO_MAP_KEY);

        if (isoMap == null) {
            try {
                Map<String, String> currencies = fetchCurrenciesFromDB();
                Set<String> dbCodes = currencies != null ? currencies.keySet() : Collections.emptySet();
                isoMap = buildIsoMapFromDbCodes(dbCodes);
                getServletContext().setAttribute(CTX_ISO_MAP_KEY, isoMap);
            } catch (Exception ex) {
                isoMap = buildIsoMapFromDbCodes(null);
                getServletContext().setAttribute(CTX_ISO_MAP_KEY, isoMap);
            }
        }

        request.setAttribute("isoMap", isoMap);


        /* -----------------------------------------------------
           NON-AJAX FALLBACK → forward to JSP
           ----------------------------------------------------- */
        request.setAttribute("result", result);
        request.setAttribute("amount", amount);
        request.setAttribute("selectedFrom", fromCode);
        request.setAttribute("selectedTo", toCode);
        request.setAttribute("error", error);
        request.setAttribute("currentPage", "convert");

        request.getRequestDispatcher("convert.jsp").forward(request, response);
    }

}
