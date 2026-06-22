package com.steeven.controller;

import com.steeven.dao.ClientDAO;
import com.steeven.util.MoneyFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/operateur/gestion-clients")
public class OperateurClientServlet extends HttpServlet {
    private ClientDAO clientDAO = new ClientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String searchQuery = request.getParameter("search");
        List<String[]> clients;
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            clients = clientDAO.searchClients(searchQuery.trim());
            request.setAttribute("searchQuery", searchQuery);
            request.setAttribute("searchResult", clients.size() + " résultat(s) trouvé(s)");
        } else {
            clients = clientDAO.getAllClients();
        }
        
        request.setAttribute("clients", clients);
        request.getRequestDispatcher("/operateur/clients.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String numtel = request.getParameter("numtel");
        
        if ("delete".equals(action)) {
            boolean success = clientDAO.deleteClient(numtel);
            request.setAttribute("message", success ? "Client supprimé" : "Erreur suppression");
            request.setAttribute("messageType", success ? "success" : "error");
        } else if ("depot".equals(action)) {
            int montant = 0;
            try { montant = Integer.parseInt(request.getParameter("montant")); } catch (Exception ignored) {}
            boolean success = clientDAO.creditSolde(numtel, montant);
            if (success) {
                request.setAttribute("message", "Dépôt effectué : +" + MoneyFormat.format(montant) + " Ar sur le compte " + numtel);
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Dépôt impossible. Vérifiez le montant et l'utilisateur.");
                request.setAttribute("messageType", "error");
            }
        } else if ("create".equals(action)) {
            String nom = request.getParameter("nom");
            String sexe = request.getParameter("sexe");
            String ageStr = request.getParameter("age");
            String mail = request.getParameter("mail");
            int solde = 0;
            try {
                String soldeStr = request.getParameter("solde");
                if (soldeStr != null && !soldeStr.trim().isEmpty()) {
                    solde = Integer.parseInt(soldeStr.trim());
                }
            } catch (NumberFormatException ignored) {
                solde = -1;
            }

            StringBuilder err = new StringBuilder();
            if (numtel == null || !numtel.matches("[0-9]{10}")) {
                err.append("Numéro de téléphone invalide (10 chiffres). ");
            }
            if (nom == null || nom.trim().isEmpty()) {
                err.append("Le nom est requis. ");
            }
            if (sexe == null || sexe.trim().isEmpty()) {
                err.append("Le sexe est requis. ");
            }
            int age = 0;
            try {
                age = Integer.parseInt(ageStr);
                if (age < 18 || age > 120) {
                    err.append("Âge invalide (18–120 ans). ");
                }
            } catch (Exception e) {
                err.append("Âge invalide. ");
            }
            if (mail == null || !mail.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                err.append("Email invalide. ");
            }
            if (solde < 0) {
                err.append("Solde initial invalide. ");
            }
            if (err.length() == 0 && clientDAO.getClientByNumtel(numtel) != null) {
                err.append("Ce numéro est déjà enregistré. ");
            }

            if (err.length() > 0) {
                request.setAttribute("message", err.toString().trim());
                request.setAttribute("messageType", "error");
            } else {
                final String codeOperateurDefaut = "0000";
                boolean ok = clientDAO.createClient(numtel, nom.trim(), sexe, age, solde, mail.trim(), codeOperateurDefaut);
                if (ok) {
                    request.setAttribute("message", "Client créé : " + nom.trim() + " — solde initial " + MoneyFormat.format(solde) + " Ar, code secret " + codeOperateurDefaut + ".");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Impossible de créer le client (doublon ou erreur base).");
                    request.setAttribute("messageType", "error");
                }
            }
        }
        
        doGet(request, response);
    }
}