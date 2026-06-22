package com.steeven.controller;

import com.steeven.dao.ClientDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/parametres")
public class ParametresServlet extends HttpServlet {

    private ClientDAO clientDAO;

    @Override
    public void init() {
        clientDAO = new ClientDAO();
    }

    private void flash(HttpSession session, String msg, String type) {
        session.setAttribute("paramFlash", msg);
        session.setAttribute("paramFlashType", type);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        Object msg = session.getAttribute("paramFlash");
        if (msg != null) {
            request.setAttribute("flashMsg", msg);
            request.setAttribute("flashType", session.getAttribute("paramFlashType"));
            session.removeAttribute("paramFlash");
            session.removeAttribute("paramFlashType");
        }
        String numtel = (String) session.getAttribute("numtel");
        request.setAttribute("client", clientDAO.getClientByNumtel(numtel));
        request.getRequestDispatcher("client/parametres.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String numtel = (String) session.getAttribute("numtel");
        String action = request.getParameter("action");

        if ("majProfil".equals(action)) {
            String nom = request.getParameter("nom");
            String sexe = request.getParameter("sexe");
            String ageStr = request.getParameter("age");
            String mail = request.getParameter("mail");

            StringBuilder err = new StringBuilder();
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
                    err.append("Âge invalide (18–120). ");
                }
            } catch (NumberFormatException e) {
                err.append("Âge invalide. ");
            }
            if (mail == null || !mail.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                err.append("Email invalide. ");
            }

            if (err.length() > 0) {
                flash(session, err.toString().trim(), "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }

            String[] c = clientDAO.getClientByNumtel(numtel);
            if (c == null) {
                flash(session, "Compte introuvable.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }
            int solde = Integer.parseInt(c[4]);
            boolean ok = clientDAO.updateClient(numtel, nom.trim(), sexe.trim(), age, solde, mail.trim());
            flash(session, ok ? "Profil mis à jour." : "Impossible d'enregistrer les modifications.", ok ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/parametres");
            return;
        }

        if ("majCode".equals(action)) {
            String ancien = request.getParameter("ancien_code");
            String nouveau = request.getParameter("nouveau_code");
            String conf = request.getParameter("nouveau_code_confirm");

            if (ancien == null || !ancien.matches("[0-9]{4}")
                    || nouveau == null || !nouveau.matches("[0-9]{4}")
                    || conf == null || !conf.matches("[0-9]{4}")) {
                flash(session, "Les codes doivent contenir exactement 4 chiffres.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }
            if (!nouveau.equals(conf)) {
                flash(session, "La confirmation ne correspond pas au nouveau code.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }
            if (ancien.equals(nouveau)) {
                flash(session, "Le nouveau code doit être différent de l'ancien.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }

            boolean ok = clientDAO.changeCodeSecret(numtel, ancien, nouveau);
            flash(session, ok ? "Code secret modifié." : "Ancien code incorrect ou erreur technique.", ok ? "success" : "error");
            response.sendRedirect(request.getContextPath() + "/parametres");
            return;
        }

        if ("supprimerCompte".equals(action)) {
            String code = request.getParameter("code_suppression");
            String confirmation = request.getParameter("confirmation_texte");

            if (code == null || !code.matches("[0-9]{4}")) {
                flash(session, "Code secret invalide.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }
            if (!"SUPPRIMER".equals(confirmation != null ? confirmation.trim() : "")) {
                flash(session, "Tapez exactement SUPPRIMER pour confirmer.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }
            if (!clientDAO.verifyCredentials(numtel, code)) {
                flash(session, "Code secret incorrect.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }

            String[] c = clientDAO.getClientByNumtel(numtel);
            if (c == null) {
                flash(session, "Compte introuvable.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }
            int solde = Integer.parseInt(c[4]);
            if (solde != 0) {
                flash(session, "Solde non nul : retirez ou transférez vos fonds avant de supprimer le compte.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }

            boolean ok = clientDAO.deleteClientCascade(numtel);
            if (!ok) {
                flash(session, "Suppression impossible pour le moment. Réessayez ou contactez le support.", "error");
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }

            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login?compte_supprime=1");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/parametres");
    }
}
