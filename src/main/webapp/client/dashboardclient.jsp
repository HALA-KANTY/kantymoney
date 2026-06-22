<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.ClientDAO" %>
<%@ page import="com.steeven.dao.HistoriqueDAO" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<%@ page import="java.util.List" %>
<%!
    private static String fmtTelDash(String t) {
        if (t == null) return "";
        String d = t.replaceAll("\\D", "");
        if (d.length() == 10) {
            return d.substring(0, 3) + " " + d.substring(3, 5) + " " + d.substring(5, 8) + " " + d.substring(8);
        }
        return t;
    }
%>
<%
    // Vérifier si l'utilisateur est connecté
    if (session == null || session.getAttribute("numtel") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String numtel = (String) session.getAttribute("numtel");
    
    // Récupérer les infos du client connecté
    ClientDAO clientDAO = new ClientDAO();
    List<String[]> clients = clientDAO.searchClients(numtel);
    
    String nom = "";
    String solde = "0";
    String email = "";
    String sexe = "";
    
    if (!clients.isEmpty()) {
        String[] client = clients.get(0);
        nom = client[1];       // nom
        sexe = client[2];      // sexe
        solde = client[4];     // solde
        email = client[5];     // mail
    }

    HistoriqueDAO historiqueDAO = new HistoriqueDAO();
    List<String[]> recentTx = historiqueDAO.getRecent(numtel, 3);
    int[] statsMois = historiqueDAO.getStatsMoisCourant(numtel);
    int envoyeMois = statsMois[0];
    int recuMois = statsMois[1];
    int retireMois = statsMois[2];
    int nbTxMois = statsMois[3];
    
    // Initiales pour l'avatar
    String initiales = "";
    if (!nom.isEmpty()) {
        String[] parts = nom.split(" ");
        for (String part : parts) {
            if (!part.isEmpty() && initiales.length() < 2) {
                initiales += part.charAt(0);
            }
        }
    }
    
    // Formater le numéro pour l'affichage (ex: 032 44 321 67)
    String numtelFormatte = numtel;
    if (numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }
    
    // Formater le solde avec séparateur de milliers (1 000 / 10 000 / 1 000 000)
    String soldeFormatte = MoneyFormat.formatNullable(solde);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Espace Client</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav-client.css">
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

        /* ===== SIDEBAR (Sans scroll) ===== */
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
            overflow: hidden; /* Empêche tout scroll dans la sidebar */
        }

        .sidebar-header {
            padding: 32px 24px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0; /* Empêche le header de rétrécir */
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
            flex-shrink: 0; /* Empêche le profil de rétrécir */
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
            color: #A8B2C1;
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
            overflow-y: hidden; /* Scroll vertical uniquement si nécessaire */
            overflow-x: hidden; /* Pas de scroll horizontal */
            min-height: 0; /* Important pour que flex fonctionne correctement */
        }

        /* Personnalisation du scroll vertical (fin et discret) */
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

        .sidebar-nav::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.2);
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
            position: relative;
            white-space: nowrap; /* Empêche le texte de passer à la ligne */
        }

        .nav-item i {
            width: 22px;
            font-size: 1.15rem;
            text-align: center;
            transition: all 0.25s;
            flex-shrink: 0; /* Empêche l'icône de rétrécir */
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
            flex-shrink: 0; /* Empêche le footer de rétrécir */
        }

        /* ===== MAIN CONTENT ===== */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 36px 40px;
            min-height: 100vh;
        }

        /* Header */
        .dashboard-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 36px;
        }

        .header-greeting h1 {
            font-size: 2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }

        .header-greeting h1 span {
            background: linear-gradient(135deg, #C49450, #D4A373);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .header-greeting p {
            color: #6C757D;
            font-size: 0.92rem;
            font-weight: 400;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .notification-btn {
            position: relative;
            width: 48px;
            height: 48px;
            background: white;
            border: 1px solid #E9ECEF;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6C757D;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }

        .notification-btn:hover {
            border-color: #C49450;
            color: #C49450;
            box-shadow: 0 4px 15px rgba(196, 148, 80, 0.1);
        }

        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            font-size: 0.65rem;
            font-weight: 700;
            padding: 3px 7px;
            border-radius: 20px;
            box-shadow: 0 2px 8px rgba(196, 148, 80, 0.3);
        }

        .quick-action {
            padding: 13px 22px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            border: none;
            border-radius: 14px;
            font-weight: 600;
            font-size: 0.92rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            text-decoration: none;
            box-shadow: 0 4px 20px rgba(196, 148, 80, 0.2);
        }

        .quick-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(196, 148, 80, 0.3);
        }

        /* Solde Card */
        .balance-card {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            border-radius: 28px;
            padding: 36px 40px;
            color: white;
            margin-bottom: 36px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 20px 50px rgba(26, 26, 46, 0.15);
            position: relative;
            overflow: hidden;
        }

        .balance-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, rgba(196, 148, 80, 0.1) 0%, transparent 70%);
            border-radius: 50%;
        }

        .balance-info {
            position: relative;
            z-index: 1;
        }

        .balance-info h3 {
            font-size: 0.9rem;
            font-weight: 500;
            opacity: 0.8;
            margin-bottom: 10px;
            letter-spacing: 0.5px;
        }

        .balance-amount {
            font-size: 3.2rem;
            font-weight: 800;
            letter-spacing: -1px;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #FFFFFF, #D4A373);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .balance-amount small {
            font-size: 1.4rem;
            font-weight: 600;
            opacity: 0.7;
            background: none;
            -webkit-text-fill-color: rgba(255, 255, 255, 0.7);
        }

        .balance-phone {
            font-size: 0.88rem;
            opacity: 0.75;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .balance-actions {
            display: flex;
            gap: 14px;
            position: relative;
            z-index: 1;
        }

        .balance-btn {
            padding: 16px 28px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 16px;
            color: white;
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            text-decoration: none;
            backdrop-filter: blur(10px);
        }

        .balance-btn:hover {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.4);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 22px;
            margin-bottom: 36px;
        }

        .stat-card {
            background: white;
            border: 1px solid #E9ECEF;
            border-radius: 22px;
            padding: 24px;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
        }

        .stat-card:hover {
            border-color: #D4A373;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
            transform: translateY(-4px);
        }

        .stat-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #FDF6ED, #FFF8F0);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #C49450;
            font-size: 1.5rem;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }

        .stat-label {
            font-size: 0.82rem;
            color: #6C757D;
            font-weight: 500;
        }

        /* Transactions récentes */
        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
        }

        .section-header h2 {
            font-size: 1.4rem;
            font-weight: 700;
            color: #1a1a2e;
        }

        .section-header a {
            color: #C49450;
            text-decoration: none;
            font-size: 0.92rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }

        .section-header a:hover {
            gap: 12px;
            color: #B8873E;
        }

        .transactions-list {
            background: white;
            border: 1px solid #E9ECEF;
            border-radius: 22px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
        }

        .transaction-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 28px;
            border-bottom: 1px solid #F0F2F5;
            transition: all 0.2s;
        }

        .transaction-item:last-child {
            border-bottom: none;
        }

        .transaction-item:hover {
            background: #FAFBFC;
        }

        .transaction-info {
            display: flex;
            align-items: center;
            gap: 18px;
        }

        .transaction-icon {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }

        .transaction-icon.send {
            background: #FEF2F2;
            color: #DC3545;
        }

        .transaction-icon.receive {
            background: #F0FDF4;
            color: #28A745;
        }

        .transaction-icon.withdraw {
            background: #FFF3E0;
            color: #FD7E14;
        }

        .transaction-details h4 {
            font-size: 1rem;
            font-weight: 600;
            color: #1a1a2e;
            margin-bottom: 6px;
        }

        .transaction-details p {
            font-size: 0.82rem;
            color: #6C757D;
            font-weight: 400;
        }

        .transaction-amount {
            text-align: right;
        }

        .transaction-amount .amount {
            font-size: 1.15rem;
            font-weight: 700;
            margin-bottom: 6px;
            letter-spacing: -0.3px;
        }

        .transaction-amount.send .amount {
            color: #DC3545;
        }

        .transaction-amount.receive .amount {
            color: #28A745;
        }

        .transaction-amount .date {
            font-size: 0.78rem;
            color: #6C757D;
        }

        /* Services rapides */
        .quick-services {
            margin-top: 36px;
        }

        .services-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
        }

        .service-card {
            background: white;
            border: 1px solid #E9ECEF;
            border-radius: 20px;
            padding: 22px;
            text-align: center;
            text-decoration: none;
            color: inherit;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
        }

        .service-card:hover {
            border-color: #C49450;
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
        }

        .service-card i {
            font-size: 2rem;
            color: #C49450;
            margin-bottom: 14px;
        }

        .service-card h4 {
            font-size: 0.92rem;
            font-weight: 600;
            color: #1a1a2e;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .services-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 900px) {
            .sidebar {
                width: 90px;
            }
            .sidebar-header h2 {
                font-size: 1.4rem;
            }
            .sidebar-header span,
            .user-info,
            .nav-section-title,
            .nav-item span,
            .sidebar-footer {
                display: none;
            }
            .nav-item {
                justify-content: center;
                padding: 16px;
            }
            .nav-item i {
                font-size: 1.5rem;
                width: auto;
            }
            .user-profile {
                justify-content: center;
            }
            .main-content {
                margin-left: 90px;
                padding: 24px;
            }
        }

        @media (max-width: 700px) {
            .balance-card {
                flex-direction: column;
                text-align: center;
                gap: 28px;
                padding: 28px 24px;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
            .transaction-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 14px;
            }
            .transaction-amount {
                text-align: left;
                width: 100%;
            }
            .services-grid {
                grid-template-columns: 1fr;
            }
            .dashboard-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 18px;
            }
        }
    </style>
