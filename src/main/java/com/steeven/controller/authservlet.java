package com.steeven.controller;

import com.steeven.dao.OperateurDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/auth")
public class authservlet extends HttpServlet {
    private OperateurDAO operateurDAO = new OperateurDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect("operateur/login-operateur.jsp?logout=true");
        } else {
            response.sendRedirect("operateur/login-operateur.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("login".equals(action)) {
            request.setCharacterEncoding("UTF-8");
            
            String mail = request.getParameter("mail");
            String motDePasse = request.getParameter("mot_de_passe");
            
            if (mail == null || mail.trim().isEmpty()) {
                request.setAttribute("error", "Veuillez saisir votre email");
                request.getRequestDispatcher("operateur/login-operateur.jsp").forward(request, response);
                return;
            }
            
            if (motDePasse == null || motDePasse.trim().isEmpty()) {
                request.setAttribute("error", "Veuillez saisir votre mot de passe");
                request.setAttribute("mail", mail);
                request.getRequestDispatcher("login-operateur.jsp").forward(request, response);
                return;
            }
            
            boolean isValid = operateurDAO.verifyCredentials(mail, motDePasse);
            
            if (isValid) {
                String[] operateur = operateurDAO.getOperateurByMail(mail);
                
                if (operateur != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("operateurMail", mail);
                    session.setAttribute("operateurNom", operateur[1]);
                    session.setAttribute("operateurTel", operateur[0]);
                    session.setAttribute("isOperateur", true);
                    session.setMaxInactiveInterval(30 * 60);
                    
                    response.sendRedirect("operateur/dashboardOperateur.jsp");
                } else {
                    request.setAttribute("error", "Erreur lors de la récupération des informations");
                    request.getRequestDispatcher("login-operateur.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Email ou mot de passe incorrect");
                request.setAttribute("mail", mail);
                request.getRequestDispatcher("operateur/login-operateur.jsp").forward(request, response);
            }
        } else {
            response.sendRedirect("operateur/login-operateur.jsp");
        }
    }
}