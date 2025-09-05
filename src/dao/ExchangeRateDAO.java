package dao;

import model.Currency;
import model.ExchangeRate;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExchangeRateDAO {

    // Insert or update exchange rate
    public void updateRate(ExchangeRate rate) {
        String query = "INSERT INTO exchange_rates (from_currency, to_currency, rate) " +
                       "VALUES (?, ?, ?) " +
                       "ON DUPLICATE KEY UPDATE rate = VALUES(rate)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

        	ps.setString(1, rate.getFromCurrency().getCode());
        	ps.setString(2, rate.getToCurrency().getCode());

            ps.setDouble(3, rate.getRate());
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Get exchange rate between two currencies
    public Double getRate(String from, String to) {
        Double rate = null;
        String query = "SELECT rate FROM exchange_rates WHERE from_currency = ? AND to_currency = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, from);
            ps.setString(2, to);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                rate = rs.getDouble("rate");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return rate;
    }

	public List<ExchangeRate> getAllExchangeRates() {
		List<ExchangeRate> rates = new ArrayList<>();
	    String sql = "SELECT from_currency, to_currency, rate FROM exchange_rates";

	    try (Connection conn = DBConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql);
	         ResultSet rs = stmt.executeQuery()) {

	        while (rs.next()) {
	            String fromCode = rs.getString("from_currency");
	            String toCode = rs.getString("to_currency");
	            double rate = rs.getDouble("rate");

	            Currency from = new Currency(fromCode, "");
	            Currency to = new Currency(toCode, "");

	            rates.add(new ExchangeRate(from, to, rate));
	        }

	    } catch (SQLException e) {
	        e.printStackTrace();
	    }

	    return rates;
	}
	
	public void addExchangeRate(ExchangeRate exRate) throws SQLException {
	    String sql = "INSERT INTO exchange_rates (from_currency, to_currency, rate) VALUES (?, ?, ?)";

	    try (Connection conn = DBConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {

	        stmt.setString(1, exRate.getFromCurrency().getCode());
	        stmt.setString(2, exRate.getToCurrency().getCode());
	        stmt.setDouble(3, exRate.getRate());
	        stmt.executeUpdate();

	    } // Don't catch here — let it throw to the servlet
	}


	public void deleteExchangeRate(String fromCode, String toCode) {
	    String sql = "DELETE FROM exchange_rates WHERE from_currency = ? AND to_currency = ?";

	    try (Connection conn = DBConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {

	        stmt.setString(1, fromCode);
	        stmt.setString(2, toCode);
	        stmt.executeUpdate();

	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	}
	public List<ExchangeRate> searchExchangeRates(String code) {
	    List<ExchangeRate> list = new ArrayList<>();
	    String sql = "SELECT from_currency, to_currency, rate FROM exchange_rates WHERE from_currency = ? OR to_currency = ?";
	    
	    try (Connection conn = DBConnection.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {

	        stmt.setString(1, code);
	        stmt.setString(2, code);
	        try (ResultSet rs = stmt.executeQuery()) {
	            while (rs.next()) {
	                String fromCode = rs.getString("from_currency");
	                String toCode = rs.getString("to_currency");
	                double rate = rs.getDouble("rate");

	                Currency from = new Currency(fromCode, "");
	                Currency to = new Currency(toCode, "");
	                list.add(new ExchangeRate(from, to, rate));
	            }
	        }
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    return list;
	}

	
 
}

