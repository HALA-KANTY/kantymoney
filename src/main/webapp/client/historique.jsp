<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.ClientDAO" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<%@ page import="java.util.List" %>
<%!
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;");
    }
%>
<%
    if (session == null || session.getAttribute("numtel") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String numtel = (String) session.getAttribute("numtel");
    ClientDAO clientDAO = new ClientDAO();
    List<String[]> clients = clientDAO.searchClients(numtel);
    String nom = "";
    String initiales = "";
    String numtelFormatte = numtel;
    if (!clients.isEmpty()) {
        String[] client = clients.get(0);
        nom = client[1];
        String[] parts = nom.split("\\s+");
        for (String part : parts) {
            if (!part.isEmpty() && initiales.length() < 2) initiales += part.charAt(0);
        }
    }
    if (numtel != null && numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }

    @SuppressWarnings("unchecked")
    List<String[]> rows = (List<String[]>) request.getAttribute("historiqueRows");
    int total = request.getAttribute("historiqueTotal") != null ? (Integer) request.getAttribute("historiqueTotal") : 0;
    int currentPage = request.getAttribute("historiquePage") != null ? (Integer) request.getAttribute("historiquePage") : 1;
    int totalPages = request.getAttribute("historiqueTotalPages") != null ? (Integer) request.getAttribute("historiqueTotalPages") : 1;
    String filterDate = request.getAttribute("filterDate") != null ? (String) request.getAttribute("filterDate") : "";
    String filterKind = request.getAttribute("filterKind") != null ? (String) request.getAttribute("filterKind") : "all";
    String filterTel = request.getAttribute("filterTel") != null ? (String) request.getAttribute("filterTel") : "";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Historique</title>
    <link rel="stylesheet" href="../style/nav-client.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #faf5f0 100%);
            color: #1A1A1A;
            min-height: 100vh;
            display: flex;
        }

        :root {
            --blanc: #FFFFFF;
            --gris-tres-clair: #F8F9FA;
            --gris-clair: #E9ECEF;
            --gris-moyen: #DEE2E6;
            --gris-fonce: #6C757D;
            --noir-doux: #212529;
            --marron: #C49450;
            --marron-clair: #D4A373;
            --marron-tres-clair: #FDF6ED;
            --vert: #28A745;
            --rouge: #DC3545;
            --bleu: #0D6EFD;
            --orange: #FD7E14;
        }
    .sidebar {
            width: 280px; height: 100vh; position: fixed;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
            color: white; display: flex; flex-direction: column;
            box-shadow: 4px 0 25px rgba(0, 0, 0, 0.1); z-index: 100; overflow: hidden;
        }
        .sidebar-header { padding: 32px 24px 20px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); flex-shrink: 0; }
        .sidebar-header h2 { font-size: 1.8rem; font-weight: 700; letter-spacing: -0.5px; background: linear-gradient(135deg, #C49450, #E8C87A); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
        .sidebar-header span { display: block; font-size: 0.75rem; font-weight: 400; color: #A8B2C1; margin-top: 6px; letter-spacing: 2px; text-transform: uppercase; }
        .user-profile { display: flex; align-items: center; gap: 14px; padding: 24px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); flex-shrink: 0; }
        .user-avatar { width: 50px; height: 50px; background: linear-gradient(135deg, #C49450, #D4A373); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.2rem; color: white; box-shadow: 0 4px 15px rgba(196, 148, 80, 0.3); flex-shrink: 0; }
        .user-info h4 { font-size: 1rem; font-weight: 600; color: white; margin-bottom: 4px; }
        .user-info p { font-size: 0.78rem; color: #A8B2C1; font-weight: 400; }
        .sidebar-nav { flex: 1; padding: 16px 12px; overflow-y: auto; overflow-x: hidden; min-height: 0; }
        .sidebar-nav::-webkit-scrollbar { width: 3px; }
        .sidebar-nav::-webkit-scrollbar-track { background: transparent; }
        .sidebar-nav::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 10px; }
        .nav-section { margin-bottom: 20px; }
        .nav-section-title { font-size: 0.7rem; font-weight: 600; color: #6C7A8D; text-transform: uppercase; letter-spacing: 1.5px; padding: 8px 12px; margin-bottom: 4px; }
        .nav-item { display: flex; align-items: center; gap: 14px; padding: 14px 16px; border-radius: 12px; color: #B0B9C6; text-decoration: none; font-weight: 500; font-size: 0.93rem; transition: all 0.25s; margin-bottom: 4px; white-space: nowrap; }
        .nav-item i { width: 22px; font-size: 1.15rem; text-align: center; flex-shrink: 0; }
        .nav-item:hover { background: rgba(255, 255, 255, 0.06); color: #E8C87A; transform: translateX(4px); }
        .nav-item.active { background: rgba(196, 148, 80, 0.15); color: #E8C87A; font-weight: 600; box-shadow: inset 3px 0 0 #C49450; }
        .nav-item.logout { color: #E8878A; opacity: 0.8; }
        .nav-item.logout:hover { background: rgba(220, 53, 69, 0.1); color: #F4A2A4; }
        .sidebar-footer { padding: 16px 24px; border-top: 1px solid rgba(255, 255, 255, 0.08); font-size: 0.7rem; color: #5A6678; text-align: center; letter-spacing: 0.5px; flex-shrink: 0; }

       
        /* ===== MAIN CONTENT ===== */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 28px 36px;
            min-height: 100vh;
        }

        /* Top Bar avec fond navbar */
        .top-bar {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            border-radius: 20px;
            padding: 22px 32px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 8px 30px rgba(26, 26, 46, 0.2);
        }

        .top-bar h1 {
            font-size: 1.6rem;
            font-weight: 700;
            color: white;
            display: flex;
            align-items: center;
            gap: 14px;
            letter-spacing: -0.3px;
        }

        .top-bar h1 i {
            color: #C49450;
            font-size: 1.5rem;
        }

        .top-bar .result-count {
            font-size: 0.85rem;
            color: #A8B2C1;
            background: rgba(255, 255, 255, 0.1);
            padding: 8px 18px;
            border-radius: 25px;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(255, 255, 255, 0.12);
        }

        /* ===== FILTRES DANS UNE CARTE BLANCHE ===== */
        .filter-card {
            background: white;
            border: 1px solid #E9ECEF;
            border-radius: 18px;
            padding: 20px 24px;
            margin-bottom: 20px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
        }

        .filter-card-title {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #6C757D;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .filter-card-title i {
            color: #C49450;
        }

        .filter-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1.5fr;
            gap: 16px;
            align-items: end;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .filter-group label {
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            color: #6C757D;
        }

        .filter-group input,
        .filter-group select {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #DEE2E6;
            border-radius: 12px;
            font-size: 0.88rem;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s;
            background: #F8F9FA;
            color: #212529;
        }

        .filter-group input:focus,
        .filter-group select:focus {
            outline: none;
            border-color: #C49450;
            background: white;
            box-shadow: 0 0 0 4px rgba(196, 148, 80, 0.08);
        }

        .filter-group input::placeholder {
            color: #ADB5BD;
        }

        .btn-reset {
            padding: 12px 20px;
            border-radius: 12px;
            border: 2px solid #DEE2E6;
            background: white;
            color: #6C757D;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            transition: all 0.25s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            white-space: nowrap;
        }

        .btn-reset:hover {
            border-color: #C49450;
            color: #C49450;
            background: #FDF6ED;
        }

        /* Tableau */
        .table-container {
            background: white;
            border: 1px solid #E9ECEF;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
        }

        .tx-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        .tx-table th, .tx-table td {
            padding: 15px 20px;
            border-bottom: 1px solid #F0F2F5;
            font-size: 0.9rem;
            text-align: left;
        }

        .tx-table th {
            font-size: 0.73rem;
            color: #6C757D;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: #F8F9FA;
            font-weight: 600;
            padding: 14px 20px;
        }

        .tx-table th:first-child { border-radius: 18px 0 0 0; }
        .tx-table th:last-child { border-radius: 0 18px 0 0; }

        .tx-table tbody tr {
            transition: all 0.2s;
        }

        .tx-table tbody tr:hover {
            background: #FDF6ED;
        }

        .tx-table tbody tr:last-child td {
            border-bottom: none;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 600;
            letter-spacing: 0.2px;
        }

        .badge-out { background: #FEF2F2; color: #DC3545; }
        .badge-in { background: #ECFDF3; color: #28A745; }
        .badge-ret { background: #FFF8ED; color: #FD7E14; }

        .cell-ref {
            font-weight: 600;
            color: #1a1a2e;
            font-size: 0.88rem;
        }

        .cell-amount {
            font-weight: 700;
            font-size: 0.9rem;
            letter-spacing: -0.3px;
        }

        .amount-out { color: #DC3545; }
        .amount-in { color: #28A745; }
        .amount-ret { color: #FD7E14; }

        .cell-date {
            color: #6C757D;
            font-size: 0.85rem;
        }

        .cell-tel {
            color: #6C757D;
            font-size: 0.85rem;
        }

        /* Empty State */
        .empty-row td {
            text-align: center;
            padding: 50px 20px !important;
            color: #ADB5BD;
            font-size: 0.95rem;
        }

        .empty-row i {
            font-size: 2.5rem;
            display: block;
            margin-bottom: 12px;
            opacity: 0.3;
            color: #C49450;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 6px;
            padding: 16px 28px;
            border-top: 1px solid #E9ECEF;
            background: #F8F9FA;
        }

        .pagination a,
        .pagination span {
            min-width: 38px;
            height: 38px;
            padding: 0 10px;
            border-radius: 10px;
            font-size: 0.85rem;
            font-weight: 500;
            text-decoration: none;
            color: #212529;
            border: 2px solid #DEE2E6;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.25s;
        }

        .pagination a:hover {
            background: #FDF6ED;
            border-color: #C49450;
            color: #C49450;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(196, 148, 80, 0.15);
        }

        .pagination .active {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            border-color: #1a1a2e;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(26, 26, 46, 0.3);
        }

        .pagination .disabled {
            opacity: 0.3;
            pointer-events: none;
        }

        /* Responsive */
        @media (max-width: 1000px) {
            .sidebar { width: 85px; }
            .sidebar-header h2 { font-size: 1.3rem; }
            .sidebar-header span, .user-info, .nav-section-title, .nav-item span, .sidebar-footer { display: none; }
            .nav-item { justify-content: center; padding: 14px; }
            .nav-item i { font-size: 1.4rem; width: auto; }
            .user-profile { justify-content: center; }
            .main-content { margin-left: 85px; padding: 20px; }
            .filter-grid { grid-template-columns: 1fr 1fr; }
        }

        @media (max-width: 768px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; padding: 16px; }
            .filter-grid { grid-template-columns: 1fr; }
            .top-bar { padding: 18px 20px; }
            .top-bar h1 { font-size: 1.3rem; }
            .tx-table th:nth-child(4),
            .tx-table td:nth-child(4) { display: none; }
        }
    </style>
</head>
<body>
    <!-- SIDEBAR -->
  <aside class="sidebar">
    <div class="sidebar-header"><h2>KantyMoney</h2><span>Espace Client</span></div>
    <div class="user-profile">
        <div class="user-avatar"><%= initiales.toUpperCase() %></div>
        <div class="user-info"><h4><%= nom %></h4><p><%= numtelFormatte %></p></div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section">
            <div class="nav-section-title">Principal</div>
            <a href="<%= request.getContextPath() %>/client/dashboardclient.jsp" class="nav-item"><i class="fas fa-chart-pie"></i><span>Tableau de bord</span></a>
            <a href="<%= request.getContextPath() %>/historique" class="nav-item active"><i class="fas fa-clock-rotate-left"></i><span>Historique</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Transactions</div>
            <a href="<%= request.getContextPath() %>/envoi" class="nav-item "><i class="fas fa-paper-plane"></i><span>Envoyer</span></a>
            <a href="<%= request.getContextPath() %>/retrait" class="nav-item"><i class="fas fa-hand-holding-dollar"></i><span>Retirer</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Outils</div>
            <a href="<%= request.getContextPath() %>/client/releve.jsp" class="nav-item"><i class="fas fa-file-pdf"></i><span>Relevé PDF</span></a>
            <a href="<%= request.getContextPath() %>/frais-transactions" class="nav-item"><i class="fas fa-percent"></i><span>Frais de transaction</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Compte</div>
            <a href="<%= request.getContextPath() %>/parametres" class="nav-item"><i class="fas fa-user-gear"></i><span>Paramètres</span></a>
            <a href="#" class="nav-item logout" onclick="openLogoutModal('<%= request.getContextPath() %>/login?logout=true'); return false;"><i class="fas fa-sign-out-alt"></i><span>Déconnexion</span></a>
        </div>
    </nav>
  
</aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <!-- Top Bar -->
        <div class="top-bar">
            <h1>
                <i class="fas fa-clock-rotate-left"></i>
                Historique des transactions
            </h1>
            <span class="result-count">
                <i class="fas fa-database"></i>
                <%= total %> résultat<%= total > 1 ? "s" : "" %>
                <% if (totalPages > 1) { %> · Page <%= currentPage %>/<%= totalPages %><% } %>
            </span>
        </div>

        <!-- Filtres dans une carte -->
        <div class="filter-card">
            <div class="filter-card-title">
                <i class="fas fa-filter"></i> Filtres
            </div>
            <div class="filter-grid">
                <div class="filter-group">
                    <label for="fkind">Type d'opération</label>
                    <select id="fkind" name="kind" onchange="applyFilter()">
                        <option value="all" <%= "all".equals(filterKind) ? "selected" : "" %>>Toutes les opérations</option>
                        <option value="envoi" <%= "envoi".equals(filterKind) ? "selected" : "" %>>Envois</option>
                        <option value="retrait" <%= "retrait".equals(filterKind) ? "selected" : "" %>>Retraits</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label for="fdate">Date</label>
                    <input type="date" id="fdate" name="date" value="<%= h(filterDate) %>" onchange="applyFilter()">
                </div>
                <div class="filter-group">
                    <label for="ftel">Téléphone ou référence</label>
                    <input type="text" id="ftel" name="tel" placeholder="Ex: 034 12 345 67 ou REF123..." value="<%= h(filterTel) %>" oninput="applyFilterDebounced()">
                </div>
            </div>
            <% if (!filterDate.isEmpty() || !"all".equals(filterKind) || !filterTel.isEmpty()) { %>
            <div style="text-align: right; margin-top: 12px;">
                <button class="btn-reset" onclick="resetFilters()">
                    <i class="fas fa-undo"></i> Réinitialiser les filtres
                </button>
            </div>
            <% } %>
        </div>

        <!-- Tableau -->
        <div class="table-container">
            <table class="tx-table">
                <thead>
                    <tr>
                        <th style="width: 120px;">Type</th>
                        <th style="width: 200px;">ID / Référence</th>
                        <th>Téléphone</th>
                        <th style="width: 140px;">Montant</th>
                        <th style="width: 160px;">Date</th>
                    </tr>
                </thead>
                <tbody>
                <% if (rows != null && !rows.isEmpty()) {
                    for (String[] r : rows) {
                        String tx = r[0];
                        String ref = r[1] != null ? r[1] : "-";
                        String part = r[2] != null ? r[2] : "-";
                        int m = 0;
                        try { m = Integer.parseInt(r[3]); } catch (Exception ignored) {}
                        String dt = r[4] != null ? r[4] : "-";
                        String badgeClass, typeLabel, typeIcon, amtClass;
                        if ("OUT".equals(tx)) {
                            badgeClass = "badge-out"; typeLabel = "Envoi"; typeIcon = "fa-paper-plane";
                            amtClass = "amount-out";
                        } else if ("IN".equals(tx)) {
                            badgeClass = "badge-in"; typeLabel = "Reçu"; typeIcon = "fa-download";
                            amtClass = "amount-in";
                        } else {
                            badgeClass = "badge-ret"; typeLabel = "Retrait"; typeIcon = "fa-hand-holding-dollar";
                            amtClass = "amount-ret";
                        }
                %>
                    <tr>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <i class="fas <%= typeIcon %>"></i>
                                <%= typeLabel %>
                            </span>
                        </td>
                        <td class="cell-ref"><%= h(ref) %></td>
                        <td class="cell-tel"><%= h(part) %></td>
                        <td class="cell-amount <%= amtClass %>"><%= MoneyFormat.format(m) %> Ar</td>
                        <td class="cell-date"><%= h(dt) %></td>
                    </tr>
                <% } } else { %>
                    <tr class="empty-row">
                        <td colspan="5">
                            <i class="fas fa-inbox"></i>
                            Aucune transaction trouvée
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>

            <% if (totalPages > 1) { %>
            <div class="pagination">
                <a href="#" onclick="goToPage(<%= currentPage - 1 %>); return false;" 
                   class="<%= currentPage <= 1 ? "disabled" : "" %>">
                    <i class="fas fa-chevron-left"></i>
                </a>
                
                <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    if (startPage > 1) { 
                %>
                    <a href="#" onclick="goToPage(1); return false;">1</a>
                    <% if (startPage > 2) { %><span>...</span><% } %>
                <% } %>
                
                <% for (int i = startPage; i <= endPage; i++) { %>
                    <a href="#" onclick="goToPage(<%= i %>); return false;" 
                       class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
                <% } %>
                
                <% if (endPage < totalPages) { %>
                    <% if (endPage < totalPages - 1) { %><span>...</span><% } %>
                    <a href="#" onclick="goToPage(<%= totalPages %>); return false;"><%= totalPages %></a>
                <% } %>
                
                <a href="#" onclick="goToPage(<%= currentPage + 1 %>); return false;" 
                   class="<%= currentPage >= totalPages ? "disabled" : "" %>">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </div>
            <% } %>
        </div>
    </main>

    <div id="logoutModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);z-index:2000;align-items:center;justify-content:center;">
        <div style="background:#fff;border-radius:22px;max-width:520px;width:92%;padding:24px;box-shadow:0 24px 60px rgba(20,20,35,.28);text-align:center;position:relative;">
            <button onclick="closeLogoutModal()" style="position:absolute;right:12px;top:12px;border:1px solid #E9ECEF;background:#fff;border-radius:8px;padding:6px 9px;cursor:pointer;"><i class="fas fa-times"></i></button>
            <div style="width:70px;height:70px;border-radius:50%;background:#FFF3E0;color:#FD7E14;display:flex;align-items:center;justify-content:center;font-size:1.9rem;margin:0 auto 12px;"><i class="fas fa-power-off"></i></div>
                <h4 style="margin-bottom:6px;color:#1a1a2e;">Voulez-vous vous déconnecter ?</h4>
                <p style="color:#6C757D;font-size:0.88rem;">Votre session en cours sera fermée.</p>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:16px;">
                    <button class="btn-modal-secondary" style="padding:12px;border-radius:10px;border:2px solid #DEE2E6;background:#fff;cursor:pointer;" onclick="closeLogoutModal()">Annuler</button>
                    <button class="btn-full" style="padding:12px;border-radius:10px;border:none;background:linear-gradient(135deg,#C49450,#D4A373);color:#fff;cursor:pointer;" onclick="confirmLogout()">Se déconnecter</button>
                </div>
        </div>
    </div>

    <script>
        let debounceTimer;
        const baseUrl = '<%= request.getContextPath() %>/historique';
        let logoutTarget = null;
        
        function applyFilter() {
            const kind = document.getElementById('fkind').value;
            const d = document.getElementById('fdate').value;
            const telVal = document.getElementById('ftel').value;
            redirectWithFilters(kind, d, telVal, 1);
        }
        
        function applyFilterDebounced() {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
                const kind = document.getElementById('fkind').value;
                const d = document.getElementById('fdate').value;
                const telVal = document.getElementById('ftel').value;
                redirectWithFilters(kind, d, telVal, 1);
            }, 500);
        }
        
        function resetFilters() {
            window.location.href = baseUrl;
        }
        
        function redirectWithFilters(kind, dateVal, tel, page) {
            let url = baseUrl + '?page=' + page;
            if (kind && kind !== 'all') url += '&kind=' + encodeURIComponent(kind);
            if (dateVal) url += '&date=' + encodeURIComponent(dateVal);
            if (tel) url += '&tel=' + encodeURIComponent(tel);
            window.location.href = url;
        }
        
        function goToPage(page) {
            const kind = document.getElementById('fkind').value;
            const d = document.getElementById('fdate').value;
            const telVal = document.getElementById('ftel').value;
            redirectWithFilters(kind, d, telVal, page);
        }

        function openLogoutModal(url){
            logoutTarget = url;
            document.getElementById('logoutModal').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        function closeLogoutModal(){
            document.getElementById('logoutModal').style.display = 'none';
            document.body.style.overflow = '';
        }
        function confirmLogout(){
            if (logoutTarget) window.location.href = logoutTarget;
        }
    </script>
</body>
</html>