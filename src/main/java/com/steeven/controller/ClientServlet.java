package com.steeven.controller;

import com.steeven.dao.ClientDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/gestionClient")
public class ClientServlet extends HttpServlet {
    private ClientDAO clientDAO = new ClientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
       
        if ("edit".equals(action)) {
            String numtel = request.getParameter("numtel");
           
            request.setAttribute("editNumtel", numtel);
        }
        
       
        request.setAttribute("clients", clientDAO.getAllClients());
        
      
        request.getRequestDispatcher("client.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        String numtel = request.getParameter("numtel");
        String nom = request.getParameter("nom");
        String sexe = request.getParameter("sexe");
        String ageStr = request.getParameter("age");
        String soldeStr = request.getParameter("solde");
        String mail = request.getParameter("mail");
        String code = request.getParameter("code_secret");
        
        boolean success = false;
        String message = "";
        String messageType = "success";
        
        try {
            if ("create".equals(action)) {
               
                if (numtel == null || numtel.trim().isEmpty() || !numtel.matches("[0-9]{10}")) {
                    throw new IllegalArgumentException("Numéro de téléphone invalide (10 chiffres requis)");
                }
                if (nom == null || nom.trim().isEmpty()) {
                    throw new IllegalArgumentException("Le nom est obligatoire");
                }
                if (sexe == null || sexe.trim().isEmpty()) {
                    throw new IllegalArgumentException("Le sexe est obligatoire");
                }
                if (code == null || !code.matches("[0-9]{4}")) {
                    throw new IllegalArgumentException("Le code secret doit contenir 4 chiffres");
                }
                
                int age = Integer.parseInt(ageStr);
                int solde = Integer.parseInt(soldeStr);
                
                success = clientDAO.createClient(numtel, nom, sexe, age, solde, mail, code);
                message = success ? "Client créé avec succès" : "Erreur lors de la création du client";
                
            } else if ("update".equals(action)) {
                
                if (numtel == null || numtel.trim().isEmpty()) {
                    throw new IllegalArgumentException("Numéro de téléphone requis");
                }
                if (nom == null || nom.trim().isEmpty()) {
                    throw new IllegalArgumentException("Le nom est obligatoire");
                }
                
                int age = Integer.parseInt(ageStr);
                int solde = Integer.parseInt(soldeStr);
                
                success = clientDAO.updateClient(numtel, nom, sexe, age, solde, mail);
                message = success ? "Client modifié avec succès" : "Erreur lors de la modification du client";
                
            } else if ("delete".equals(action)) {
                if (numtel == null || numtel.trim().isEmpty()) {
                    throw new IllegalArgumentException("Numéro de téléphone requis pour la suppression");
                }
                
                success = clientDAO.deleteClient(numtel);
                message = success ? "Client supprimé avec succès" : "Erreur lors de la suppression du client";
                
            } else {
                message = "Action non reconnue";
                messageType = "error";
            }
            
        } catch (NumberFormatException e) {
            message = "Format de nombre invalide pour l'âge ou le solde";
            messageType = "error";
        } catch (IllegalArgumentException e) {
            message = e.getMessage();
            messageType = "error";
        } catch (Exception e) {
            message = "Une erreur est survenue : " + e.getMessage();
            messageType = "error";
            e.printStackTrace();
        }
        
       
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);
        
       
        request.setAttribute("clients", clientDAO.getAllClients());
        
       
        request.getRequestDispatcher("client.jsp").forward(request, response);
    }
}