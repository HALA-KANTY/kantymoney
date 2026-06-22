package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EnvoiDAO {

    // CREATE 
    public boolean ajouterEnvoi(String numEnv, String numRec, int montant, boolean payerFrais, String raison) {
        String query = "INSERT INTO ENVOI (numEnvoyeur, numRecepteur, montant, date, payer_frais_retrait, raison) VALUES (?, ?, ?, NOW(), ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, numEnv);
            ps.setString(2, numRec);
            ps.setInt(3, montant);
            ps.setBoolean(4, payerFrais);
            ps.setString(5, raison);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean ajouterEnvoi(Connection conn, String numEnv, String numRec, int montant, boolean payerFrais, String raison) throws SQLException {
        String query = "INSERT INTO ENVOI (numEnvoyeur, numRecepteur, montant, date, payer_frais_retrait, raison) VALUES (?, ?, ?, NOW(), ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numEnv);
            ps.setString(2, numRec);
            ps.setInt(3, montant);
            ps.setBoolean(4, payerFrais);
            ps.setString(5, raison);
            return ps.executeUpdate() > 0;
        }
    }

    public String ajouterEnvoiEtRetourIdEnv(Connection conn, String numEnv, String numRec, int montant, boolean payerFrais, String raison) throws SQLException {
        String query = "INSERT INTO ENVOI (numEnvoyeur, numRecepteur, montant, date, payer_frais_retrait, raison) VALUES (?, ?, ?, NOW(), ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, numEnv);
            ps.setString(2, numRec);
            ps.setInt(3, montant);
            ps.setBoolean(4, payerFrais);
            ps.setString(5, raison);
            int affected = ps.executeUpdate();
            if (affected != 1) {
                return null;
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    return null;
                }
                int id = keys.getInt(1);
                try (PreparedStatement ps2 = conn.prepareStatement("SELECT idEnv FROM ENVOI WHERE id = ?")) {
                    ps2.setInt(1, id);
                    try (ResultSet rs = ps2.executeQuery()) {
                        if (rs.next()) {
                            return rs.getString("idEnv");
                        }
                    }
                }
            }
        }
        return null;
    }

    // READ 
    public List<String[]> getAllEnvois() {
        List<String[]> envois = new ArrayList<>();
        String query = "SELECT * FROM ENVOI ORDER BY date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            
            while (rs.next()) {
                envois.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idEnv"), 
                    rs.getString("numEnvoyeur"),
                    rs.getString("numRecepteur"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("date"),
                    String.valueOf(rs.getBoolean("payer_frais_retrait")),
                    rs.getString("raison")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return envois;
    }

    // DELETE 
    public boolean deleteEnvoi(int id) {
        String query = "DELETE FROM ENVOI WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // SEARCH 
    public List<String[]> searchEnvois(String keyword) {
        List<String[]> envois = new ArrayList<>();
        String query = "SELECT * FROM ENVOI WHERE numEnvoyeur LIKE ? OR idEnv LIKE ? ORDER BY date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                envois.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idEnv"),
                    rs.getString("numEnvoyeur"),
                    rs.getString("numRecepteur"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("date"),
                    String.valueOf(rs.getBoolean("payer_frais_retrait")),
                    rs.getString("raison")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return envois;
    }

    public List<String[]> getEnvoisByEnvoyeur(String numEnvoyeur) {
        return getEnvoisByEnvoyeur(numEnvoyeur, null);
    }

  
    public List<String[]> getEnvoisByEnvoyeur(String numEnvoyeur, String dateYmd) {
        List<String[]> envois = new ArrayList<>();
        StringBuilder query = new StringBuilder("SELECT * FROM ENVOI WHERE numEnvoyeur = ?");
        List<Object> params = new ArrayList<>();
        params.add(numEnvoyeur);
        appendEnvoiSingleDay(query, params, dateYmd);
        query.append(" ORDER BY `date` DESC");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object o = params.get(i);
                if (o instanceof java.sql.Date) {
                    ps.setDate(i + 1, (java.sql.Date) o);
                } else {
                    ps.setString(i + 1, o != null ? o.toString() : null);
                }
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                envois.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idEnv"),
                    rs.getString("numEnvoyeur"),
                    rs.getString("numRecepteur"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("date"),
                    String.valueOf(rs.getBoolean("payer_frais_retrait")),
                    rs.getString("raison")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return envois;
    }

    private static void appendEnvoiSingleDay(StringBuilder sql, List<Object> params, String dateYmd) {
        java.sql.Date d = parseDateOrNull(dateYmd);
        if (d == null) {
            return;
        }
        sql.append(" AND DATE(`date`) = ? ");
        params.add(d);
    }

    private static java.sql.Date parseDateOrNull(String ymd) {
        if (ymd == null || ymd.isBlank()) {
            return null;
        }
        try {
            return java.sql.Date.valueOf(ymd.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    public String[] getEnvoiByIdAndEnvoyeur(int id, String numEnvoyeur) {
        String query = "SELECT * FROM ENVOI WHERE id = ? AND numEnvoyeur = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, id);
            ps.setString(2, numEnvoyeur);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idEnv"),
                    rs.getString("numEnvoyeur"),
                    rs.getString("numRecepteur"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("date"),
                    String.valueOf(rs.getBoolean("payer_frais_retrait")),
                    rs.getString("raison")
                };
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateEnvoiByIdAndEnvoyeur(int id, String numEnvoyeur, boolean payerFraisRetrait, String raison) {
        String query = "UPDATE ENVOI SET payer_frais_retrait = ?, raison = ? WHERE id = ? AND numEnvoyeur = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setBoolean(1, payerFraisRetrait);
            ps.setString(2, raison);
            ps.setInt(3, id);
            ps.setString(4, numEnvoyeur);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteEnvoiByIdAndEnvoyeur(int id, String numEnvoyeur) {
        String query = "DELETE FROM ENVOI WHERE id = ? AND numEnvoyeur = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, id);
            ps.setString(2, numEnvoyeur);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}