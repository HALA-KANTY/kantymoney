package com.steeven.controller;

import com.steeven.dao.FraisEnvoiDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/operateur/gestionFraisEnvoi")
public class FraisEnvoiServlet extends HttpServlet {
    
    private FraisEnvoiDAO fraisDAO = new FraisEnvoiDAO();

   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
       
        request.setAttribute("listeFrais", fraisDAO.getAllFrais());
        request.getRequestDispatcher("/operateur/frais-envoi.jsp").forward(request, response);
    }

   
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String idEnv = request.getParameter("idEnv");

      
        try {
            if (!"delete".equals(action)) {
                int m1 = Integer.parseInt(request.getParameter("montant1"));
                int m2 = Integer.parseInt(request.getParameter("montant2"));
                int frais = Integer.parseInt(request.getParameter("frais_env"));

                if ("create".equals(action)) {
                    fraisDAO.createFrais(m1, m2, frais);
                    request.setAttribute("message", "Tranche créée avec succès.");
                    request.setAttribute("messageType", "success");
                } else if ("update".equals(action)) {
                    if (idEnv != null && !idEnv.isEmpty()) {
                        fraisDAO.updateFrais(Integer.parseInt(idEnv), m1, m2, frais);
                        request.setAttribute("message", "Tranche mise à jour avec succès.");
                        request.setAttribute("messageType", "success");
                    } else {
                        request.setAttribute("message", "Identifiant de tranche manquant.");
                        request.setAttribute("messageType", "error");
                    }
                } else {
                    request.setAttribute("message", "Action invalide.");
                    request.setAttribute("messageType", "error");
                }
            } else {
                if (idEnv != null && !idEnv.isEmpty()) {
                    fraisDAO.deleteFrais(Integer.parseInt(idEnv));
                    request.setAttribute("message", "Tranche supprimée avec succès.");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "Identifiant de tranche manquant.");
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