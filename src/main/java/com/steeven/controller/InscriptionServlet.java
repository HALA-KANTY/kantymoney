package com.steeven.controller;

import com.steeven.dao.UserDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/inscrire")
public class InscriptionServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();

    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
      
        List<String[]> liste = userDAO.getAllUsers();
        
       
        request.setAttribute("utilisateurs", liste);
        
      
        request.getRequestDispatcher("inscription.jsp").forward(request, response);
    }

   
    @Override
   

protected void doPost(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
    String action = request.getParameter("action");
    String nom = request.getParameter("nom");
    String email = request.getParameter("email");

    if ("delete".equals(action)) {
        userDAO.deleteUser(email);
    } else if ("update".equals(action)) {
        userDAO.updateUser(nom, email);
    } else {
       
        String password = request.getParameter("password");
        userDAO.registerUser(nom, email, password);
    }
    
    doGet(request, response);
}
}