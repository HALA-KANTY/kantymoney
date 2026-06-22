package com.steeven.controller;

import com.steeven.dao.FraisEnvoiDAO;
import com.steeven.dao.FraisRecepDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/frais-transactions")
public class ClientFraisTransactionServlet extends HttpServlet {

    private FraisEnvoiDAO fraisEnvoiDAO;
    private FraisRecepDAO fraisRecepDAO;

    @Override
    public void init() {
        fraisEnvoiDAO = new FraisEnvoiDAO();
        fraisRecepDAO = new FraisRecepDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.setAttribute("tranchesEnvoi", fraisEnvoiDAO.getAllFrais());
        request.setAttribute("tranchesRetrait", fraisRecepDAO.getAllFrais());
        request.getRequestDispatcher("/client/frais-transactions.jsp").forward(request, response);
    }
}
