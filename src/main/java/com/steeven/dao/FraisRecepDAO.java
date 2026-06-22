package com.steeven.dao;

import com.steeven.config.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FraisRecepDAO {

    // CREATE 
    public boolean createFrais(int m1, int m2, int frais) {
        String query = "INSERT INTO FRAIS_RECEP (montant1, montant2, frais_rec) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, m1);
            ps.setInt(2, m2);
            ps.setInt(3, frais);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // READ
    public List<String[]> getAllFrais() {
        List<String[]> list = new ArrayList<>();
        String query = "SELECT * FROM FRAIS_RECEP ORDER BY montant1 ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(query)) {
            while (rs.next()) {
                list.add(new String[]{
                    String.valueOf(rs.getInt("idRec")), 
                    String.valueOf(rs.getInt("montant1")), 
                    String.valueOf(rs.getInt("montant2")), 
                    String.valueOf(rs.getInt("frais_rec"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // UPDATE 
    public boolean updateFrais(int idRec, int m1, int m2, int frais) {
        String query = "UPDATE FRAIS_RECEP SET montant1 = ?, montant2 = ?, frais_rec = ? WHERE idRec = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, m1);
            ps.setInt(2, m2);
            ps.setInt(3, frais);
            ps.setInt(4, idRec);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    // DELETE
    public boolean deleteFrais(int idRec) {
        String query = "DELETE FROM FRAIS_RECEP WHERE idRec = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, idRec);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }
   
public int getFraisPourMontant(int montantRecu) {
    String query = "SELECT frais_rec FROM FRAIS_RECEP WHERE ? BETWEEN montant1 AND montant2";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setInt(1, montantRecu);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt("frais_rec");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return 0;
}
}