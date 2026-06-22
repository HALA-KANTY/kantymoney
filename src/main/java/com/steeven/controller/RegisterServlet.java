package com.steeven.controller;

import com.steeven.dao.ClientDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private ClientDAO clientDAO = new ClientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
     
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
      
        String numtel = request.getParameter("numtel");
        String nom = request.getParameter("nom");
        String sexe = request.getParameter("sexe");
        String ageStr = request.getParameter("age");
        String mail = request.getParameter("mail");
        String codeSecret = request.getParameter("code_secret");
        
      
        StringBuilder errorMessage = new StringBuilder();
        
      
        if (numtel == null || !numtel.matches("[0-9]{10}")) {
            errorMessage.append("Numéro de téléphone invalide (10 chiffres requis). ");
        }
        
      
        if (nom == null || nom.trim().isEmpty()) {
            errorMessage.append("Le nom est requis. ");
        }
        
       
        if (sexe == null || sexe.trim().isEmpty()) {
            errorMessage.append("Le sexe est requis. ");
        }
        
      
        int age = 0;
        try {
            age = Integer.parseInt(ageStr);
            if (age < 18 || age > 120) {
                errorMessage.append("Âge invalide (doit être entre 18 et 120 ans). ");
            }
        } catch (NumberFormatException e) {
            errorMessage.append("Âge invalide. ");
        }
        
     
        if (mail == null || !mail.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            errorMessage.append("Email invalide. ");
        }
        
       
        if (codeSecret == null || !codeSecret.matches("[0-9]{4}")) {
            errorMessage.append("Le code secret doit contenir exactement 4 chiffres. ");
        }
        
       
        if (errorMessage.length() > 0) {
            request.setAttribute("error", errorMessage.toString());
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        
       
        boolean success = clientDAO.createClient(numtel, nom, sexe, age, 0, mail, codeSecret);
        
        if (success) {
            HttpSession session = request.getSession();
            session.setAttribute("numtel", numtel);
            session.setAttribute("isLoggedIn", true);
            session.setAttribute("success", "Compte créé avec succès !");
            response.sendRedirect(request.getContextPath() + "/client/dashboardclient.jsp");
        } else {
            request.setAttribute("error", "Erreur lors de la création du compte. Veuillez réessayer.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}