package com.steeven.controller;

import com.steeven.dao.OperateurStatsDAO;
import com.steeven.util.MoneyFormat;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;

@WebServlet("/operateur/recette-pdf")
public class RecetteOperateurPdfServlet extends HttpServlet {

    private final OperateurStatsDAO dao = new OperateurStatsDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("isOperateur"))) {
            response.sendRedirect(request.getContextPath() + "/operateur/login-operateur.jsp");
            return;
        }

        String period = request.getParameter("period");
        if (period == null || period.isBlank()) period = "month";

        LocalDate start;
        LocalDate end;
        LocalDate today = LocalDate.now();
        switch (period) {
            case "day" -> {
                start = today;
                end = today;
            }
            case "week" -> {
                start = today.minusDays(6);
                end = today;
            }
            case "year" -> {
                int y = today.getYear();
                try { y = Integer.parseInt(request.getParameter("year")); } catch (Exception ignored) {}
                start = LocalDate.of(y, 1, 1);
                end = LocalDate.of(y, 12, 31);
            }
            case "custom" -> {
                try {
                    start = LocalDate.parse(request.getParameter("startDate"));
                    end = LocalDate.parse(request.getParameter("endDate"));
                    if (end.isBefore(start)) {
                        LocalDate t = start; start = end; end = t;
                    }
                } catch (Exception e) {
                    start = today.withDayOfMonth(1);
                    end = today;
                }
            }
            default -> {
                int y = today.getYear();
                int m = today.getMonthValue();
                try { y = Integer.parseInt(request.getParameter("year")); } catch (Exception ignored) {}
                try { m = Integer.parseInt(request.getParameter("month")); } catch (Exception ignored) {}
                if (m < 1 || m > 12) m = today.getMonthValue();
                YearMonth ym = YearMonth.of(y, m);
                start = ym.atDay(1);
                end = ym.atEndOfMonth();
            }
        }

        long[] r = dao.getRecetteBetween(Date.valueOf(start), Date.valueOf(end));
        long fraisEnvoi = r[0];
        long fraisRetrait = r[1];
        long total = r[2];
        long txCount = r[3];

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"recette-operateur.pdf\"");

        try (PDDocument doc = new PDDocument()) {
            PDPage page = new PDPage(PDRectangle.A4);
            doc.addPage(page);
            float x = 50;
            float y = page.getMediaBox().getHeight() - 50;
            try (PDPageContentStream cs = new PDPageContentStream(doc, page)) {
                cs.beginText();
                cs.setFont(PDType1Font.HELVETICA_BOLD, 16);
                cs.newLineAtOffset(x, y);
                cs.showText("Recette operateur");
                cs.endText();

                y -= 24;
                cs.beginText();
                cs.setFont(PDType1Font.HELVETICA, 11);
                cs.newLineAtOffset(x, y);
                cs.showText("Periode: " + start + " au " + end);
                cs.endText();

                y -= 30;
                cs.beginText();
                cs.setFont(PDType1Font.HELVETICA_BOLD, 12);
                cs.newLineAtOffset(x, y);
                cs.showText("Frais d'envoi cumules: " + MoneyFormat.format(fraisEnvoi) + " Ar");
                cs.endText();

                y -= 20;
                cs.beginText();
                cs.setFont(PDType1Font.HELVETICA_BOLD, 12);
                cs.newLineAtOffset(x, y);
                cs.showText("Frais de retrait cumules: " + MoneyFormat.format(fraisRetrait) + " Ar");
                cs.endText();

                y -= 20;
                cs.beginText();
                cs.setFont(PDType1Font.HELVETICA_BOLD, 13);
                cs.newLineAtOffset(x, y);
                cs.showText("Recette totale: " + MoneyFormat.format(total) + " Ar");
                cs.endText();

                y -= 26;
                cs.beginText();
                cs.setFont(PDType1Font.HELVETICA, 11);
                cs.newLineAtOffset(x, y);
                cs.showText("Nombre total de transactions: " + MoneyFormat.format(txCount));
                cs.endText();
            }
            doc.save(response.getOutputStream());
        }
    }
}

