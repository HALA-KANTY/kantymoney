package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FraisEnvoiDAO {

    // CREATE (Ajouter une tranche de frais) 
    public boolean createFrais(int m1, int m2, int frais) {
        String query = "INSERT INTO FRAIS_ENVOI (montant1, montant2, frais_env) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, m1);
            ps.setInt(2, m2);
            ps.setInt(3, frais);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ (Récupérer toutes les tranches)
    public List<String[]> getAllFrais() {
        List<String[]> list = new ArrayList<>();
        String query = "SELECT idEnv, montant1, montant2, frais_env FROM FRAIS_ENVOI ORDER BY montant1 ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            while (rs.next()) {
                list.add(new String[]{
                    String.valueOf(rs.getInt("idEnv")),  
                    String.valueOf(rs.getInt("montant1")), 
                    String.valueOf(rs.getInt("montant2")), 
                    String.valueOf(rs.getInt("frais_env"))
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // UPDATE (Modifier une tranche existante) 
    public boolean updateFrais(int idEnv, int m1, int m2, int frais) {
        String query = "UPDATE FRAIS_ENVOI SET montant1 = ?, montant2 = ?, frais_env = ? WHERE idEnv = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, m1);
            ps.setInt(2, m2);
            ps.setInt(3, frais);
            ps.setInt(4, idEnv);  
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE 
    public boolean deleteFrais(int idEnv) {
        String query = "DELETE FROM FRAIS_ENVOI WHERE idEnv = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, idEnv); 
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Trouver les frais selon un montant donné
    public int getFraisPourMontant(int montantEnvoye) {
        String query = "SELECT frais_env FROM FRAIS_ENVOI WHERE ? BETWEEN montant1 AND montant2";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, montantEnvoye);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("frais_env");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0; 
    }
}