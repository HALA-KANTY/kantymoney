package com.steeven.controller;

import com.steeven.dao.HistoriqueDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/historique")
public class HistoriqueServlet extends HttpServlet {

    private static final int PAGE_SIZE = 8;
    private HistoriqueDAO historiqueDAO;

    @Override
    public void init() {
        historiqueDAO = new HistoriqueDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("numtel") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String numtel = (String) session.getAttribute("numtel");

        String dateFilter = trimOrNull(request.getParameter("date"));
        if (dateFilter == null) {
            dateFilter = trimOrNull(request.getParameter("dateDebut"));
        }
        if (dateFilter == null) {
            dateFilter = trimOrNull(request.getParameter("dateFin"));
        }

        String kind = request.getParameter("kind");
        if (kind != null) {
            kind = kind.trim().toLowerCase();
            if (kind.isEmpty() || "all".equals(kind)) {
                kind = "all";
            } else if (!"envoi".equals(kind) && !"retrait".equals(kind)) {
                kind = "all";
            }
        } else {
            kind = "all";
        }

        String telRaw = request.getParameter("tel");
        String telDigits = null;
        if (telRaw != null && !telRaw.trim().isEmpty()) {
            telDigits = telRaw.replaceAll("\\D", "");
            if (telDigits.isEmpty()) {
                telDigits = null;
            }
        }

        int page = 1;
        try {
            page = Integer.parseInt(request.getParameter("page"));
        } catch (Exception ignored) {
            page = 1;
        }
        if (page < 1) {
            page = 1;
        }

        int total = historiqueDAO.countHistorique(numtel, dateFilter, telDigits, kind);
        int totalPages = (int) Math.ceil(total / (double) PAGE_SIZE);
        if (totalPages == 0) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }
        int offset = (page - 1) * PAGE_SIZE;

        request.setAttribute("historiqueRows", historiqueDAO.listHistorique(numtel, dateFilter, telDigits, kind, offset, PAGE_SIZE));
        request.setAttribute("historiqueTotal", total);
        request.setAttribute("historiquePage", page);
        request.setAttribute("historiqueTotalPages", totalPages);
        request.setAttribute("historiquePageSize", PAGE_SIZE);
        request.setAttribute("filterDate", dateFilter != null ? dateFilter : "");
        request.setAttribute("filterKind", kind);
        request.setAttribute("filterTel", telRaw != null ? telRaw.trim() : "");

        request.getRequestDispatcher("client/historique.jsp").forward(request, response);
    }

    private static String trimOrNull(String s) {
        if (s == null) {
            return null;
        }
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
