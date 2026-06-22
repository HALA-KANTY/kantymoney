package com.steeven.controller;

import com.steeven.config.DBConnection;
import com.steeven.dao.ClientDAO;
import com.steeven.dao.OperateurTransactionDAO;
import com.steeven.service.EmailService;
import com.steeven.util.MoneyFormat;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/operateur/transactions")
public class OperateurTransactionServlet extends HttpServlet {

    private OperateurTransactionDAO transactionDAO;
    private ClientDAO clientDAO;
    private EmailService emailService;

    @Override
    public void init() {
        transactionDAO = new OperateurTransactionDAO();
        clientDAO = new ClientDAO();
        emailService = new EmailService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "all";
        }
        String search = request.getParameter("search");
        if (search == null) {
            search = "";
        }
        String date = request.getParameter("date");
        if (date == null) {
            date = "";
        } else {
            date = date.trim();
        }

        List<String[]> transactions = transactionDAO.listTransactions(type, search, date.isEmpty() ? null : date);
        request.setAttribute("transactions", transactions);
        request.setAttribute("typeFilter", type);
        request.setAttribute("searchQuery", search);
        request.setAttribute("filterDate", date);

        String flashMsg = request.getParameter("msg");
        String flashType = request.getParameter("msgType");
        if (flashMsg != null && !flashMsg.isEmpty()) {
            try {
                request.setAttribute("message", URLDecoder.decode(flashMsg, StandardCharsets.UTF_8));
            } catch (Exception e) {
                request.setAttribute("message", flashMsg);
            }
            request.setAttribute("messageType", flashType != null && !flashType.isEmpty() ? flashType : "info");
        }

        request.setAttribute("searchResult", transactions.size() + " transaction(s) trouvee(s)");
        request.getRequestDispatcher("/operateur/transactions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (!"annuler".equals(action)) {
            doGet(request, response);
            return;
        }

        String returnType = request.getParameter("returnType");
        if (returnType == null || returnType.trim().isEmpty()) {
            returnType = "all";
        }
        String returnSearch = request.getParameter("returnSearch");
        if (returnSearch == null) {
            returnSearch = "";
        }
        String returnDate = request.getParameter("returnDate");
        if (returnDate == null) {
            returnDate = "";
        }

        String txType = request.getParameter("txType");
        String txId = request.getParameter("txId");
        if (txType == null || txId == null || txType.trim().isEmpty() || txId.trim().isEmpty()) {
            response.sendRedirect(buildTransactionsListUrl(request, returnType, returnSearch, returnDate,
                    "Transaction invalide.", "error"));
            return;
        }

        CancellationResult result;
        if ("ENVOI".equalsIgnoreCase(txType.trim())) {
            result = cancelEnvoi(txId.trim());
        } else if ("RETRAIT".equalsIgnoreCase(txType.trim())) {
            result = cancelRetrait(txId.trim());
        } else {
            result = new CancellationResult(false, "Type de transaction inconnu.");
        }

        response.sendRedirect(buildTransactionsListUrl(request, returnType, returnSearch, returnDate,
                result.message, result.success ? "success" : "error"));
    }

    private String buildTransactionsListUrl(HttpServletRequest request, String type, String search, String date,
                                            String message, String messageType) {
        StringBuilder sb = new StringBuilder();
        sb.append(request.getContextPath()).append("/operateur/transactions?");
        sb.append("type=").append(URLEncoder.encode(type.trim(), StandardCharsets.UTF_8));
        if (search != null && !search.trim().isEmpty()) {
            sb.append("&search=").append(URLEncoder.encode(search.trim(), StandardCharsets.UTF_8));
        }
        if (date != null && !date.trim().isEmpty()) {
            sb.append("&date=").append(URLEncoder.encode(date.trim(), StandardCharsets.UTF_8));
        }
        if (message != null && !message.isEmpty()) {
            sb.append("&msg=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));
            sb.append("&msgType=").append(URLEncoder.encode(messageType != null ? messageType : "info", StandardCharsets.UTF_8));
        }
        return sb.toString();
    }

    private CancellationResult cancelEnvoi(String idEnv) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String ownerNumtel;
            int montant;
            String fetchSql = "SELECT numEnvoyeur, montant FROM ENVOI WHERE idEnv = ? FOR UPDATE";
            try (PreparedStatement ps = conn.prepareStatement(fetchSql)) {
                ps.setString(1, idEnv);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return new CancellationResult(false, "Transaction envoi introuvable.");
                    }
                    ownerNumtel = rs.getString("numEnvoyeur");
                    montant = rs.getInt("montant");
                }
            }

            if (!creditOwner(conn, ownerNumtel, montant)) {
                conn.rollback();
                return new CancellationResult(false, "Recredit impossible pour ce client.");
            }

            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM ENVOI WHERE idEnv = ?")) {
                ps.setString(1, idEnv);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    return new CancellationResult(false, "Annulation envoi impossible.");
                }
            }

            conn.commit();
            notifyOwnerCancellation(ownerNumtel, idEnv, montant, "ENVOI");
            return new CancellationResult(true, "Transaction ENVOI annulee. Montant recredite (hors frais).");
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            return new CancellationResult(false, "Erreur technique lors de l'annulation.");
        } finally {
            closeConn(conn);
        }
    }

    private CancellationResult cancelRetrait(String idRecep) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String ownerNumtel;
            int montant;
            String fetchSql = "SELECT numtel, montant FROM RETRAIT WHERE idrecep = ? FOR UPDATE";
            try (PreparedStatement ps = conn.prepareStatement(fetchSql)) {
                ps.setString(1, idRecep);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return new CancellationResult(false, "Transaction retrait introuvable.");
                    }
                    ownerNumtel = rs.getString("numtel");
                    montant = rs.getInt("montant");
                }
            }

            if (!creditOwner(conn, ownerNumtel, montant)) {
                conn.rollback();
                return new CancellationResult(false, "Recredit impossible pour ce client.");
            }

            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM RETRAIT WHERE idrecep = ?")) {
                ps.setString(1, idRecep);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    return new CancellationResult(false, "Annulation retrait impossible.");
                }
            }

            conn.commit();
            notifyOwnerCancellation(ownerNumtel, idRecep, montant, "RETRAIT");
            return new CancellationResult(true, "Transaction RETRAIT annulee. Montant recredite (hors frais).");
        } catch (Exception e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            return new CancellationResult(false, "Erreur technique lors de l'annulation.");
        } finally {
            closeConn(conn);
        }
    }

    private boolean creditOwner(Connection conn, String numtel, int montant) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("UPDATE CLIENT SET solde = solde + ? WHERE numtel = ?")) {
            ps.setInt(1, montant);
            ps.setString(2, numtel);
            return ps.executeUpdate() == 1;
        }
    }

    private void notifyOwnerCancellation(String ownerNumtel, String transactionId, int montant, String txType) {
        try {
            String[] owner = clientDAO.getClientByNumtel(ownerNumtel);
            if (owner == null) {
                return;
            }
            String email = owner[5];
            String sujet = "Annulation transaction - KantyMoney";
            String msg = "Votre transaction " + txType + " (" + transactionId + ") a ete annulee par l'operateur. "
                    + "Le montant de " + MoneyFormat.format(montant) + " Ar a ete recredite sur votre compte (hors frais).";
            emailService.sendAsync(email, sujet, msg);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.rollback();
        } catch (SQLException ignored) {
        }
    }

    private void closeConn(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.setAutoCommit(true);
            conn.close();
        } catch (SQLException ignored) {
        }
    }

    private static class CancellationResult {
        private final boolean success;
        private final String message;

        private CancellationResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }
}
