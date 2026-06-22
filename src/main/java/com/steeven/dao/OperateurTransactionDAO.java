package com.steeven.dao;

import com.steeven.config.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class OperateurTransactionDAO {

    public List<String[]> listTransactions(String typeFilter, String keyword, String dateYmd) {
        List<String[]> rows = new ArrayList<>();
        String normalizedType = typeFilter == null ? "all" : typeFilter.trim().toLowerCase();
        String kw = keyword == null ? "" : keyword.trim();
        boolean hasKeyword = !kw.isEmpty();
        Date day = parseDateOrNull(dateYmd);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT typeTx, txId, ownerNumtel, contrepartieNumtel, montant, dateTx FROM (");
        sql.append(" SELECT 'ENVOI' AS typeTx, idEnv AS txId, numEnvoyeur AS ownerNumtel, numRecepteur AS contrepartieNumtel, montant, `date` AS dateTx");
        sql.append(" FROM ENVOI");
        sql.append(" UNION ALL");
        sql.append(" SELECT 'RETRAIT' AS typeTx, idrecep AS txId, numtel AS ownerNumtel, NULL AS contrepartieNumtel, montant, daterecep AS dateTx");
        sql.append(" FROM RETRAIT");
        sql.append(" ) tx WHERE 1=1");

        if ("envoi".equals(normalizedType)) {
            sql.append(" AND tx.typeTx = 'ENVOI'");
        } else if ("retrait".equals(normalizedType)) {
            sql.append(" AND tx.typeTx = 'RETRAIT'");
        }

        if (day != null) {
            sql.append(" AND DATE(tx.dateTx) = ?");
        }

        if (hasKeyword) {
            sql.append(" AND (tx.txId LIKE ?)");
        }

        sql.append(" ORDER BY tx.dateTx DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (day != null) {
                ps.setDate(idx++, day);
            }
            if (hasKeyword) {
                ps.setString(idx, "%" + kw + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(new String[]{
                            rs.getString("typeTx"),
                            rs.getString("txId"),
                            rs.getString("ownerNumtel"),
                            rs.getString("contrepartieNumtel"),
                            String.valueOf(rs.getInt("montant")),
                            rs.getString("dateTx")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rows;
    }

    private static Date parseDateOrNull(String ymd) {
        if (ymd == null || ymd.isBlank()) {
            return null;
        }
        try {
            return Date.valueOf(ymd.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
