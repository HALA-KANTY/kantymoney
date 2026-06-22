package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OperateurDAO {

    // CREATE
    public boolean createOperateur(String numtel, String nom, String mail, String mdp) {
        String query = "INSERT INTO OPERATEUR (numtel, nom, mail, mot_de_passe) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numtel);
            ps.setString(2, nom);
            ps.setString(3, mail);
            ps.setString(4, mdp);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ ALL
    public List<String[]> getAllOperateurs() {
        List<String[]> list = new ArrayList<>();
        String query = "SELECT numtel, nom, mail FROM OPERATEUR";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            while (rs.next()) {
                list.add(new String[]{
                    rs.getString("numtel"), 
                    rs.getString("nom"), 
                    rs.getString("mail")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // UPDATE
    public boolean updateOperateur(String numtel, String nom, String mail) {
        String query = "UPDATE OPERATEUR SET nom = ?, mail = ? WHERE numtel = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, nom);
            ps.setString(2, mail);
            ps.setString(3, numtel);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE
    public boolean deleteOperateur(String numtel) {
        String query = "DELETE FROM OPERATEUR WHERE numtel = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, numtel);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    // Vérifier les credentials de l'opérateur
public boolean verifyCredentials(String mail, String motDePasse) {
    String query = "SELECT * FROM OPERATEUR WHERE mail = ? AND mot_de_passe = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, mail);
        ps.setString(2, motDePasse);
        ResultSet rs = ps.executeQuery();
        
        return rs.next(); 
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

// Récupérer un opérateur par son email
public String[] getOperateurByMail(String mail) {
    String query = "SELECT numtel, nom, mail FROM OPERATEUR WHERE mail = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        
        ps.setString(1, mail);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return new String[]{
                rs.getString("numtel"),
                rs.getString("nom"),
                rs.getString("mail")
            };
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}
}