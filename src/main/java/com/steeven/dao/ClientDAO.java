package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClientDAO {

    // CREATE
    public boolean createClient(String numtel, String nom, String sexe, int age, int solde, String mail, String code) {
        String query = "INSERT INTO CLIENT (numtel, nom, sexe, age, solde, mail, code_secret) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numtel);
            ps.setString(2, nom);
            ps.setString(3, sexe);
            ps.setInt(4, age);
            ps.setInt(5, solde);
            ps.setString(6, mail);
            ps.setString(7, code);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // READ
    public List<String[]> getAllClients() {
        List<String[]> clients = new ArrayList<>();
        String query = "SELECT * FROM CLIENT";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            while (rs.next()) {
                clients.add(new String[]{
                    rs.getString("numtel"), rs.getString("nom"), rs.getString("sexe"),
                    String.valueOf(rs.getInt("age")), String.valueOf(rs.getInt("solde")),
                    rs.getString("mail"), rs.getString("code_secret")
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return clients;
    }

    // UPDATE 
    public boolean updateClient(String numtel, String nom, String sexe, int age, int solde, String mail) {
        String query = "UPDATE CLIENT SET nom=?, sexe=?, age=?, solde=?, mail=? WHERE numtel=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, nom);
            ps.setString(2, sexe);
            ps.setInt(3, age);
            ps.setInt(4, solde);
            ps.setString(5, mail);
            ps.setString(6, numtel);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }
    public boolean verifyCredentials(String numtel, String codeSecret) {
    String query = "SELECT * FROM CLIENT WHERE numtel = ? AND code_secret = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, numtel);
        ps.setString(2, codeSecret);
        ResultSet rs = ps.executeQuery();
        
        return rs.next(); 
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

    // DELETE
    public boolean deleteClient(String numtel) {
        String query = "DELETE FROM CLIENT WHERE numtel = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numtel);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    //Supprime l'historique lié au client puis le compte (transaction).
     
    public boolean deleteClientCascade(String numtel) {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM ENVOI WHERE numEnvoyeur = ? OR numRecepteur = ?")) {
                    ps.setString(1, numtel);
                    ps.setString(2, numtel);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM RETRAIT WHERE numtel = ?")) {
                    ps.setString(1, numtel);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM CLIENT WHERE numtel = ?")) {
                    ps.setString(1, numtel);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
                e.printStackTrace();
                return false;
            } finally {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean changeCodeSecret(String numtel, String ancienCode, String nouveauCode) {
        if (nouveauCode == null || !nouveauCode.matches("[0-9]{4}")) {
            return false;
        }
        if (!verifyCredentials(numtel, ancienCode)) {
            return false;
        }
        String query = "UPDATE CLIENT SET code_secret = ? WHERE numtel = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, nouveauCode);
            ps.setString(2, numtel);
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean creditSolde(String numtel, int montant) {
        if (numtel == null || numtel.trim().isEmpty() || montant <= 0) {
            return false;
        }
        String query = "UPDATE CLIENT SET solde = solde + ? WHERE numtel = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, montant);
            ps.setString(2, numtel.trim());
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<String[]> searchClients(String keyword) {
    List<String[]> clients = new ArrayList<>();
    String query = "SELECT * FROM CLIENT WHERE nom LIKE ? OR numtel LIKE ? ORDER BY nom";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        String searchPattern = "%" + keyword + "%";
        ps.setString(1, searchPattern);
        ps.setString(2, searchPattern);
        
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            clients.add(new String[]{
                rs.getString("numtel"), 
                rs.getString("nom"), 
                rs.getString("sexe"),
                String.valueOf(rs.getInt("age")), 
                String.valueOf(rs.getInt("solde")),
                rs.getString("mail"), 
                rs.getString("code_secret")
            });
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return clients;
}

    public String[] getClientByNumtel(String numtel) {
        String query = "SELECT * FROM CLIENT WHERE numtel = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numtel);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new String[]{
                    rs.getString("numtel"),
                    rs.getString("nom"),
                    rs.getString("sexe"),
                    String.valueOf(rs.getInt("age")),
                    String.valueOf(rs.getInt("solde")),
                    rs.getString("mail"),
                    rs.getString("code_secret")
                };
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}