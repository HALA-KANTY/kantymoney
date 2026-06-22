package com.steeven.controller;

import com.steeven.dao.ClientDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private ClientDAO clientDAO = new ClientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String logout = request.getParameter("logout");
        if ("true".equalsIgnoreCase(logout)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            Cookie numtelCookie = new Cookie("numtel", "");
            numtelCookie.setMaxAge(0);
            numtelCookie.setPath("/");
            response.addCookie(numtelCookie);
        }
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        String numtel = request.getParameter("numtel");
        String codeSecret = request.getParameter("code_secret");
        String remember = request.getParameter("remember");
        
       
        if (numtel == null || !numtel.matches("[0-9]{10}")) {
            request.setAttribute("error", "Numéro de téléphone invalide");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        if (codeSecret == null || !codeSecret.matches("[0-9]{4}")) {
            request.setAttribute("error", "Code secret invalide");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
    
        boolean isValid = clientDAO.verifyCredentials(numtel, codeSecret);
        
        if (isValid) {
           
            HttpSession session = request.getSession();
            session.setAttribute("numtel", numtel);
            session.setAttribute("isLoggedIn", true);
            
        
            if ("on".equals(remember)) {
                Cookie numtelCookie = new Cookie("numtel", numtel);
                numtelCookie.setMaxAge(30 * 24 * 60 * 60); 
                response.addCookie(numtelCookie);
            }
            
           
            response.sendRedirect(request.getContextPath() + "/client/dashboardclient.jsp");
        } else {
            request.setAttribute("error", "Numéro de téléphone ou code secret incorrect");
            request.setAttribute("numtel", numtel); 
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}