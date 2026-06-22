package com.steeven.dao;

import com.steeven.config.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class HistoriqueDAO {

    private static final String UNION_INNER =
            "SELECT 'OUT' AS tx_type, idEnv AS ref, numRecepteur AS partenaire, montant, `date` AS d, IFNULL(raison,'') AS info "
                    + "FROM ENVOI WHERE numEnvoyeur = ? "
                    + "UNION ALL "
                    + "SELECT 'IN', idEnv, numEnvoyeur, montant, `date`, IFNULL(raison,'') FROM ENVOI WHERE numRecepteur = ? "
                    + "UNION ALL "
                    + "SELECT 'RET', idrecep, numtel, montant, daterecep, '' FROM RETRAIT WHERE numtel = ? ";

    public List<String[]> getRecent(String numtel, int limit) {
        if (limit < 1) {
            limit = 1;
        }
        List<String[]> rows = new ArrayList<>();
        String sql = "SELECT * FROM (" + UNION_INNER + ") h ORDER BY h.d DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, numtel);
            ps.setString(2, numtel);
            ps.setString(3, numtel);
            ps.setInt(4, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rows;
    }

    public int countHistorique(String numtel, String dateYmd, String telDigits, String txKind) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM (").append(UNION_INNER).append(") h WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        params.add(numtel);
        params.add(numtel);
        params.add(numtel);
        appendSingleDayFilter(sql, params, dateYmd);
        appendTelFilter(sql, params, telDigits);
        appendTxKindFilter(sql, txKind);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindAll(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<String[]> listHistorique(String numtel, String dateYmd, String telDigits, String txKind, int offset, int pageSize) {
        List<String[]> rows = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM (").append(UNION_INNER).append(") h WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        params.add(numtel);
        params.add(numtel);
        params.add(numtel);
        appendSingleDayFilter(sql, params, dateYmd);
        appendTelFilter(sql, params, telDigits);
        appendTxKindFilter(sql, txKind);
        sql.append(" ORDER BY h.d DESC LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add(offset);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindAll(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rows;
    }

    /**
     * Totaux du mois en cours : [totalEnvoye, totalRecu, totalRetraitsBruts, nbOperations]
     */
    public int[] getStatsMoisCourant(String numtel) {
        int[] out = new int[]{0, 0, 0, 0};
        String qEnv = "SELECT COALESCE(SUM(montant),0) FROM ENVOI WHERE numEnvoyeur = ? AND YEAR(`date`) = YEAR(CURDATE()) AND MONTH(`date`) = MONTH(CURDATE())";
        String qRec = "SELECT COALESCE(SUM(montant),0) FROM ENVOI WHERE numRecepteur = ? AND YEAR(`date`) = YEAR(CURDATE()) AND MONTH(`date`) = MONTH(CURDATE())";
        String qRet = "SELECT COALESCE(SUM(montant),0) FROM RETRAIT WHERE numtel = ? AND YEAR(daterecep) = YEAR(CURDATE()) AND MONTH(daterecep) = MONTH(CURDATE())";
        String qNb = "SELECT (SELECT COUNT(*) FROM ENVOI WHERE (numEnvoyeur = ? OR numRecepteur = ?) AND YEAR(`date`) = YEAR(CURDATE()) AND MONTH(`date`) = MONTH(CURDATE())) "
                + "+ (SELECT COUNT(*) FROM RETRAIT WHERE numtel = ? AND YEAR(daterecep) = YEAR(CURDATE()) AND MONTH(daterecep) = MONTH(CURDATE()))";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(qEnv)) {
                ps.setString(1, numtel);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out[0] = rs.getInt(1);
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(qRec)) {
                ps.setString(1, numtel);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out[1] = rs.getInt(1);
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(qRet)) {
                ps.setString(1, numtel);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out[2] = rs.getInt(1);
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(qNb)) {
                ps.setString(1, numtel);
                ps.setString(2, numtel);
                ps.setString(3, numtel);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out[3] = rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return out;
    }

    private static String[] mapRow(ResultSet rs) throws SQLException {
        return new String[]{
                rs.getString("tx_type"),
                rs.getString("ref"),
                rs.getString("partenaire"),
                String.valueOf(rs.getInt("montant")),
                rs.getString("d"),
                rs.getString("info")
        };
    }

    private static Date parseSqlDateOrNull(String ymd) {
        if (ymd == null || ymd.isBlank()) {
            return null;
        }
        try {
            return Date.valueOf(ymd.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

   
    private static void appendSingleDayFilter(StringBuilder sql, List<Object> params, String dateYmd) {
        Date d = parseSqlDateOrNull(dateYmd);
        if (d == null) {
            return;
        }
        sql.append(" AND DATE(h.d) = ? ");
        params.add(d);
    }

    
    private static void appendTxKindFilter(StringBuilder sql, String txKind) {
        if (txKind == null || txKind.isBlank() || "all".equalsIgnoreCase(txKind)) {
            return;
        }
        if ("envoi".equalsIgnoreCase(txKind)) {
            sql.append(" AND h.tx_type IN ('OUT','IN') ");
        } else if ("retrait".equalsIgnoreCase(txKind)) {
            sql.append(" AND h.tx_type = 'RET' ");
        }
    }

    private static void appendTelFilter(StringBuilder sql, List<Object> params, String telDigits) {
        if (telDigits == null || telDigits.isBlank()) {
            return;
        }
        String p = "%" + telDigits.trim() + "%";
        sql.append(" AND (h.partenaire LIKE ? OR h.ref LIKE ?) ");
        params.add(p);
        params.add(p);
    }

    private static void bindAll(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object o = params.get(i);
            int idx = i + 1;
            if (o instanceof Date) {
                ps.setDate(idx, (Date) o);
            } else if (o instanceof Integer) {
                ps.setInt(idx, (Integer) o);
            } else {
                ps.setString(idx, o != null ? o.toString() : null);
            }
        }
    }
}
