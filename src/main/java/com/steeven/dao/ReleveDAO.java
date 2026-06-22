package com.steeven.dao;

import com.steeven.config.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;


public class ReleveDAO {

    public List<String[]> getReleveMois(String numtel, int year, int month) {
        List<String[]> out = new ArrayList<>();

       
        String sql =
                "SELECT d, libelle, debit, credit FROM (" +
                        " SELECT `date` AS d, CONCAT('Transfert vers ', numRecepteur, IF(raison IS NULL OR raison='', '', CONCAT(' • ', raison))) AS libelle," +
                        " montant AS debit, 0 AS credit" +
                        " FROM ENVOI WHERE numEnvoyeur = ? AND YEAR(`date`) = ? AND MONTH(`date`) = ? " +
                        " UNION ALL " +
                        " SELECT `date` AS d, CONCAT('Transfert de ', numEnvoyeur, IF(raison IS NULL OR raison='', '', CONCAT(' • ', raison))) AS libelle," +
                        " 0 AS debit, montant AS credit" +
                        " FROM ENVOI WHERE numRecepteur = ? AND YEAR(`date`) = ? AND MONTH(`date`) = ? " +
                        " UNION ALL " +
                        " SELECT daterecep AS d, CONCAT('Retrait (', idrecep, ')') AS libelle," +
                        " montant AS debit, 0 AS credit" +
                        " FROM RETRAIT WHERE numtel = ? AND YEAR(daterecep) = ? AND MONTH(daterecep) = ? " +
                        ") x ORDER BY d ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, numtel);
            ps.setInt(2, year);
            ps.setInt(3, month);
            ps.setString(4, numtel);
            ps.setInt(5, year);
            ps.setInt(6, month);
            ps.setString(7, numtel);
            ps.setInt(8, year);
            ps.setInt(9, month);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(new String[]{
                            rs.getString("d"),
                            rs.getString("libelle"),
                            String.valueOf(rs.getInt("debit")),
                            String.valueOf(rs.getInt("credit"))
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }
}

