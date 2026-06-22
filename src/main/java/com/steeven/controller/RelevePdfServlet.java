package com.steeven.controller;

import com.steeven.dao.ClientDAO;
import com.steeven.dao.ReleveDAO;
import com.steeven.util.MoneyFormat;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.awt.Color;
import java.io.IOException;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;

@WebServlet("/releve-pdf")
public class RelevePdfServlet extends HttpServlet {

    private final ClientDAO clientDAO = new ClientDAO();
    private final ReleveDAO releveDAO = new ReleveDAO();

    private static final DateTimeFormatter OUT_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter IN1 = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter IN2 = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
    
   
    private static final Color HEADER_BG = new Color(52, 73, 94);
    private static final Color HEADER_TEXT = Color.WHITE;
    private static final Color ALTERNATE_ROW = new Color(245, 247, 250);
    private static final Color BORDER_COLOR = new Color(189, 195, 199);
    private static final Color TOTAL_BG = new Color(236, 240, 241);
    private static final Color DEBIT_COLOR = new Color(231, 76, 60);
    private static final Color CREDIT_COLOR = new Color(46, 204, 113);

    private static String monthLabel(int month) {
        switch (month) {
            case 1: return "Janvier";
            case 2: return "Février";
            case 3: return "Mars";
            case 4: return "Avril";
            case 5: return "Mai";
            case 6: return "Juin";
            case 7: return "Juillet";
            case 8: return "Août";
            case 9: return "Septembre";
            case 10: return "Octobre";
            case 11: return "Novembre";
            case 12: return "Décembre";
            default: return "Mois";
        }
    }

    private static String formatDate(String raw) {
        if (raw == null || raw.isBlank()) return "";
        String s = raw.trim();
        try {
            if (s.length() == 10 && s.charAt(4) == '-' && s.charAt(7) == '-') {
                return LocalDate.parse(s).format(OUT_DATE);
            }
        } catch (Exception ignored) {}
        try {
            return LocalDateTime.parse(s, IN1).toLocalDate().format(OUT_DATE);
        } catch (DateTimeParseException ignored) {}
        try {
            return LocalDateTime.parse(s, IN2).toLocalDate().format(OUT_DATE);
        } catch (DateTimeParseException ignored) {}
        return s;
    }

    private static String toFileSafeName(String rawName) {
        if (rawName == null || rawName.trim().isEmpty()) {
            return "client";
        }
        String normalized = Normalizer.normalize(rawName.trim(), Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        String slug = normalized.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-|-$)", "");
        return slug.isEmpty() ? "client" : slug;
    }

    private static String[] splitLibelle(String lib) {
        if (lib == null || lib.isBlank()) return new String[]{"", ""};
        int idx = lib.indexOf("•");
        if (idx == -1) {
            return new String[]{lib.trim(), ""};
        }
        return new String[]{
            lib.substring(0, idx).trim(),
            lib.substring(idx + 1).trim()
        };
    }

