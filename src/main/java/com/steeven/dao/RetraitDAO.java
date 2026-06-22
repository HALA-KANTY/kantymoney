package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RetraitDAO {

    // 🔹 CREATE : Ajouter un retrait
    public boolean ajouterRetrait(String numtel, int montant) {
        String query = "INSERT INTO RETRAIT (numtel, montant, daterecep) VALUES (?, ?, NOW())";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, numtel);
            ps.setInt(2, montant);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 CREATE avec connexion externe (transaction)
    public boolean ajouterRetrait(Connection conn, String numtel, int montant) throws SQLException {
        String query = "INSERT INTO RETRAIT (numtel, montant, daterecep) VALUES (?, ?, NOW())";
        
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numtel);
            ps.setInt(2, montant);
            return ps.executeUpdate() > 0;
        }
    }

    public String ajouterRetraitEtRetourIdRecep(Connection conn, String numtel, int montant) throws SQLException {
        String query = "INSERT INTO RETRAIT (numtel, montant, daterecep) VALUES (?, ?, NOW())";
        try (PreparedStatement ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, numtel);
            ps.setInt(2, montant);
            int affected = ps.executeUpdate();
            if (affected != 1) {
                return null;
            }
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    return null;
                }
                int id = keys.getInt(1);
                try (PreparedStatement ps2 = conn.prepareStatement("SELECT idrecep FROM RETRAIT WHERE id = ?")) {
                    ps2.setInt(1, id);
                    try (ResultSet rs = ps2.executeQuery()) {
                        if (rs.next()) {
                            return rs.getString("idrecep");
                        }
                    }
                }
            }
        }
        return null;
    }

    // 🔹 READ : Lister tous les retraits
    public List<String[]> getAllRetraits() {
        List<String[]> retraits = new ArrayList<>();
        String query = "SELECT * FROM RETRAIT ORDER BY daterecep DESC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            
            while (rs.next()) {
                retraits.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idrecep"), // RET-N-0001 généré automatiquement
                    rs.getString("numtel"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("daterecep")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return retraits;
    }

    //  DELETE : Supprimer un retrait
    public boolean deleteRetrait(int id) {
        String query = "DELETE FROM RETRAIT WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // SEARCH : Rechercher par numéro ou ID RET-N-xxxx
    public List<String[]> searchRetraits(String keyword) {
        List<String[]> retraits = new ArrayList<>();
        String query = "SELECT * FROM RETRAIT WHERE numtel LIKE ? OR idrecep LIKE ? ORDER BY daterecep DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            String pattern = "%" + keyword + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                retraits.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idrecep"),
                    rs.getString("numtel"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("daterecep")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return retraits;
    }

    //  Filtrer par numéro
    public List<String[]> getRetraitsByNumtel(String numtel) {
        return getRetraitsByNumtel(numtel, null);
    }

    public List<String[]> getRetraitsByNumtel(String numtel, String dateYmd) {
        List<String[]> retraits = new ArrayList<>();
        StringBuilder query = new StringBuilder("SELECT * FROM RETRAIT WHERE numtel = ?");
        List<Object> params = new ArrayList<>();
        params.add(numtel);
        appendRetraitSingleDay(query, params, dateYmd);
        query.append(" ORDER BY daterecep DESC");
        
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
                retraits.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idrecep"),
                    rs.getString("numtel"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("daterecep")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return retraits;
    }

    private static void appendRetraitSingleDay(StringBuilder sql, List<Object> params, String dateYmd) {
        java.sql.Date d = parseDateOrNull(dateYmd);
        if (d == null) {
            return;
        }
        sql.append(" AND DATE(daterecep) = ? ");
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

    //  READ 
    public String[] getRetraitByIdAndNumtel(int id, String numtel) {
        String query = "SELECT * FROM RETRAIT WHERE id = ? AND numtel = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setInt(1, id);
            ps.setString(2, numtel);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("idrecep"),
                    rs.getString("numtel"),
                    String.valueOf(rs.getInt("montant")),
                    rs.getString("daterecep")
                };
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}