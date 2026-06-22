package com.steeven.controller;

import com.steeven.config.DBConnection;
import com.steeven.dao.ClientDAO;
import com.steeven.dao.FraisRecepDAO;
import com.steeven.dao.RetraitDAO;
import com.steeven.service.EmailService;
import com.steeven.util.MoneyFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/retrait")
public class RetraitServlet extends HttpServlet {

    private ClientDAO clientDAO;
    private FraisRecepDAO fraisRecepDAO;
    private RetraitDAO retraitDAO;
    private EmailService emailService;

    @Override
    public void init() {
        clientDAO = new ClientDAO();
        fraisRecepDAO = new FraisRecepDAO();
        retraitDAO = new RetraitDAO();
        emailService = new EmailService();
    }

    private static final String SESS_LIST_RETRAIT_DATE = "clientListeRetraitDate";

    private static String normalizeYmdOrNull(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        if (s.isEmpty()) {
            return null;
        }
        try {
            java.sql.Date.valueOf(s);
            return s;
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private String pickListDateFromRequest(HttpServletRequest request) {
        String d = normalizeYmdOrNull(request.getParameter("date"));
        if (d != null) {
            return d;
        }
        String a = normalizeYmdOrNull(request.getParameter("dateDebut"));
        String b = normalizeYmdOrNull(request.getParameter("dateFin"));
        if (a != null && (b == null || a.equals(b))) {
            return a;
        }
        if (b != null) {
            return b;
        }
        return null;
    }

    private String[] resolveRetraitDateFilter(HttpServletRequest request) {
        HttpSession session = request.getSession();
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            if (request.getQueryString() == null) {
                session.removeAttribute(SESS_LIST_RETRAIT_DATE);
                request.setAttribute("filterDate", "");
                return new String[]{null};
            }
            boolean touchedDates = request.getParameterMap().containsKey("date")
                    || request.getParameterMap().containsKey("dateDebut")
                    || request.getParameterMap().containsKey("dateFin");
            if (touchedDates) {
                String day = pickListDateFromRequest(request);
                session.setAttribute(SESS_LIST_RETRAIT_DATE, day);
                request.setAttribute("filterDate", day != null ? day : "");
                return new String[]{day};
            }
        }
        String day = (String) session.getAttribute(SESS_LIST_RETRAIT_DATE);
        request.setAttribute("filterDate", day != null ? day : "");
        return new String[]{day};
    }

    private String buildRetraitListRedirect(HttpServletRequest request) {
        HttpSession s = request.getSession();
        String day = (String) s.getAttribute(SESS_LIST_RETRAIT_DATE);
        if (day == null) {
            return request.getContextPath() + "/retrait";
        }
        return request.getContextPath() + "/retrait?date=" + URLEncoder.encode(day, StandardCharsets.UTF_8);
    }

    private void loadRetraits(HttpServletRequest request, String numtel) {
        String[] df = resolveRetraitDateFilter(request);
        request.setAttribute("retraits", retraitDAO.getRetraitsByNumtel(numtel, df[0]));
    }

    private void forwardRetrait(HttpServletRequest request, HttpServletResponse response, String numtel)
            throws ServletException, IOException {
        loadRetraits(request, numtel);
        request.getRequestDispatcher("client/retrait.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect("login");
            return;
        }

        String numtel = (String) session.getAttribute("numtel");
        if (session.getAttribute("retraitSuccessData") != null) {
            int[] successData = (int[]) session.getAttribute("retraitSuccessData");
            request.setAttribute("showSuccessModal", true);
            request.setAttribute("successMontant", successData[0]);
            request.setAttribute("successFraisRetrait", successData[1]);
            request.setAttribute("successTotalDebite", successData[2]);
            request.setAttribute("successNouveauSolde", successData[3]);
            session.removeAttribute("retraitSuccessData");
        }
        forwardRetrait(request, response, numtel);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect("login");
            return;
        }

        String numtel = (String) session.getAttribute("numtel");
        String action = request.getParameter("action");
        String montantStr = request.getParameter("montant");
        String codeSecret = request.getParameter("code_secret");

        if ("calculer".equals(action)) {
            int montant;
            try {
                montant = Integer.parseInt(montantStr);
                if (montant <= 0) {
                    request.setAttribute("error", "Montant invalide");
                    request.setAttribute("showInputModal", true);
                    forwardRetrait(request, response, numtel);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Montant invalide");
                request.setAttribute("showInputModal", true);
                forwardRetrait(request, response, numtel);
                return;
            }

            int fraisRetrait = fraisRecepDAO.getFraisPourMontant(montant);
            if (fraisRetrait == 0) {
                request.setAttribute("error", "Aucune tranche de frais de retrait configuree pour ce montant.");
                request.setAttribute("showInputModal", true);
                forwardRetrait(request, response, numtel);
                return;
            }

            int totalDebiter = montant + fraisRetrait;
            request.setAttribute("montant", montantStr);
            request.setAttribute("fraisRetrait", fraisRetrait);
            request.setAttribute("totalDebiter", totalDebiter);
            request.setAttribute("showConfirmModal", true);
            forwardRetrait(request, response, numtel);
            return;
        }

        if ("confirmer".equals(action)) {
            int montant;
            try {
                montant = Integer.parseInt(montantStr);
                if (montant <= 0) {
                    request.setAttribute("error", "Montant invalide");
                    request.setAttribute("showInputModal", true);
                    forwardRetrait(request, response, numtel);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Montant invalide");
                request.setAttribute("showInputModal", true);
                forwardRetrait(request, response, numtel);
                return;
            }

            if (codeSecret == null || !codeSecret.matches("[0-9]{4}")) {
                request.setAttribute("error", "Code secret invalide (4 chiffres)");
                request.setAttribute("showConfirmModal", true);
                request.setAttribute("montant", montantStr);
                request.setAttribute("fraisRetrait", fraisRecepDAO.getFraisPourMontant(montant));
                request.setAttribute("totalDebiter", montant + fraisRecepDAO.getFraisPourMontant(montant));
                forwardRetrait(request, response, numtel);
                return;
            }

            if (!clientDAO.verifyCredentials(numtel, codeSecret)) {
                request.setAttribute("error", "Code secret incorrect");
                request.setAttribute("showConfirmModal", true);
                request.setAttribute("montant", montantStr);
                request.setAttribute("fraisRetrait", fraisRecepDAO.getFraisPourMontant(montant));
                request.setAttribute("totalDebiter", montant + fraisRecepDAO.getFraisPourMontant(montant));
                forwardRetrait(request, response, numtel);
                return;
            }

            int fraisRetrait = fraisRecepDAO.getFraisPourMontant(montant);
            if (fraisRetrait == 0) {
                request.setAttribute("error", "Aucune tranche de frais de retrait configuree pour ce montant.");
                request.setAttribute("showInputModal", true);
                forwardRetrait(request, response, numtel);
                return;
            }

            int totalDebiter = montant + fraisRetrait;

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                conn.setAutoCommit(false);

                PreparedStatement ps = conn.prepareStatement("SELECT solde FROM CLIENT WHERE numtel = ? FOR UPDATE");
                ps.setString(1, numtel);
                ResultSet rs = ps.executeQuery();

                if (!rs.next()) {
                    conn.rollback();
                    request.setAttribute("error", "Compte introuvable");
                    request.setAttribute("showInputModal", true);
                    forwardRetrait(request, response, numtel);
                    return;
                }

                int solde = rs.getInt("solde");
                if (solde < totalDebiter) {
                    conn.rollback();
                    request.setAttribute("error", "Solde insuffisant. Solde: " + solde + " Ar, besoin: " + totalDebiter + " Ar");
                    request.setAttribute("showConfirmModal", true);
                    request.setAttribute("montant", montantStr);
                    request.setAttribute("fraisRetrait", fraisRetrait);
                    request.setAttribute("totalDebiter", totalDebiter);
                    forwardRetrait(request, response, numtel);
                    return;
                }

                ps = conn.prepareStatement("UPDATE CLIENT SET solde = solde - ? WHERE numtel = ?");
                ps.setInt(1, totalDebiter);
                ps.setString(2, numtel);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    request.setAttribute("error", "Debit impossible");
                    request.setAttribute("showInputModal", true);
                    forwardRetrait(request, response, numtel);
                    return;
                }

                String idRecepTransaction = retraitDAO.ajouterRetraitEtRetourIdRecep(conn, numtel, montant);
                if (idRecepTransaction == null || idRecepTransaction.trim().isEmpty()) {
                    conn.rollback();
                    request.setAttribute("error", "Enregistrement retrait impossible");
                    request.setAttribute("showInputModal", true);
                    forwardRetrait(request, response, numtel);
                    return;
                }

                conn.commit();
                int nouveauSolde = solde - totalDebiter;
                try {
                    String[] client = clientDAO.getClientByNumtel(numtel);
                    String email = client != null ? client[5] : null;
                    String sujet = "Confirmation de retrait - KantyMoney";
                    String msg = "Le retrait de " + MoneyFormat.format(montant) + " Ar sur votre compte auprès du " + numtel
                            + " est réussi. Frais : " + MoneyFormat.format(fraisRetrait) + " Ar. Nouveau solde : " + MoneyFormat.format(nouveauSolde)
                            + " Ar. Trans Id : " + idRecepTransaction + ". KANTY Money vous remercie.";
                    emailService.sendAsync(email, sujet, msg);
                } catch (Exception mailEx) {
                    mailEx.printStackTrace();
                }
                session.setAttribute("retraitSuccessData", new int[]{montant, fraisRetrait, totalDebiter, nouveauSolde});
                response.sendRedirect(buildRetraitListRedirect(request));
                return;
            } catch (Exception e) {
                try {
                    if (conn != null) {
                        conn.rollback();
                    }
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
                e.printStackTrace();
                request.setAttribute("error", "Erreur technique, veuillez reessayer");
                request.setAttribute("showInputModal", true);
                forwardRetrait(request, response, numtel);
                return;
            } finally {
                try {
                    if (conn != null) {
                        conn.setAutoCommit(true);
                        conn.close();
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        forwardRetrait(request, response, numtel);
    }
}
