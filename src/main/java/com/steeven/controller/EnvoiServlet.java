package com.steeven.controller;

import com.steeven.dao.*;
import com.steeven.config.DBConnection;
import com.steeven.service.EmailService;
import com.steeven.util.MoneyFormat;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.*;


@WebServlet("/envoi")
public class EnvoiServlet extends HttpServlet {
    
    private ClientDAO clientDAO;
    private FraisEnvoiDAO fraisEnvoiDAO;
    private FraisRecepDAO fraisRecepDAO;
    private EnvoiDAO envoiDAO;
    private EmailService emailService;
    
    @Override
    public void init() {
        clientDAO = new ClientDAO();
        fraisEnvoiDAO = new FraisEnvoiDAO();
        fraisRecepDAO = new FraisRecepDAO();
        envoiDAO = new EnvoiDAO();
        emailService = new EmailService();
    }

    private static final String SESS_LIST_ENVOI_DATE = "clientListeEnvoiDate";

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

  
    private String[] resolveEnvoiDateFilter(HttpServletRequest request) {
        HttpSession session = request.getSession();
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            if (request.getQueryString() == null) {
                session.removeAttribute(SESS_LIST_ENVOI_DATE);
                request.setAttribute("filterDate", "");
                return new String[]{null};
            }
            boolean touchedDates = request.getParameterMap().containsKey("date")
                    || request.getParameterMap().containsKey("dateDebut")
                    || request.getParameterMap().containsKey("dateFin");
            if (touchedDates) {
                String day = pickListDateFromRequest(request);
                session.setAttribute(SESS_LIST_ENVOI_DATE, day);
                request.setAttribute("filterDate", day != null ? day : "");
                return new String[]{day};
            }
        }
        String day = (String) session.getAttribute(SESS_LIST_ENVOI_DATE);
        request.setAttribute("filterDate", day != null ? day : "");
        return new String[]{day};
    }

    private String buildEnvoiListRedirect(HttpServletRequest request) {
        HttpSession s = request.getSession();
        String day = (String) s.getAttribute(SESS_LIST_ENVOI_DATE);
        if (day == null) {
            return request.getContextPath() + "/envoi";
        }
        return request.getContextPath() + "/envoi?date=" + URLEncoder.encode(day, StandardCharsets.UTF_8);
    }

    private void loadTransactions(HttpServletRequest request, String numEnvoyeur) {
        String[] df = resolveEnvoiDateFilter(request);
        request.setAttribute("transactions", envoiDAO.getEnvoisByEnvoyeur(numEnvoyeur, df[0]));
    }

    private void forwardEnvoi(HttpServletRequest request, HttpServletResponse response, String numEnvoyeur)
            throws ServletException, IOException {
        loadTransactions(request, numEnvoyeur);
        request.getRequestDispatcher("client/envoi.jsp").forward(request, response);
    }
    
   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
       
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect("login");
            return;
        }
        
        
        String numEnvoyeur = (String) session.getAttribute("numtel");
        if (session.getAttribute("envoiSuccessData") != null) {
            int[] successData = (int[]) session.getAttribute("envoiSuccessData");
            request.setAttribute("showSuccessModal", true);
            request.setAttribute("successMontant", successData[0]);
            request.setAttribute("successFraisEnvoi", successData[1]);
            request.setAttribute("successFraisRetrait", successData[2]);
            request.setAttribute("successTotalDebite", successData[3]);
            request.setAttribute("successMontantRecu", successData[4]);
            request.setAttribute("successRecepteur", session.getAttribute("envoiSuccessRecepteur"));
            request.setAttribute("successRaison", session.getAttribute("envoiSuccessRaison"));
            session.removeAttribute("envoiSuccessData");
            session.removeAttribute("envoiSuccessRecepteur");
            session.removeAttribute("envoiSuccessRaison");
        }
        loadTransactions(request, numEnvoyeur);
        request.getRequestDispatcher("client/envoi.jsp").forward(request, response);
    }
    
    // Traiter l'envoi
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        
      
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect("login");
            return;
        }
        
        String numEnvoyeur = (String) session.getAttribute("numtel");
        String numRecepteur = request.getParameter("recepteur");
        String montantStr = request.getParameter("montant");
        String payerFraisRetrait = request.getParameter("payerFraisRetrait"); 
        String codeSecret = request.getParameter("code_secret");
        String raisonSaisie = request.getParameter("raison");
        String action = request.getParameter("action");
        boolean avecFraisRetrait = "on".equals(payerFraisRetrait);
        
      
        if ("rechercher".equals(action)) {
            if (numRecepteur == null || numRecepteur.trim().isEmpty()) {
                request.setAttribute("error", "Veuillez entrer un numéro de récepteur");
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            int montant;
            try {
                montant = Integer.parseInt(montantStr);
                if (montant <= 0) {
                    request.setAttribute("error", "Montant invalide");
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Montant invalide");
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            if (numEnvoyeur.equals(numRecepteur)) {
                request.setAttribute("error", "Vous ne pouvez pas vous envoyer de l'argent à vous-même");
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            String[] client = clientDAO.getClientByNumtel(numRecepteur);

            if (client == null) {
                request.setAttribute("error", "Aucun client trouvé avec ce numéro");
            } else {
                request.setAttribute("recepteurTrouve", true);
                request.setAttribute("recepteurNom", client[1]);
                request.setAttribute("recepteurEmail", client[5]);
                request.setAttribute("recepteurNum", client[0]);

                int fraisEnvoi = fraisEnvoiDAO.getFraisPourMontant(montant);
                int fraisRetrait = avecFraisRetrait ? fraisRecepDAO.getFraisPourMontant(montant) : 0;
                int totalDebiter = montant + fraisEnvoi + (avecFraisRetrait ? fraisRetrait : 0);
                int totalCrediter = montant + (avecFraisRetrait ? fraisRetrait : 0);

                request.setAttribute("fraisEnvoiPreview", fraisEnvoi);
                request.setAttribute("fraisRetraitPreview", fraisRetrait);
                request.setAttribute("totalDebiterPreview", totalDebiter);
                request.setAttribute("totalCrediterPreview", totalCrediter);

                if (fraisEnvoi == 0) {
                    request.setAttribute("info", "Aucune tranche de frais d'envoi trouvee pour ce montant (frais = 0).");
                }
            }
            
            request.setAttribute("recepteur", numRecepteur);
            request.setAttribute("montant", montantStr);
            request.setAttribute("payerFraisRetraitSelected", avecFraisRetrait);
            request.setAttribute("raison", raisonSaisie);
            request.setAttribute("showCreateModal", true);
            forwardEnvoi(request, response, numEnvoyeur);
            return;
        }

        if ("supprimerTransaction".equals(action)) {
            int id;
            try {
                id = Integer.parseInt(request.getParameter("idTransaction"));
            } catch (Exception e) {
                request.setAttribute("error", "Transaction invalide");
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            if (envoiDAO.deleteEnvoiByIdAndEnvoyeur(id, numEnvoyeur)) {
                request.setAttribute("success", "Transaction supprimee avec succes");
            } else {
                request.setAttribute("error", "Suppression impossible pour cette transaction");
            }
            forwardEnvoi(request, response, numEnvoyeur);
            return;
        }

        if ("modifierTransaction".equals(action)) {
            int id;
            try {
                id = Integer.parseInt(request.getParameter("idTransaction"));
            } catch (Exception e) {
                request.setAttribute("error", "Transaction invalide");
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            boolean payerRetrait = "on".equals(request.getParameter("payerFraisRetraitEdit"));
            String raisonEdit = request.getParameter("raisonEdit");
            if (raisonEdit == null || raisonEdit.trim().isEmpty()) {
                raisonEdit = "Envoi";
            }

            if (envoiDAO.updateEnvoiByIdAndEnvoyeur(id, numEnvoyeur, payerRetrait, raisonEdit.trim())) {
                request.setAttribute("success", "Transaction modifiee avec succes");
            } else {
                request.setAttribute("error", "Modification impossible pour cette transaction");
            }
            forwardEnvoi(request, response, numEnvoyeur);
            return;
        }
        
        // ÉTAPE 2 : Confirmation et exécution de l'envoi
        if ("confirmer".equals(action)) {
            
          
            if (numRecepteur == null || numRecepteur.trim().isEmpty()) {
                request.setAttribute("error", "Numéro du récepteur requis");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }
            
            int montant;
            try {
                montant = Integer.parseInt(montantStr);
                if (montant <= 0) {
                    request.setAttribute("error", "Montant invalide");
                    request.setAttribute("showCreateModal", true);
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Montant invalide");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }
            
            if (numEnvoyeur.equals(numRecepteur)) {
                request.setAttribute("error", "Vous ne pouvez pas vous envoyer de l'argent à vous-même");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            String[] recepteur = clientDAO.getClientByNumtel(numRecepteur);
            if (recepteur == null) {
                request.setAttribute("error", "Bénéficiaire introuvable. Vérifiez le numéro, puis relancez la recherche.");
                request.setAttribute("showCreateModal", true);
                request.setAttribute("recepteur", numRecepteur);
                request.setAttribute("montant", montantStr);
                request.setAttribute("payerFraisRetraitSelected", avecFraisRetrait);
                request.setAttribute("raison", raisonSaisie);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            request.setAttribute("recepteurTrouve", true);
            request.setAttribute("recepteurNom", recepteur[1]);
            request.setAttribute("recepteurEmail", recepteur[5]);
            request.setAttribute("recepteurNum", recepteur[0]);
            request.setAttribute("recepteur", numRecepteur);
            request.setAttribute("montant", montantStr);
            request.setAttribute("payerFraisRetraitSelected", avecFraisRetrait);
            request.setAttribute("raison", raisonSaisie);
            
           
            if (codeSecret == null || !codeSecret.matches("[0-9]{4}")) {
                request.setAttribute("error", "Code secret invalide (4 chiffres)");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }
            
            if (!clientDAO.verifyCredentials(numEnvoyeur, codeSecret)) {
                request.setAttribute("error", "Code secret incorrect");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }
            
            // Calcul des frais
            int fraisEnvoi = fraisEnvoiDAO.getFraisPourMontant(montant);
            int fraisRetrait = 0;
            
            if (avecFraisRetrait) {
                fraisRetrait = fraisRecepDAO.getFraisPourMontant(montant);
            }

            if (fraisEnvoi == 0) {
                request.setAttribute("error", "Aucune tranche de frais d'envoi configuree pour ce montant.");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }

            if (avecFraisRetrait && fraisRetrait == 0) {
                request.setAttribute("error", "Aucune tranche de frais de retrait configuree pour ce montant.");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            }
            
            int totalDebiter = montant + fraisEnvoi + (avecFraisRetrait ? fraisRetrait : 0);
            int totalCrediter = montant + (avecFraisRetrait ? fraisRetrait : 0);
            
            // Transaction en base
            Connection conn = null;
            try {
                conn = DBConnection.getConnection();
                conn.setAutoCommit(false);
                
               
                String sqlSolde = "SELECT solde FROM CLIENT WHERE numtel = ? FOR UPDATE";
                PreparedStatement ps = conn.prepareStatement(sqlSolde);
                ps.setString(1, numEnvoyeur);
                ResultSet rs = ps.executeQuery();
                
                if (!rs.next()) {
                    conn.rollback();
                    request.setAttribute("error", "Compte envoyeur introuvable");
                    request.setAttribute("showCreateModal", true);
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
                
                int solde = rs.getInt("solde");
                if (solde < totalDebiter) {
                    conn.rollback();
                    request.setAttribute("error", "Solde insuffisant. Votre solde : " + solde + " F, besoin : " + totalDebiter + " F");
                    request.setAttribute("showCreateModal", true);
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
                
               
                ps = conn.prepareStatement("UPDATE CLIENT SET solde = solde - ? WHERE numtel = ?");
                ps.setInt(1, totalDebiter);
                ps.setString(2, numEnvoyeur);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    request.setAttribute("error", "Debit envoyeur impossible");
                    request.setAttribute("showCreateModal", true);
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
                
                
                ps = conn.prepareStatement("UPDATE CLIENT SET solde = solde + ? WHERE numtel = ?");
                ps.setInt(1, totalCrediter);
                ps.setString(2, numRecepteur);
                if (ps.executeUpdate() != 1) {
                    conn.rollback();
                    request.setAttribute("error", "Credit recepteur impossible");
                    request.setAttribute("showCreateModal", true);
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
                
               
                String raison = (raisonSaisie == null || raisonSaisie.trim().isEmpty()) ? "Sans raison" : raisonSaisie.trim();
                String idEnvTransaction = envoiDAO.ajouterEnvoiEtRetourIdEnv(conn, numEnvoyeur, numRecepteur, montant, avecFraisRetrait, raison);
                if (idEnvTransaction == null || idEnvTransaction.trim().isEmpty()) {
                    conn.rollback();
                    request.setAttribute("error", "Impossible d'enregistrer la transaction");
                    request.setAttribute("showCreateModal", true);
                    forwardEnvoi(request, response, numEnvoyeur);
                    return;
                }
                
                conn.commit();

                session.setAttribute("envoiSuccessData", new int[]{montant, fraisEnvoi, fraisRetrait, totalDebiter, totalCrediter});
                session.setAttribute("envoiSuccessRecepteur", numRecepteur);
                session.setAttribute("envoiSuccessRaison", raison);

               
                try {
                    String[] envoyeur = clientDAO.getClientByNumtel(numEnvoyeur);
                    String[] recepteurApres = clientDAO.getClientByNumtel(numRecepteur);
                    String emailEnvoyeur = envoyeur != null ? envoyeur[5] : null;
                    String emailRecepteur = recepteur[5];
                    int nouveauSoldeEnvoyeur = solde - totalDebiter;
                    int nouveauSoldeRecepteur = 0;
                    if (recepteurApres != null) {
                        try {
                            nouveauSoldeRecepteur = Integer.parseInt(recepteurApres[4]);
                        } catch (NumberFormatException ignored) {
                           
                        }
                    }
                    String sujet = "Confirmation - KantyMoney";
                    String fraisTxt = " Frais envoi: " + MoneyFormat.format(fraisEnvoi) + " Ar."
                            + (avecFraisRetrait ? " Frais retrait: " + MoneyFormat.format(fraisRetrait) + " Ar." : "");
                    String msgEnvoyeur = "Votre transfert de " + MoneyFormat.format(montant) + " Ar vers " + numRecepteur + " est reussi."
                            + fraisTxt
                            + " Nouveau Solde: " + MoneyFormat.format(nouveauSoldeEnvoyeur) + " Ar. Trans Id: " + idEnvTransaction
                            + ". KANTY Money vous remercie.";
                    String msgRecepteur = "Vous avez recu un transfert de " + MoneyFormat.format(totalCrediter) + " Ar venant du "
                            + numEnvoyeur + " Nouveau Solde: " + MoneyFormat.format(nouveauSoldeRecepteur) + " Ar. Trans Id: "
                            + idEnvTransaction
                            + ". KANTY Money vous remercie.";
                    emailService.sendAsync(emailEnvoyeur, sujet, msgEnvoyeur);
                    emailService.sendAsync(emailRecepteur, sujet, msgRecepteur);
                } catch (Exception mailEx) {
                    mailEx.printStackTrace();
                }

                response.sendRedirect(buildEnvoiListRedirect(request));
                return;
                
            } catch (Exception e) {
                try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                e.printStackTrace();
                request.setAttribute("error", "Erreur technique, veuillez réessayer");
                request.setAttribute("showCreateModal", true);
                forwardEnvoi(request, response, numEnvoyeur);
                return;
            } finally {
                try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
            }
        }

        forwardEnvoi(request, response, numEnvoyeur);
    }
}