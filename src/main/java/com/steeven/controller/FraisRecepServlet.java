package com.steeven.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.steeven.dao.FraisRecepDAO;

@WebServlet("/operateur/gestionFraisRecep")

public class FraisRecepServlet extends HttpServlet {
    private FraisRecepDAO fraisDAO = new FraisRecepDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("listeFrais", fraisDAO.getAllFrais());
        request.getRequestDispatcher("/operateur/frais-recep.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
     
        String idStr = request.getParameter("idRec");
        int idRec = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;

        try {
            if ("delete".equals(action)) {
                fraisDAO.deleteFrais(idRec);
                request.setAttribute("message", "Tranche supprimée avec succès.");
                request.setAttribute("messageType", "success");
            } else {
                int m1 = Integer.parseInt(request.getParameter("montant1"));
                int m2 = Integer.parseInt(request.getParameter("montant2"));
                int frais = Integer.parseInt(request.getParameter("frais_rec"));

                if ("create".equals(action)) {
                    fraisDAO.createFrais(m1, m2, frais);
                    request.setAttribute("message", "Tranche créée avec succès.");
                    request.setAttribute("messageType", "success");
                } else if ("update".equals(action)) {
                    fraisDAO.updateFrais(idRec, m1, m2, frais);
                    request.setAttribute("message", "Tranche mise à jour avec succès.");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Action invalide.");
                    request.setAttribute("messageType", "error");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Erreur: impossible d'exécuter l'action.");
            request.setAttribute("messageType", "error");
        }
        doGet(request, response);
    }
}