    private static String safeValue(String value) {
        if (value == null || value.isBlank()) {
            return "-";
        }
        return value.trim();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("numtel") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            String numtel = (String) session.getAttribute("numtel");

            int year;
            int month;
            try {
                year = Integer.parseInt(request.getParameter("year"));
                month = Integer.parseInt(request.getParameter("month"));
            } catch (Exception e) {
                YearMonth now = YearMonth.now();
                year = now.getYear();
                month = now.getMonthValue();
            }
            if (month < 1 || month > 12) month = YearMonth.now().getMonthValue();
            if (year < 2000 || year > 2100) year = YearMonth.now().getYear();

            String[] client = clientDAO.getClientByNumtel(numtel);
            if (client == null) {
                response.sendRedirect(request.getContextPath() + "/parametres");
                return;
            }

            List<String[]> rows = releveDAO.getReleveMois(numtel, year, month);
            int totalDebit = 0;
            int totalCredit = 0;
            for (String[] r : rows) {
                try { totalDebit += Integer.parseInt(r[2]); } catch (Exception ignored) {}
                try { totalCredit += Integer.parseInt(r[3]); } catch (Exception ignored) {}
            }

            String nomClient = client[1] != null ? client[1] : "";
            String nomClientSafe = toFileSafeName(nomClient);
            String filename = "releve-" + nomClientSafe + "-" + String.format("%02d", month) + ".pdf";
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

           
            Document document = new Document(PageSize.A4, 30, 30, 30, 30);
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

           
            Font fontTitle = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16, new Color(44, 62, 80));
            Font fontSubtitle = FontFactory.getFont(FontFactory.HELVETICA, 9, new Color(127, 140, 141));
            Font fontHeader = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, HEADER_TEXT);
            Font fontData = FontFactory.getFont(FontFactory.HELVETICA, 8);
            Font fontDataBold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8);
            Font fontSmall = FontFactory.getFont(FontFactory.HELVETICA, 7);
            Font fontFooter = FontFactory.getFont(FontFactory.HELVETICA, 6, new Color(149, 165, 166));

          
            Paragraph headerLine = new Paragraph("KANTYMONEY", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, new Color(52, 152, 219)));
            headerLine.setAlignment(Element.ALIGN_RIGHT);
            headerLine.setSpacingAfter(5);
            document.add(headerLine);

          
            Paragraph titre = new Paragraph("Relevé Mensuel", fontTitle);
            titre.setAlignment(Element.ALIGN_CENTER);
            titre.setSpacingAfter(2);
            document.add(titre);

            Paragraph periode = new Paragraph(monthLabel(month) + " " + year, fontSubtitle);
            periode.setAlignment(Element.ALIGN_CENTER);
            periode.setSpacingAfter(10);
            document.add(periode);

          
            String nom = safeValue(client[1]);
            String sexe = safeValue(client[2]);
            String age = safeValue(client[3]);
            String ageDisplay = "-".equals(age) ? "-" : age + " ans";
            int solde = 0;
            try { solde = Integer.parseInt(client[4]); } catch (Exception ignored) {}

            PdfPTable infoTable = new PdfPTable(2);
            infoTable.setWidthPercentage(100);
            infoTable.setWidths(new float[]{15f, 85f});
            infoTable.setSpacingAfter(10);
            
            addInfoRow(infoTable, "Client", nom);
            addInfoRow(infoTable, "Sexe", sexe);
            addInfoRow(infoTable, "Age", ageDisplay);
            addInfoRow(infoTable, "Téléphone", numtel);
            addInfoRow(infoTable, "Solde actuel", MoneyFormat.format(solde) + " Ar");
            
            document.add(infoTable);

           
            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            table.setWidths(new float[]{10f, 28f, 22f, 10f, 18f});
            table.setSpacingAfter(8);

          
            addTableHeader(table, "Date", fontHeader);
            addTableHeader(table, "Détail", fontHeader);
            addTableHeader(table, "Raison", fontHeader);
            addTableHeader(table, "Type", fontHeader);
            addTableHeader(table, "Montant (Ar)", fontHeader);

          
            boolean alternate = false;
            for (String[] r : rows) {
                String date = formatDate(r[0]);
                String libRaw = r[1] != null ? r[1] : "";
                
                String[] parts = splitLibelle(libRaw);
                String detail = parts[0];
                String raison = parts[1];
                
                int deb = 0;
                int cre = 0;
                try { deb = Integer.parseInt(r[2]); } catch (Exception ignored) {}
                try { cre = Integer.parseInt(r[3]); } catch (Exception ignored) {}
                
                String type;
                String montant;
                Color typeColor;
                Color montantColor;
                
                if (deb > 0) {
                    type = "DÉBIT";
                    montant = MoneyFormat.format(deb);
                    typeColor = DEBIT_COLOR;     
                    montantColor = DEBIT_COLOR;   
                } else if (cre > 0) {
                    type = "CRÉDIT";
                    montant = MoneyFormat.format(cre);
                    typeColor = CREDIT_COLOR;    
                    montantColor = CREDIT_COLOR; 
                } else {
                    type = "-";
                    montant = "0";
                    typeColor = Color.BLACK;
                    montantColor = Color.BLACK;
                }
                
             
                if (detail.length() > 30) detail = detail.substring(0, 27) + "...";
                if (raison.length() > 25) raison = raison.substring(0, 22) + "...";
                
                Color bgColor = alternate ? ALTERNATE_ROW : Color.WHITE;
                
                addDataCell(table, date, fontData, bgColor, Element.ALIGN_CENTER);
                addDataCell(table, detail, fontData, bgColor, Element.ALIGN_LEFT);
                addDataCell(table, raison.isEmpty() ? "-" : raison, raison.isEmpty() ? fontSmall : fontData, bgColor, Element.ALIGN_LEFT);
                
              
                PdfPCell typeCell = new PdfPCell(new Phrase(type, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 7, typeColor)));
                typeCell.setBackgroundColor(bgColor); 
                typeCell.setBorderColor(BORDER_COLOR);
                typeCell.setPadding(3);
                typeCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                typeCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                table.addCell(typeCell);
                
               
                PdfPCell montantCell = new PdfPCell(new Phrase(montant, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, montantColor)));
                montantCell.setBackgroundColor(bgColor);
                montantCell.setBorderColor(BORDER_COLOR);
                montantCell.setPadding(3);
                montantCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
                montantCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
                table.addCell(montantCell);
                
                alternate = !alternate;
            }

            document.add(table);

          
            PdfPTable totalsTable = new PdfPTable(4);
            totalsTable.setWidthPercentage(100);
            totalsTable.setWidths(new float[]{20f, 20f, 20f, 40f});
            totalsTable.setSpacingBefore(5);
            
          
            PdfPCell debitLabel = new PdfPCell(new Phrase("Total Débit :", fontDataBold));
            styleTotalCell(debitLabel);
            totalsTable.addCell(debitLabel);
            
            PdfPCell debitValue = new PdfPCell(new Phrase(MoneyFormat.format(totalDebit) + " Ar", 
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, DEBIT_COLOR)));
            styleTotalCell(debitValue);
            debitValue.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totalsTable.addCell(debitValue);
            
            PdfPCell empty1 = new PdfPCell(new Phrase(""));
            styleTotalCell(empty1);
            totalsTable.addCell(empty1);
            
            PdfPCell empty2 = new PdfPCell(new Phrase(""));
            styleTotalCell(empty2);
            totalsTable.addCell(empty2);
            
           
            PdfPCell creditLabel = new PdfPCell(new Phrase("Total Crédit :", fontDataBold));
            styleTotalCell(creditLabel);
            totalsTable.addCell(creditLabel);
            
            PdfPCell creditValue = new PdfPCell(new Phrase(MoneyFormat.format(totalCredit) + " Ar", 
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, CREDIT_COLOR)));
            styleTotalCell(creditValue);
            creditValue.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totalsTable.addCell(creditValue);
            
            PdfPCell empty3 = new PdfPCell(new Phrase(""));
            styleTotalCell(empty3);
            totalsTable.addCell(empty3);
            
            PdfPCell empty4 = new PdfPCell(new Phrase(""));
            styleTotalCell(empty4);
            totalsTable.addCell(empty4);
            
            document.add(totalsTable);

            document.add(new Paragraph(" "));
            
         
            Paragraph footer = new Paragraph();
            footer.setAlignment(Element.ALIGN_CENTER);
            footer.setSpacingBefore(15);
            footer.add(new Phrase("Document généré le " + LocalDate.now().format(OUT_DATE) + " - ", fontFooter));
            footer.add(new Phrase("KantyMoney © " + YearMonth.now().getYear(), 
                FontFactory.getFont(FontFactory.HELVETICA_BOLD, 6, new Color(52, 152, 219))));
            document.add(footer);

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.reset();
            response.setContentType("text/html;charset=UTF-8");
            java.io.PrintWriter out = response.getWriter();
            out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body>");
            out.println("<h2>Erreur</h2><p>" + e.toString() + "</p></body></html>");
        }
    }
    
    private void addTableHeader(PdfPTable table, String text, Font font) {
        PdfPCell header = new PdfPCell(new Phrase(text, font));
        header.setBackgroundColor(HEADER_BG);
        header.setBorderColor(BORDER_COLOR);
        header.setPadding(5);
        header.setHorizontalAlignment(Element.ALIGN_CENTER);
        header.setVerticalAlignment(Element.ALIGN_MIDDLE);
        table.addCell(header);
    }
    
    private void addDataCell(PdfPTable table, String text, Font font, Color bgColor, int alignment) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(bgColor);
        cell.setBorderColor(BORDER_COLOR);
        cell.setPadding(3);
        cell.setHorizontalAlignment(alignment);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        table.addCell(cell);
    }
    
    private void styleTotalCell(PdfPCell cell) {
        cell.setBackgroundColor(TOTAL_BG);
        cell.setBorderColor(BORDER_COLOR);
        cell.setPadding(4);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
    }
    
    private void addInfoRow(PdfPTable table, String label, String value) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label + " :", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8)));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPadding(2);
        labelCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(labelCell);
        
        PdfPCell valueCell = new PdfPCell(new Phrase(value, FontFactory.getFont(FontFactory.HELVETICA, 8)));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setPadding(2);
        table.addCell(valueCell);
    }
}