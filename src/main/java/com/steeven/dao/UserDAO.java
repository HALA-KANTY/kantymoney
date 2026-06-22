package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Méthode pour ajouter un utilisateur
    public boolean registerUser(String nom, String email, String password) {
        String query = "INSERT INTO users (nom, email, password) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, nom);
            ps.setString(2, email);
            ps.setString(3, password);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Méthode pour récupérer la liste de tous les utilisateurs
    public List<String[]> getAllUsers() {
        List<String[]> users = new ArrayList<>();
        String query = "SELECT nom, email FROM users ORDER BY id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
               
                users.add(new String[]{rs.getString("nom"), rs.getString("email")});
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }
  
// SUPPRIMER (DELETE)
public boolean deleteUser(String email) {
    String query = "DELETE FROM users WHERE email = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, email);
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

// METTRE À JOUR (UPDATE)
public boolean updateUser(String nom, String email) {
    String query = "UPDATE users SET nom = ? WHERE email = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, nom);
        ps.setString(2, email); 
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}
}