</head>
<body>
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h2>KantyMoney</h2>
            <span>Espace Client</span>
        </div>
        
        <div class="user-profile">
            <div class="user-avatar">
                <span><%= initiales %></span>
            </div>
            <div class="user-info">
                <h4><%= nom %></h4>
                <p><%= numtelFormatte %></p>
            </div>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Principal</div>
                <a href="dashboardclient.jsp" class="nav-item active">
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
                <a href="<%= request.getContextPath() %>/client/releve.jsp" class="nav-item">
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
    
    <!-- MAIN CONTENT -->
    <main class="main-content">
       
               
        <!-- Solde Card -->
        <div class="balance-card">
            <div class="balance-info">
                <h3>Solde disponible</h3>
                <div class="balance-amount"><%= soldeFormatte %> <small>Ar</small></div>
                <div class="balance-phone">
                    <i class="fas fa-mobile-alt"></i> <%= numtelFormatte %>
                </div>
            </div>
            <div class="balance-actions">
                <a href="<%= request.getContextPath() %>/envoi" class="balance-btn">
                    <i class="fas fa-paper-plane"></i>
                    Envoyer
                </a>
                <a href="<%= request.getContextPath() %>/retrait" class="balance-btn">
                    <i class="fas fa-hand-holding-dollar"></i>
                    Retirer
                </a>
            </div>
        </div>
        
        <!-- Stats (mois en cours, données réelles) -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">
                        <i class="fas fa-paper-plane"></i>
                    </div>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(envoyeMois) %> Ar</div>
                <div class="stat-label">Envoyés ce mois</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">
                        <i class="fas fa-download"></i>
                    </div>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(recuMois) %> Ar</div>
                <div class="stat-label">Reçus ce mois</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">
                        <i class="fas fa-hand-holding-dollar"></i>
                    </div>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(retireMois) %> Ar</div>
                <div class="stat-label">Retirés ce mois</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon">
                        <i class="fas fa-arrow-trend-up"></i>
                    </div>
                </div>
                <div class="stat-value"><%= nbTxMois %></div>
                <div class="stat-label">Transactions ce mois</div>
            </div>
        </div>
        
        <!-- Transactions récentes (3 derniers mouvements réels) -->
        <div class="section-header">
            <h2>Transactions récentes</h2>
            <a href="<%= request.getContextPath() %>/historique">
                Voir tout
                <i class="fas fa-arrow-right"></i>
            </a>
        </div>
        
        <div class="transactions-list">
            <% if (recentTx != null && !recentTx.isEmpty()) {
                for (String[] row : recentTx) {
                    String tx = row[0];
                    String ref = row[1] != null ? row[1] : "";
                    String part = row[2] != null ? row[2] : "";
                    int m = 0;
                    try { m = Integer.parseInt(row[3]); } catch (Exception ignored) {}
                    String dt = row[4] != null ? row[4] : "";
                    String nomPart = null;
                    if (!"RET".equals(tx) && part.length() >= 10) {
                        String[] autre = clientDAO.getClientByNumtel(part.replaceAll("\\D", ""));
                        if (autre != null) nomPart = autre[1];
                    }
                    String titre;
                    String sous;
                    String iconWrap;
                    String amtClass;
                    String amtSign;
                    if ("OUT".equals(tx)) {
                        titre = nomPart != null ? "Envoi à " + nomPart : "Envoi vers " + fmtTelDash(part);
                        sous = fmtTelDash(part);
                        iconWrap = "send";
                        amtClass = "send";
                        amtSign = "-";
                    } else if ("IN".equals(tx)) {
                        titre = nomPart != null ? "Reçu de " + nomPart : "Reçu de " + fmtTelDash(part);
                        sous = fmtTelDash(part);
                        iconWrap = "receive";
                        amtClass = "receive";
                        amtSign = "+";
                    } else {
                        titre = "Retrait";
                        sous = ref;
                        iconWrap = "withdraw";
                        amtClass = "send";
                        amtSign = "-";
                    }
            %>
            <div class="transaction-item">
                <div class="transaction-info">
                    <div class="transaction-icon <%= iconWrap %>">
                        <% if ("OUT".equals(tx)) { %><i class="fas fa-paper-plane"></i><% } else if ("IN".equals(tx)) { %><i class="fas fa-download"></i><% } else { %><i class="fas fa-hand-holding-dollar"></i><% } %>
                    </div>
                    <div class="transaction-details">
                        <h4><%= titre %></h4>
                        <p><%= sous %></p>
                    </div>
                </div>
                <div class="transaction-amount <%= amtClass %>">
                    <div class="amount"><%= amtSign %><%= MoneyFormat.format(m) %> Ar</div>
                    <div class="date"><%= dt %></div>
                </div>
            </div>
            <% } } else { %>
            <div class="transaction-item" style="justify-content:center;padding:32px;color:var(--gris-fonce);">
                <i class="fas fa-inbox" style="font-size:2rem;opacity:0.3;margin-right:12px;"></i>
                Aucune transaction pour le moment. 
                <a href="<%= request.getContextPath() %>/envoi" style="color:var(--marron);font-weight:700;margin-left:10px;text-decoration:none;">
                    Faire un premier envoi →
                </a>
            </div>
            <% } %>
        </div>
        
       
    </main>

    <style>
        .logout-overlay{position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);display:none;align-items:center;justify-content:center;z-index:2000}
        .logout-overlay.show{display:flex}
        .logout-box{background:#fff;border-radius:22px;max-width:520px;width:92%;padding:24px;box-shadow:0 24px 60px rgba(20,20,35,.28);text-align:center}
        .logout-ico{width:70px;height:70px;border-radius:50%;background:#FFF3E0;color:#FD7E14;display:flex;align-items:center;justify-content:center;font-size:1.9rem;margin:0 auto 12px}
        .logout-actions{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:16px}
        .logout-btn{padding:12px;border-radius:10px;border:2px solid #DEE2E6;background:#fff;font-weight:600;cursor:pointer}
        .logout-btn.primary{background:linear-gradient(135deg,#C49450,#D4A373);border:none;color:#fff}
    </style>
    <div class="logout-overlay" id="logoutModal">
        <div class="logout-box">
            <div class="logout-ico"><i class="fas fa-power-off"></i></div>
            <h3 style="margin-bottom:6px;">Voulez-vous vous déconnecter ?</h3>
            <p style="color:#6C757D;font-size:.9rem;">Votre session en cours sera fermée.</p>
            <div class="logout-actions">
                <button class="logout-btn" onclick="closeLogoutModal()">Annuler</button>
                <button class="logout-btn primary" onclick="confirmLogout()">Se déconnecter</button>
            </div>
        </div>
    </div>
    <script>
        let logoutTarget = null;
        function openLogoutModal(url){ logoutTarget = url; document.getElementById('logoutModal').classList.add('show'); }
        function closeLogoutModal(){ document.getElementById('logoutModal').classList.remove('show'); }
        function confirmLogout(){ if (logoutTarget) window.location.href = logoutTarget; }
          // ==== FONCTION D'ACTUALISATION EN TEMPS RÉEL ====
    function rafraichirDashboard() {
        fetch(window.location.href, {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(response => response.text())
        .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            
            // Actualiser le solde
            const nouveauSolde = doc.querySelector('.balance-amount');
            if (nouveauSolde) {
                document.querySelector('.balance-amount').innerHTML = nouveauSolde.innerHTML;
            }
            
            // Actualiser les 4 stats
            const nouvellesStats = doc.querySelectorAll('.stat-value');
            const statsActuelles = document.querySelectorAll('.stat-value');
            if (nouvellesStats.length === statsActuelles.length) {
                statsActuelles.forEach((stat, i) => {
                    stat.innerHTML = nouvellesStats[i].innerHTML;
                });
            }
            
            // Actualiser les transactions récentes
            const nouvelleListe = doc.querySelector('.transactions-list');
            const listeActuelle = document.querySelector('.transactions-list');
            if (nouvelleListe && listeActuelle) {
                listeActuelle.innerHTML = nouvelleListe.innerHTML;
            }
        })
        .catch(err => console.log('Rafraîchissement différé'));
    }

    // Lancement toutes les 3 secondes
    let intervalleRafraichissement = setInterval(rafraichirDashboard, 3000);

    // Optionnel : nettoyer l'intervalle si la page est quittée (bonne pratique)
    window.addEventListener('beforeunload', () => {
        clearInterval(intervalleRafraichissement);
    });
    </script>
</body>
</html>