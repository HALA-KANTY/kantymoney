package com.steeven.dao;

import com.steeven.config.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.util.Arrays;

public class OperateurStatsDAO {

    
    public long[] getDashboardStats() {
        long[] out = new long[]{0, 0, 0, 0, 0, 0};
        String qClients = "SELECT COUNT(*) FROM CLIENT";
        String qTxToday =
                "SELECT " +
                        " (SELECT COUNT(*) FROM ENVOI WHERE DATE(`date`) = CURDATE()) +" +
                        " (SELECT COUNT(*) FROM RETRAIT WHERE DATE(daterecep) = CURDATE())";
        String qFraisEnvoiTotal =
                "SELECT COALESCE(SUM(fe.frais_env),0) " +
                        "FROM ENVOI e " +
                        "JOIN FRAIS_ENVOI fe ON e.montant BETWEEN fe.montant1 AND fe.montant2";
        String qFraisRetraitTotal =
                "SELECT COALESCE(SUM(fr.frais_rec),0) " +
                        "FROM RETRAIT r " +
                        "JOIN FRAIS_RECEP fr ON r.montant BETWEEN fr.montant1 AND fr.montant2";
        String qFraisEnvoiMois =
                "SELECT COALESCE(SUM(fe.frais_env),0) " +
                        "FROM ENVOI e " +
                        "JOIN FRAIS_ENVOI fe ON e.montant BETWEEN fe.montant1 AND fe.montant2 " +
                        "WHERE YEAR(e.`date`) = YEAR(CURDATE()) AND MONTH(e.`date`) = MONTH(CURDATE())";
        String qFraisRetraitMois =
                "SELECT COALESCE(SUM(fr.frais_rec),0) " +
                        "FROM RETRAIT r " +
                        "JOIN FRAIS_RECEP fr ON r.montant BETWEEN fr.montant1 AND fr.montant2 " +
                        "WHERE YEAR(r.daterecep) = YEAR(CURDATE()) AND MONTH(r.daterecep) = MONTH(CURDATE())";

        try (Connection conn = DBConnection.getConnection()) {
            out[0] = scalar(conn, qClients);
            out[1] = scalar(conn, qTxToday);
            out[4] = scalar(conn, qFraisEnvoiTotal);
            out[5] = scalar(conn, qFraisRetraitTotal);
            out[2] = out[4] + out[5];
            long fraisEnvoiMois = scalar(conn, qFraisEnvoiMois);
            long fraisRetraitMois = scalar(conn, qFraisRetraitMois);
            out[3] = fraisEnvoiMois + fraisRetraitMois;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

    private long scalar(Connection conn, String sql) {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0L;
    }

 
    public long[] getRecette7DerniersJours() {
        long[] out = new long[7];
        Arrays.fill(out, 0L);
        String qEnvoi =
                "SELECT DATE(e.`date`) d, COALESCE(SUM(fe.frais_env),0) v " +
                        "FROM ENVOI e " +
                        "JOIN FRAIS_ENVOI fe ON e.montant BETWEEN fe.montant1 AND fe.montant2 " +
                        "WHERE DATE(e.`date`) BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND CURDATE() " +
                        "GROUP BY DATE(e.`date`)";
        String qRetrait =
                "SELECT DATE(r.daterecep) d, COALESCE(SUM(fr.frais_rec),0) v " +
                        "FROM RETRAIT r " +
                        "JOIN FRAIS_RECEP fr ON r.montant BETWEEN fr.montant1 AND fr.montant2 " +
                        "WHERE DATE(r.daterecep) BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 DAY) AND CURDATE() " +
                        "GROUP BY DATE(r.daterecep)";
        String[] keys = new String[7];
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL ? DAY), '%Y-%m-%d')")) {
                for (int i = 0; i < 7; i++) {
                    ps.setInt(1, 6 - i);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) keys[i] = rs.getString(1);
                    }
                }
            }
            accumulateByDate(conn, qEnvoi, keys, out);
            accumulateByDate(conn, qRetrait, keys, out);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

   
    public long[] getRepartitionTransactionsAujourdhui() {
        long[] out = new long[]{0, 0, 0};
        String qEnvoi = "SELECT COUNT(*) FROM ENVOI WHERE DATE(`date`) = CURDATE()";
        String qReception = "SELECT COUNT(*) FROM ENVOI WHERE DATE(`date`) = CURDATE()";
        String qRetrait = "SELECT COUNT(*) FROM RETRAIT WHERE DATE(daterecep) = CURDATE()";
        try (Connection conn = DBConnection.getConnection()) {
            out[0] = scalar(conn, qEnvoi);
            out[1] = scalar(conn, qReception);
            out[2] = scalar(conn, qRetrait);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

    private void accumulateByDate(Connection conn, String sql, String[] keys, long[] out) {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String d = rs.getString("d");
                long v = rs.getLong("v");
                for (int i = 0; i < keys.length; i++) {
                    if (keys[i] != null && keys[i].equals(d)) {
                        out[i] += v;
                        break;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

   
    public long[] getRecetteBetween(Date start, Date end) {
        long[] out = new long[]{0, 0, 0, 0};
        String qFraisEnvoi =
                "SELECT COALESCE(SUM(fe.frais_env),0) " +
                        "FROM ENVOI e " +
                        "JOIN FRAIS_ENVOI fe ON e.montant BETWEEN fe.montant1 AND fe.montant2 " +
                        "WHERE DATE(e.`date`) BETWEEN ? AND ?";
        String qFraisRetrait =
                "SELECT COALESCE(SUM(fr.frais_rec),0) " +
                        "FROM RETRAIT r " +
                        "JOIN FRAIS_RECEP fr ON r.montant BETWEEN fr.montant1 AND fr.montant2 " +
                        "WHERE DATE(r.daterecep) BETWEEN ? AND ?";
        String qCount =
                "SELECT " +
                        " (SELECT COUNT(*) FROM ENVOI e WHERE DATE(e.`date`) BETWEEN ? AND ?) +" +
                        " (SELECT COUNT(*) FROM RETRAIT r WHERE DATE(r.daterecep) BETWEEN ? AND ?)";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(qFraisEnvoi)) {
                ps.setDate(1, start);
                ps.setDate(2, end);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out[0] = rs.getLong(1);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(qFraisRetrait)) {
                ps.setDate(1, start);
                ps.setDate(2, end);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out[1] = rs.getLong(1);
                }
            }
            out[2] = out[0] + out[1];
            try (PreparedStatement ps = conn.prepareStatement(qCount)) {
                ps.setDate(1, start);
                ps.setDate(2, end);
                ps.setDate(3, start);
                ps.setDate(4, end);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out[3] = rs.getLong(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }
}

