<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.ClientDAO" %>
<%@ page import="java.util.List" %>
<%!
    private static String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;");
    }
%>
<%
    // ==================== VÉRIFICATION SESSION ====================
    if (session == null || session.getAttribute("numtel") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    // ==================== INFOS CLIENT ====================
    String numtel = (String) session.getAttribute("numtel");
    ClientDAO clientDAO = new ClientDAO();
    List<String[]> clients = clientDAO.searchClients(numtel);
    
    String nom = "";
    String initiales = "";
    String numtelFormatte = numtel;
    
    if (!clients.isEmpty()) {
        String[] cl = clients.get(0);
        nom = cl[1];
        String[] parts = nom.split("\\s+");
        for (String part : parts) {
            if (!part.isEmpty() && initiales.length() < 2) {
                initiales += part.charAt(0);
            }
        }
    }
    
    if (numtel != null && numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }

    // ==================== GESTION DATE ====================
    java.time.YearMonth now = java.time.YearMonth.now();
    String yearParam = request.getParameter("year");
    String monthParam = request.getParameter("month");
    int year = now.getYear();
    int month = now.getMonthValue();
    try { if (yearParam != null) year = Integer.parseInt(yearParam); } catch (Exception ignored) {}
    try { if (monthParam != null) month = Integer.parseInt(monthParam); } catch (Exception ignored) {}
    if (month < 1 || month > 12) month = now.getMonthValue();
    
    String[] moisNoms = {
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    };
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Relevé PDF</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <style>
        /* ==================== RESET ==================== */
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

        /* ==================== VARIABLES ==================== */
        :root {
            --blanc: #FFFFFF;
            --gris-tres-clair: #F8F9FA;
            --gris-clair: #E9ECEF;
            --gris-moyen: #DEE2E6;
            --gris-fonce: #6C757D;
            --noir-doux: #212529;
            --noir-profond: #1a1a2e;
            --marron: #C49450;
            --marron-clair: #D4A373;
            --marron-tres-clair: #FDF6ED;
            --vert: #28A745;
            --rouge: #DC3545;
            --bleu: #0D6EFD;
            --orange: #FD7E14;
        }

        /* ==================== SIDEBAR ==================== */
        .sidebar {
            width: 280px;
            height: 100vh;
            position: fixed;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            display: flex;
            flex-direction: column;
            box-shadow: 4px 0 25px rgba(0, 0, 0, 0.1);
            z-index: 100;
            overflow: hidden;
        }
        
        .sidebar-header {
            padding: 32px 24px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }
        
        .sidebar-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #C49450, #E8C87A);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .sidebar-header span {
            display: block;
            font-size: 0.75rem;
            font-weight: 400;
            color: #A8B2C1;
            margin-top: 6px;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.2rem;
            color: white;
            box-shadow: 0 4px 15px rgba(196, 148, 80, 0.3);
            flex-shrink: 0;
        }
        
        .user-info h4 {
            font-size: 1rem;
            font-weight: 600;
            color: white;
            margin-bottom: 4px;
        }
        
        .user-info p {
            font-size: 0.78rem;
            color: #A8B2C1;
            font-weight: 400;
        }
        
        .sidebar-nav {
            flex: 1;
            padding: 16px 12px;
            overflow-y: auto;
            overflow-x: hidden;
            min-height: 0;
        }
        
        .sidebar-nav::-webkit-scrollbar {
            width: 3px;
        }
        
        .sidebar-nav::-webkit-scrollbar-track {
            background: transparent;
        }
        
        .sidebar-nav::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }
        
        .nav-section {
            margin-bottom: 20px;
        }
        
        .nav-section-title {
            font-size: 0.7rem;
            font-weight: 600;
            color: #6C7A8D;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            padding: 8px 12px;
            margin-bottom: 4px;
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 16px;
            border-radius: 12px;
            color: #B0B9C6;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.93rem;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            margin-bottom: 4px;
            white-space: nowrap;
        }
        
        .nav-item i {
            width: 22px;
            font-size: 1.15rem;
            text-align: center;
            flex-shrink: 0;
        }
        
        .nav-item:hover {
            background: rgba(255, 255, 255, 0.06);
            color: #E8C87A;
            transform: translateX(4px);
        }
        
        .nav-item.active {
            background: rgba(196, 148, 80, 0.15);
            color: #E8C87A;
            font-weight: 600;
            box-shadow: inset 3px 0 0 #C49450;
        }
        
        .nav-item.logout {
            color: #E8878A;
            opacity: 0.8;
        }
        
        .nav-item.logout:hover {
            background: rgba(220, 53, 69, 0.1);
            color: #F4A2A4;
        }
        
        .sidebar-footer {
            padding: 16px 24px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            font-size: 0.7rem;
            color: #5A6678;
            text-align: center;
            letter-spacing: 0.5px;
            flex-shrink: 0;
        }

        /* ==================== MAIN CONTENT ==================== */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 36px 40px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }
        
        /* ==================== PAGE HEADER ==================== */
        .page-header {
            text-align: center;
            margin-bottom: 36px;
        }
        
        .page-header h1 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--noir-profond);
            letter-spacing: -0.5px;
            margin-bottom: 8px;
        }

        .page-header h1 span {
            background: linear-gradient(135deg, #212529,#212529);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .page-header p {
            color: var(--gris-fonce);
            font-size: 0.92rem;
            font-weight: 400;
        }

        /* ==================== CARD PRINCIPALE ==================== */
        .card {
            background: var(--blanc);
            border: 1px solid var(--gris-clair);
            border-radius: 24px;
            padding: 44px 48px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            width: 100%;
            max-width: 600px;
            transition: all 0.3s;
        }

        .card:hover {
            border-color: var(--marron-clair);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
        }

        /* ==================== ICÔNE PDF ==================== */
        .card-icon-wrapper {
            text-align: center;
            margin-bottom: 28px;
        }
        
        .card-icon {
            width: 88px;
            height: 88px;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            border-radius: 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 2.4rem;
            color: #DC3545;
            box-shadow: 0 8px 25px rgba(26, 26, 46, 0.2);
        }

        /* ==================== TITRE CARD ==================== */
        .card-title {
            text-align: center;
            margin-bottom: 28px;
        }
        
        .card-title h2 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--noir-profond);
            margin-bottom: 6px;
        }
        
        .card-title p {
            color: var(--gris-fonce);
            font-size: 0.88rem;
        }

        /* ==================== BADGE MOIS ==================== */
        .current-month-badge {
            text-align: center;
            margin-bottom: 24px;
            font-size: 0.88rem;
            color: var(--marron);
            font-weight: 600;
            background: var(--marron-tres-clair);
            display: inline-block;
            padding: 10px 20px;
            border-radius: 20px;
            border: 1px solid rgba(196, 148, 80, 0.2);
        }
        
        .current-month-badge i {
            margin-right: 6px;
        }

        /* ==================== FORMULAIRE ==================== */
        .form-container {
            width: 100%;
        }

        .badge-wrapper {
            text-align: center;
            margin-bottom: 24px;
        }

        .form-row {
            display: flex;
            gap: 16px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        
        .form-group {
            flex: 1;
            min-width: 160px;
        }
        
        .form-group label {
            display: block;
            font-size: 0.84rem;
            font-weight: 600;
            color: var(--noir-profond);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .form-group label i {
            color: var(--marron);
            font-size: 0.9rem;
        }
        
        .form-group select,
        .form-group input {
            width: 100%;
            padding: 13px 16px;
            border: 2px solid var(--gris-moyen);
            border-radius: 12px;
            font-size: 0.92rem;
            font-family: 'Inter', sans-serif;
            background: var(--gris-tres-clair);
            transition: all 0.25s;
        }
        
        .form-group select:focus,
        .form-group input:focus {
            outline: none;
            border-color: var(--marron);
            background: white;
            box-shadow: 0 0 0 4px rgba(196, 148, 80, 0.06);
        }
        
        .form-group select {
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%236C757D' viewBox='0 0 16 16'%3E%3Cpath d='M8 11L3 6h10z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 40px;
        }

        /* ==================== BOUTON ==================== */
        .btn-download {
            padding: 14px 34px;
            background: linear-gradient(135deg, #DC3545, #E5535D);
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            font-family: 'Inter', sans-serif;
            box-shadow: 0 6px 25px rgba(220, 53, 69, 0.25);
            white-space: nowrap;
            height: 49px;
        }
        
        .btn-download:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(220, 53, 69, 0.35);
        }
        
        .btn-download i {
            font-size: 1.1rem;
        }

        /* ==================== INFO BOX ==================== */
        .info-box {
            margin-top: 28px;
            padding: 18px 22px;
            background: var(--marron-tres-clair);
            border-radius: 14px;
            border: 1px solid rgba(196, 148, 80, 0.15);
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }
        
        .info-box .info-icon {
            color: var(--marron);
            font-size: 1.3rem;
            margin-top: 2px;
            flex-shrink: 0;
        }
        
        .info-box .info-content h4 {
            font-size: 0.88rem;
            font-weight: 600;
            color: var(--noir-profond);
            margin-bottom: 4px;
        }
        
        .info-box .info-content p {
            font-size: 0.82rem;
            color: var(--gris-fonce);
            line-height: 1.5;
        }

        /* ==================== RESPONSIVE ==================== */
        @media (max-width: 1000px) {
            .sidebar {
                width: 80px;
            }
            .sidebar-header span,
            .sidebar-header h2,
            .user-info,
            .nav-section-title,
            .nav-item span,
            .sidebar-footer {
                display: none;
            }
            .nav-item {
                justify-content: center;
                padding: 14px;
            }
            .nav-item i {
                font-size: 1.4rem;
                width: auto;
            }
            .user-profile {
                justify-content: center;
            }
            .main-content {
                margin-left: 80px;
                padding: 24px;
            }
        }
        
        @media (max-width: 768px) {
            .main-content {
                margin-left: 0;
                padding: 24px 16px;
            }
            .card {
                padding: 28px 20px;
                max-width: 100%;
            }
            .form-row {
                flex-direction: column;
            }
            .btn-download {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>

<!-- ==================== SIDEBAR ==================== -->
<aside class="sidebar">
    <div class="sidebar-header">
        <h2>KantyMoney</h2>
        <span>Espace Client</span>
    </div>
    
    <div class="user-profile">
        <div class="user-avatar">
            <span><%= initiales.toUpperCase() %></span>
        </div>
        <div class="user-info">
            <h4><%= h(nom) %></h4>
            <p><%= h(numtelFormatte) %></p>
        </div>
    </div>
    
    <nav class="sidebar-nav">
        <div class="nav-section">
            <div class="nav-section-title">Principal</div>
            <a href="<%= request.getContextPath() %>/client/dashboardclient.jsp" class="nav-item">
                <i class="fas fa-chart-pie"></i>
                <span>Tableau de bord</span>
            </a>
            <a href="<%= request.getContextPath() %>/historique" class="nav-item">
                <i class="fas fa-clock-rotate-left"></i>
                <span>Historique</span>
            </a>
        </div>
        
        <div class="nav-section">
            <div class="nav-section-title">Transactions</div>
            <a href="<%= request.getContextPath() %>/envoi" class="nav-item">
                <i class="fas fa-paper-plane"></i>
                <span>Envoyer</span>
            </a>
            <a href="<%= request.getContextPath() %>/retrait" class="nav-item">
                <i class="fas fa-hand-holding-dollar"></i>
                <span>Retirer</span>
            </a>
        </div>
        
        <div class="nav-section">
            <div class="nav-section-title">Outils</div>
            <a href="<%= request.getContextPath() %>/client/releve.jsp" class="nav-item active">
                <i class="fas fa-file-pdf"></i>
                <span>Relevé PDF</span>
            </a>
            <a href="<%= request.getContextPath() %>/frais-transactions" class="nav-item">
                <i class="fas fa-percent"></i>
                <span>Frais de transaction</span>
            </a>
        </div>
        
        <div class="nav-section">
            <div class="nav-section-title">Compte</div>
            <a href="<%= request.getContextPath() %>/parametres" class="nav-item">
                <i class="fas fa-user-gear"></i>
                <span>Paramètres</span>
            </a>
            <a href="#" class="nav-item logout" onclick="openLogoutModal('<%= request.getContextPath() %>/login?logout=true'); return false;">
                <i class="fas fa-sign-out-alt"></i>
                <span>Déconnexion</span>
            </a>
        </div>
    </nav>
    
   
</aside>

<!-- ==================== MAIN CONTENT ==================== -->
<main class="main-content">
    <div class="page-header">
        <h1>
            <span>Relevé mensuel PDF</span>
        </h1>
       
    </div>

    <div class="card">
        <div class="card-icon-wrapper">
            <div class="card-icon">
                <i class="fas fa-file-pdf"></i>
            </div>
        </div>
        
        <div class="card-title">
            <h2>Télécharger un relevé</h2>
            <p>Sélectionnez le mois et l'année pour générer votre relevé</p>
        </div>

        <div class="form-container">
            <div class="badge-wrapper">
                <span class="current-month-badge">
                    <i class="fas fa-calendar-check"></i>
                    Mois actuel : <strong><%= moisNoms[month - 1] %> <%= year %></strong>
                </span>
            </div>
            
            <form method="get" action="<%= request.getContextPath() %>/releve-pdf">
                <div class="form-row">
                    <div class="form-group">
                        <label for="month">
                            <i class="fas fa-calendar-alt"></i>
                            Mois
                        </label>
                        <select id="month" name="month">
                            <% for (int m = 1; m <= 12; m++) { %>
                                <option value="<%= m %>" <%= (m == month) ? "selected" : "" %>>
                                    <%= moisNoms[m - 1] %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="year">
                            <i class="fas fa-calendar"></i>
                            Année
                        </label>
                        <input type="number" id="year" name="year" min="2000" max="2100" 
                               value="<%= year %>" placeholder="2026">
                    </div>
                    
                    <div class="form-group" style="display: flex; align-items: flex-end;">
                        <button type="submit" class="btn-download">
                            <i class="fas fa-download"></i>
                            Télécharger le PDF
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <div class="info-box">
            <div class="info-icon">
                <i class="fas fa-info-circle"></i>
            </div>
            <div class="info-content">
                <h4>Informations sur le relevé</h4>
                <p>
                    Le relevé PDF contient le détail de tous vos mouvements du mois sélectionné 
                    (envois, réceptions et retraits) avec les totaux débiteurs et créditeurs. 
                    Le document est généré instantanément au format A4.
                </p>
            </div>
        </div>
    </div>
</main>

<div id="logoutModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);z-index:2000;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:22px;max-width:520px;width:92%;padding:24px;box-shadow:0 24px 60px rgba(20,20,35,.28);text-align:center;position:relative;">
        <button onclick="closeLogoutModal()" style="position:absolute;right:12px;top:12px;border:1px solid #E9ECEF;background:#fff;border-radius:8px;padding:6px 9px;cursor:pointer;"><i class="fas fa-times"></i></button>
        <div style="width:70px;height:70px;border-radius:50%;background:#FFF3E0;color:#FD7E14;display:flex;align-items:center;justify-content:center;font-size:1.9rem;margin:0 auto 12px;"><i class="fas fa-power-off"></i></div>
        <h4 style="margin-bottom:6px;color:#1a1a2e;">Voulez-vous vous déconnecter ?</h4>
        <p style="color:#6C757D;font-size:0.88rem;">Votre session en cours sera fermée.</p>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:16px;">
            <button style="padding:12px;border-radius:10px;border:2px solid #DEE2E6;background:#fff;cursor:pointer;" onclick="closeLogoutModal()">Annuler</button>
            <button style="padding:12px;border-radius:10px;border:none;background:linear-gradient(135deg,#C49450,#D4A373);color:#fff;cursor:pointer;" onclick="confirmLogout()">Se déconnecter</button>
        </div>
    </div>
</div>
<script>
    let logoutTarget = null;
    function openLogoutModal(url){ logoutTarget = url; document.getElementById('logoutModal').style.display = 'flex'; document.body.style.overflow = 'hidden'; }
    function closeLogoutModal(){ document.getElementById('logoutModal').style.display = 'none'; document.body.style.overflow = ''; }
    function confirmLogout(){ if (logoutTarget) window.location.href = logoutTarget; }
</script>

</body>
</html>