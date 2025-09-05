package dao;

import model.Currency;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class CurrencyDAO {

    // Fetch all currencies from DB
    public List<Currency> getAllCurrencies() {
        List<Currency> currencies = new ArrayList<>();
        String query = "SELECT * FROM currencies";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                currencies.add(new Currency(rs.getString("code"), rs.getString("name")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return currencies;
    }

    // Add a single currency
    public void addCurrency(Currency currency) throws SQLException {
        String sql = "INSERT INTO currencies (code, name) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, currency.getCode());
            stmt.setString(2, currency.getName());
            stmt.executeUpdate();

        } catch (SQLException e) {
            // Log and rethrow so the Servlet knows about the failure
            System.out.println("CurrencyDAO Error: " + e.getMessage());
            throw e;
        }
    }


    // Delete a currency by code
    public boolean deleteCurrency(String code) throws SQLException {
        String query = "DELETE FROM currencies WHERE code = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, code);
            int rowsAffected = ps.executeUpdate();

            return rowsAffected > 0; // true if something was deleted
        }
    }

    public Map<String, String> getAllCurrencyMap() {
        Map<String, String> currencyMap = new LinkedHashMap<>();
        String sql = "SELECT code, name FROM currencies ORDER BY code";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                currencyMap.put(rs.getString("code"), rs.getString("name"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return currencyMap;
    }

    
    public void saveCurrenciesFromAPI(Map<String, String> currenciesMap) {
        String query = "INSERT INTO currencies (code, name) VALUES (?, ?) " +
                       "ON DUPLICATE KEY UPDATE name = VALUES(name)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            for (Map.Entry<String, String> entry : currenciesMap.entrySet()) {
                ps.setString(1, entry.getKey());
                ps.setString(2, entry.getValue());
                ps.addBatch();
            }

            ps.executeBatch();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    
    public List<String> getAllCurrencyCodes() {
        List<String> codes = new ArrayList<>();
        String query = "SELECT code FROM currencies ORDER BY code";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                codes.add(rs.getString("code"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return codes;
    }
    
 // Save exchange rates fetched from API into DB
    public void saveExchangeRatesFromAPI(String baseCurrency, Map<String, Double> ratesMap) {
        String deleteSQL = "DELETE FROM exchange_rates WHERE from_currency = ?";
        String insertSQL = "INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement deleteStmt = conn.prepareStatement(deleteSQL);
             PreparedStatement insertStmt = conn.prepareStatement(insertSQL)) {

            // Delete old exchange rates for this base currency
            deleteStmt.setString(1, baseCurrency);
            deleteStmt.executeUpdate();

            // Insert new exchange rates
            for (Map.Entry<String, Double> entry : ratesMap.entrySet()) {
                insertStmt.setString(1, baseCurrency);
                insertStmt.setString(2, entry.getKey());
                insertStmt.setDouble(3, entry.getValue());
                insertStmt.addBatch();
            }

            insertStmt.executeBatch();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    public List<Currency> searchCurrencies(String searchTerm) {
        List<Currency> list = new ArrayList<>();
        String sql = "SELECT code, name FROM currencies WHERE code LIKE ? OR name LIKE ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            String searchPattern = "%" + searchTerm + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String code = rs.getString("code");
                    String name = rs.getString("name");
                    list.add(new Currency(code, name));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }


}
