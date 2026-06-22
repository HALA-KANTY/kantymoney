<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.ClientDAO, java.util.*" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
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
    
    String nomNav = "";
    String initiales = "";
    String numtelFormatte = numtel;
    
    if (!clients.isEmpty()) {
        String[] cl = clients.get(0);
        nomNav = cl[1];
        for (String part : nomNav.split("\\s+")) {
            if (!part.isEmpty() && initiales.length() < 2) {
                initiales += part.charAt(0);
            }
        }
    }
    
    if (numtel != null && numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }
    
    String[] client = (String[]) request.getAttribute("client");
    if (client == null) {
        client = clientDAO.getClientByNumtel(numtel);
    }
    
    // ==================== MESSAGES FLASH ====================
    String flashMsg = (String) request.getAttribute("flashMsg");
    String flashType = (String) request.getAttribute("flashType");
    
    // ==================== GESTION MODALS ====================
    boolean showEditModal = request.getAttribute("showEditModal") != null;
    boolean showPasswordModal = request.getAttribute("showPasswordModal") != null;
    boolean showDeleteModal = request.getAttribute("showDeleteModal") != null;
    boolean showSuccessModal = flashMsg != null && "success".equals(flashType);
    boolean showErrorModal = flashMsg != null && "error".equals(flashType);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Paramètres</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
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

        /* ==================== SIDEBAR (identique dashboard) ==================== */
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
        }
        
        .page-header {
            margin-bottom: 36px;
        }
        
        .page-header h1 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--noir-profond);
            letter-spacing: -0.5px;
            display: flex;
            align-items: center;
            gap: 14px;
            margin-bottom: 8px;
        }
        
        .page-header h1 i {
            color: var(--marron);
            font-size: 1.8rem;
        }
        
        .page-header p {
            color: var(--gris-fonce);
            font-size: 0.92rem;
            font-weight: 400;
        }

        /* ==================== PROFILE SUMMARY ==================== */
        .profile-summary {
            display: flex;
            align-items: center;
            gap: 24px;
            padding: 28px 32px;
            background: var(--blanc);
            border-radius: 24px;
            border: 1px solid var(--gris-clair);
            margin-bottom: 32px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            transition: all 0.3s;
        }

        .profile-summary:hover {
            border-color: var(--marron-clair);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
            transform: translateY(-2px);
        }
        
        .profile-avatar-large {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 700;
            box-shadow: 0 8px 25px rgba(26, 26, 46, 0.2);
            flex-shrink: 0;
        }
        
        .profile-details h3 {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--noir-profond);
            margin-bottom: 6px;
        }
        
        .profile-details p {
            color: var(--gris-fonce);
            font-size: 0.9rem;
        }

        /* ==================== SETTINGS CARDS ==================== */
        .settings-grid {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .settings-card {
            background: var(--blanc);
            border-radius: 20px;
            padding: 24px 28px;
            border: 1px solid var(--gris-clair);
            display: flex;
            align-items: center;
            justify-content: space-between;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
        }
        
        .settings-card:hover {
            background: #FAFBFC;
            border-color: var(--marron);
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.06);
        }
        
        .settings-card-left {
            display: flex;
            align-items: center;
            gap: 18px;
        }
        
        .settings-icon {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            flex-shrink: 0;
        }
        
        .settings-icon.blue {
            background: #EFF6FF;
            color: var(--bleu);
        }
        
        .settings-icon.green {
            background: #F0FDF4;
            color: var(--vert);
        }
        
        .settings-icon.red {
            background: #FEF2F2;
            color: var(--rouge);
        }
        
        .settings-info h3 {
            font-size: 1.05rem;
            font-weight: 600;
            color: var(--noir-profond);
            margin-bottom: 4px;
        }
        
        .settings-info p {
            font-size: 0.84rem;
            color: var(--gris-fonce);
        }
        
        .settings-arrow {
            color: var(--gris-fonce);
            font-size: 1.1rem;
            transition: all 0.2s;
        }
        
        .settings-card:hover .settings-arrow {
            transform: translateX(6px);
            color: var(--marron);
        }

        /* ==================== MODAL ==================== */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(8px);
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }
        
        .modal-overlay.show {
            opacity: 1;
            visibility: visible;
        }
        
        .modal {
            background: var(--blanc);
            border-radius: 28px;
            width: 95%;
            max-width: 540px;
            box-shadow: 0 40px 80px rgba(0, 0, 0, 0.25);
            transform: scale(0.92) translateY(10px);
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-small {
            max-width: 420px;
        }
        
        .modal-overlay.show .modal {
            transform: scale(1) translateY(0);
        }
        
        .modal-header {
            padding: 24px 32px 16px;
            border-bottom: 1px solid var(--gris-clair);
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            background: white;
            z-index: 1;
            border-radius: 28px 28px 0 0;
        }
        
        .modal-header h3 {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--noir-profond);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .modal-close {
            width: 38px;
            height: 38px;
            border-radius: 12px;
            background: var(--gris-tres-clair);
            border: 1px solid var(--gris-clair);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            font-size: 1rem;
            color: var(--gris-fonce);
        }
        
        .modal-close:hover {
            background: #FEF2F2;
            color: var(--rouge);
            border-color: #FECACA;
        }
        
        .modal-body {
            padding: 24px 32px 28px;
        }

        /* ==================== MODAL CONFIRMATION ==================== */
        .confirmation-content {
            text-align: center;
            padding: 12px 0;
        }

        .confirmation-icon {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            animation: popIn 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        @keyframes popIn {
            0% { transform: scale(0); opacity: 0; }
            70% { transform: scale(1.1); }
            100% { transform: scale(1); opacity: 1; }
        }

        .confirmation-icon.success {
            background: #ECFDF3;
            color: #166534;
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.15);
        }

        .confirmation-icon.error {
            background: #FEF2F2;
            color: #991B1B;
            box-shadow: 0 8px 25px rgba(220, 53, 69, 0.15);
        }

        .confirmation-icon.warning {
            background: #FFF3E0;
            color: #FD7E14;
            box-shadow: 0 8px 25px rgba(253, 126, 20, 0.15);
        }

        .confirmation-icon.logout-icon {
            background: #FFF3E0;
            color: #FD7E14;
            box-shadow: 0 8px 25px rgba(253, 126, 20, 0.15);
        }

        .confirmation-content h4 {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--noir-profond);
            margin-bottom: 8px;
        }

        .confirmation-content p {
            color: var(--gris-fonce);
            font-size: 0.92rem;
            margin-bottom: 24px;
            line-height: 1.5;
        }

        /* ==================== FORM ==================== */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            font-size: 0.84rem;
            font-weight: 600;
            color: var(--noir-profond);
            margin-bottom: 8px;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 13px 16px;
            border: 2px solid var(--gris-moyen);
            border-radius: 12px;
            font-size: 0.92rem;
            font-family: 'Inter', sans-serif;
            transition: all 0.25s;
            background: var(--gris-tres-clair);
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--marron);
            background: white;
            box-shadow: 0 0 0 4px rgba(196, 148, 80, 0.06);
        }
        
        .form-group input:disabled {
            background: #F0F1F3;
            color: var(--gris-fonce);
            cursor: not-allowed;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        
        .mono {
            font-family: 'SF Mono', 'Consolas', monospace;
            letter-spacing: 0.15em;
            font-size: 1.1rem !important;
        }

        /* ==================== BOUTONS ==================== */
        .btn {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 0.93rem;
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            box-shadow: 0 4px 15px rgba(196, 148, 80, 0.2);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(196, 148, 80, 0.3);
        }
        
        .btn-blue {
            background: var(--bleu);
            color: white;
            box-shadow: 0 4px 15px rgba(13, 110, 253, 0.2);
        }
        
        .btn-blue:hover {
            background: #0B5ED7;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(13, 110, 253, 0.3);
        }
        
        .btn-red {
            background: var(--rouge);
            color: white;
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.2);
        }
        
        .btn-red:hover {
            background: #C82333;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(220, 53, 69, 0.3);
        }
        
        .btn-gray {
            background: var(--gris-clair);
            color: var(--gris-fonce);
        }
        
        .btn-gray:hover {
            background: var(--gris-moyen);
        }

        .btn-success {
            background: linear-gradient(135deg, #28A745, #20C997);
            color: white;
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.2);
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.3);
        }

        .btn-warning {
            background: linear-gradient(135deg, #FD7E14, #FFA726);
            color: white;
            box-shadow: 0 4px 15px rgba(253, 126, 20, 0.2);
        }

        .btn-warning:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(253, 126, 20, 0.3);
        }

        /* ==================== DANGER ZONE ==================== */
        .danger-zone {
            border: 2px solid #FECACA;
            padding: 24px;
            border-radius: 16px;
            background: #FFFBFB;
            margin: 20px 0;
        }
        
        .danger-zone h3 {
            color: var(--rouge);
            margin-bottom: 10px;
            font-size: 1rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .danger-zone p {
            color: var(--gris-fonce);
            font-size: 0.88rem;
            margin-bottom: 16px;
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
                padding: 16px;
            }
            .form-row {
                grid-template-columns: 1fr;
            }
            .profile-summary {
                flex-direction: column;
                text-align: center;
                padding: 20px;
            }
            .modal {
                max-width: 95%;
                border-radius: 24px;
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
            <h4><%= h(nomNav) %></h4>
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
            <a href="<%= request.getContextPath() %>/parametres" class="nav-item active">
                <i class="fas fa-user-gear"></i>
                <span>Paramètres</span>
            </a>
            <a href="#" class="nav-item logout" onclick="openLogoutModal(); return false;">
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
            <i class="fas fa-user-gear"></i>
            Paramètres du compte
        </h1>
        <p>Gérez vos informations personnelles et les paramètres de sécurité</p>
    </div>

    <% if (client != null) { %>
    <!-- Profil -->
    <div class="profile-summary">
        <div class="profile-avatar-large">
            <%= initiales.toUpperCase() %>
        </div>
        <div class="profile-details">
            <h3><%= h(client[1]) %></h3>
            <p>
                <i class="fas fa-mobile-alt" style="margin-right: 8px; color: var(--marron);"></i>
                <%= h(client[0]) %>
                &nbsp;&bull;&nbsp;
                <strong style="color: var(--marron);">
                    <%= MoneyFormat.formatNullable(client[4]) %> Ar
                </strong>
            </p>
        </div>
    </div>
    <% } %>

    <!-- Cartes paramètres -->
    <div class="settings-grid">
        <!-- Carte 1 : Modifier le profil -->
        <div class="settings-card" onclick="openModal('editProfileModal')">
            <div class="settings-card-left">
                <div class="settings-icon blue">
                    <i class="fas fa-user-pen"></i>
                </div>
                <div class="settings-info">
                    <h3>Modifier le profil</h3>
                    <p>Nom complet, email, sexe et âge</p>
                </div>
            </div>
            <i class="fas fa-chevron-right settings-arrow"></i>
        </div>

        <!-- Carte 2 : Changer le code PIN -->
        <div class="settings-card" onclick="openModal('changePinModal')">
            <div class="settings-card-left">
                <div class="settings-icon green">
                    <i class="fas fa-lock"></i>
                </div>
                <div class="settings-info">
                    <h3>Changer le code secret</h3>
                    <p>Mettre à jour votre code PIN à 4 chiffres</p>
                </div>
            </div>
            <i class="fas fa-chevron-right settings-arrow"></i>
        </div>

        <!-- Carte 3 : Supprimer le compte -->
        <div class="settings-card" onclick="openModal('deleteAccountModal')">
            <div class="settings-card-left">
                <div class="settings-icon red">
                    <i class="fas fa-user-slash"></i>
                </div>
                <div class="settings-info">
                    <h3>Supprimer le compte</h3>
                    <p>Action irréversible, solde à 0 Ar requis</p>
                </div>
            </div>
            <i class="fas fa-chevron-right settings-arrow"></i>
        </div>
    </div>
</main>

<!-- ==================== MODAL 1 : MODIFIER LE PROFIL ==================== -->
<div class="modal-overlay <%= showEditModal ? "show" : "" %>" id="editProfileModal">
    <div class="modal">
        <div class="modal-header">
            <h3>
                <i class="fas fa-user-pen" style="color: var(--bleu);"></i>
                Modifier le profil
            </h3>
            <button class="modal-close" onclick="closeModal('editProfileModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <% if (client != null) { %>
            <form method="post" action="<%= request.getContextPath() %>/parametres">
                <input type="hidden" name="action" value="majProfil">
                
                <div class="form-group">
                    <label for="nom">Nom complet</label>
                    <input type="text" id="nom" name="nom" required maxlength="120" 
                           value="<%= h(client[1]) %>" placeholder="Votre nom complet">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="sexe">Sexe</label>
                        <select id="sexe" name="sexe" required>
                            <option value="Masculin" <%= "Masculin".equals(client[2]) ? "selected" : "" %>>Masculin</option>
                            <option value="Féminin" <%= "Féminin".equals(client[2]) ? "selected" : "" %>>Féminin</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="age">Âge</label>
                        <input type="number" id="age" name="age" required min="18" max="120" 
                               value="<%= h(client[3]) %>" placeholder="18">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="mail">Adresse email</label>
                    <input type="email" id="mail" name="mail" required 
                           value="<%= h(client[5]) %>" placeholder="exemple@email.com">
                </div>
                
                <div style="display: flex; gap: 12px; margin-top: 8px;">
                    <button type="button" class="btn btn-gray" onclick="closeModal('editProfileModal')">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    <button type="submit" class="btn btn-blue">
                        <i class="fas fa-save"></i> Enregistrer
                    </button>
                </div>
            </form>
            <% } %>
        </div>
    </div>
</div>

<!-- ==================== MODAL 2 : CHANGER LE CODE PIN ==================== -->
<div class="modal-overlay <%= showPasswordModal ? "show" : "" %>" id="changePinModal">
    <div class="modal">
        <div class="modal-header">
            <h3>
                <i class="fas fa-lock" style="color: var(--vert);"></i>
                Changer le code secret
            </h3>
            <button class="modal-close" onclick="closeModal('changePinModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <form method="post" action="<%= request.getContextPath() %>/parametres">
                <input type="hidden" name="action" value="majCode">
                
                <div class="form-group">
                    <label for="ancien_code">Code secret actuel</label>
                    <input type="password" id="ancien_code" name="ancien_code" 
                           pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required 
                           class="mono" placeholder="••••">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="nouveau_code">Nouveau code</label>
                        <input type="password" id="nouveau_code" name="nouveau_code" 
                               pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required 
                               class="mono" placeholder="••••">
                    </div>
                    <div class="form-group">
                        <label for="nouveau_code_confirm">Confirmer le code</label>
                        <input type="password" id="nouveau_code_confirm" name="nouveau_code_confirm" 
                               pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required 
                               class="mono" placeholder="••••">
                    </div>
                </div>
                
                <div style="display: flex; gap: 12px; margin-top: 8px;">
                    <button type="button" class="btn btn-gray" onclick="closeModal('changePinModal')">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-key"></i> Mettre à jour
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ==================== MODAL 3 : SUPPRIMER LE COMPTE ==================== -->
<div class="modal-overlay <%= showDeleteModal ? "show" : "" %>" id="deleteAccountModal">
    <div class="modal">
        <div class="modal-header">
            <h3>
                <i class="fas fa-user-slash" style="color: var(--rouge);"></i>
                Supprimer le compte
            </h3>
            <button class="modal-close" onclick="closeModal('deleteAccountModal')">
                <i class="fas fa-times"></i>
            </button>
        </div>
        <div class="modal-body">
            <div class="danger-zone">
                <h3>
                    <i class="fas fa-triangle-exclamation"></i>
                    Zone de danger
                </h3>
                <p>
                    Cette action est <strong>irréversible</strong>. Votre solde doit être à 
                    <strong>0 Ar</strong>. Toutes vos transactions et données personnelles 
                    seront définitivement effacées.
                </p>
            </div>
            
            <form method="post" action="<%= request.getContextPath() %>/parametres" id="deleteAccountForm">
                <input type="hidden" name="action" value="supprimerCompte">
                
                <div class="form-group">
                    <label for="code_suppression">Code secret</label>
                    <input type="password" id="code_suppression" name="code_suppression" 
                           pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required 
                           class="mono" placeholder="••••">
                </div>
                
                <div class="form-group">
                    <label>Tapez <strong>SUPPRIMER</strong> pour confirmer</label>
                    <input type="text" id="confirmation_texte" name="confirmation_texte" required 
                           placeholder="SUPPRIMER" autocomplete="off" 
                           style="text-transform: uppercase; font-weight: 600;">
                </div>
                
                <div style="display: flex; gap: 12px; margin-top: 8px;">
                    <button type="button" class="btn btn-gray" onclick="closeModal('deleteAccountModal')">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    <button type="button" class="btn btn-red" onclick="openConfirmDeleteModal()">
                        <i class="fas fa-user-slash"></i> Supprimer mon compte
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ==================== MODAL 3b : CONFIRMATION SUPPRESSION ==================== -->
<div class="modal-overlay" id="confirmDeleteModal">
    <div class="modal modal-small">
        <div class="modal-body">
            <div class="confirmation-content">
                <div class="confirmation-icon warning">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h4>Confirmer la suppression</h4>
                <p>Êtes-vous absolument sûr de vouloir supprimer votre compte ? Cette action est <strong style="color: var(--rouge);">IRRÉVERSIBLE</strong>.</p>
                <div style="display: flex; gap: 12px;">
                    <button class="btn btn-gray" onclick="closeModal('confirmDeleteModal')">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    <button class="btn btn-red" onclick="submitDeleteForm()">
                        <i class="fas fa-trash"></i> Oui, supprimer
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL 4 : CONFIRMATION SUCCÈS ==================== -->
<div class="modal-overlay <%= showSuccessModal ? "show" : "" %>" id="successModal">
    <div class="modal modal-small">
        <div class="modal-body">
            <div class="confirmation-content">
                <div class="confirmation-icon success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h4>Opération réussie !</h4>
                <p><%= flashMsg != null ? h(flashMsg) : "" %></p>
                <button class="btn btn-success" onclick="closeModal('successModal')">
                    <i class="fas fa-check"></i> OK, compris
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL 5 : CONFIRMATION ERREUR ==================== -->
<div class="modal-overlay <%= showErrorModal ? "show" : "" %>" id="errorModal">
    <div class="modal modal-small">
        <div class="modal-body">
            <div class="confirmation-content">
                <div class="confirmation-icon error">
                    <i class="fas fa-exclamation-circle"></i>
                </div>
                <h4>Une erreur est survenue</h4>
                <p><%= flashMsg != null ? h(flashMsg) : "" %></p>
                <button class="btn btn-red" onclick="closeModal('errorModal')">
                    <i class="fas fa-times"></i> Fermer
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL 6 : CHAMP MANQUANT (AVERTISSEMENT) ==================== -->
<div class="modal-overlay" id="warningModal">
    <div class="modal modal-small">
        <div class="modal-body">
            <div class="confirmation-content">
                <div class="confirmation-icon warning">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <h4>Attention</h4>
                <p id="warningMessage">Veuillez remplir tous les champs requis.</p>
                <button class="btn btn-warning" onclick="closeModal('warningModal')">
                    <i class="fas fa-check"></i> OK, compris
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ==================== MODAL 7 : DÉCONNEXION ==================== -->
<div class="modal-overlay" id="logoutModal">
    <div class="modal modal-small">
        <div class="modal-body">
            <div class="confirmation-content">
                <div class="confirmation-icon logout-icon">
                    <i class="fas fa-power-off"></i>
                </div>
                <h4>Voulez-vous vous déconnecter ?</h4>
                <p>Votre session en cours sera fermée.</p>
                <div style="display: flex; gap: 12px;">
                    <button class="btn btn-gray" onclick="closeModal('logoutModal')">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    <button class="btn btn-warning" onclick="confirmLogout()">
                        <i class="fas fa-sign-out-alt"></i> Se déconnecter
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ==================== SCRIPTS ==================== -->
<script>
    // URL de déconnexion
    var logoutUrl = '<%= request.getContextPath() %>/login?logout=true';
    
    // Ouvrir un modal
    function openModal(id) {
        document.getElementById(id).classList.add('show');
        document.body.style.overflow = 'hidden';
    }
    
    // Fermer un modal
    function closeModal(id) {
        document.getElementById(id).classList.remove('show');
        document.body.style.overflow = '';
    }
    
    // Ouvrir le modal de déconnexion
    function openLogoutModal() {
        openModal('logoutModal');
    }
    
    // Confirmer la déconnexion
    function confirmLogout() {
        window.location.href = logoutUrl;
    }
    
    // Ouvrir la confirmation de suppression
    function openConfirmDeleteModal() {
        // Vérifier que les champs sont remplis
        var code = document.getElementById('code_suppression').value;
        var confirmation = document.getElementById('confirmation_texte').value;
        
        if (!code || code.length !== 4) {
            showWarning('Veuillez entrer votre code secret à 4 chiffres.');
            return;
        }
        if (!confirmation || confirmation.toUpperCase() !== 'SUPPRIMER') {
            showWarning('Veuillez taper SUPPRIMER pour confirmer.');
            return;
        }
        
        openModal('confirmDeleteModal');
    }
    
    // Afficher un avertissement (remplace alert)
    function showWarning(message) {
        document.getElementById('warningMessage').textContent = message;
        openModal('warningModal');
    }
    
    // Soumettre le formulaire de suppression
    function submitDeleteForm() {
        document.getElementById('deleteAccountForm').submit();
    }
    
    // Fermer en cliquant sur l'overlay
    document.querySelectorAll('.modal-overlay').forEach(function(modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal(this.id);
            }
        });
    });
    
    // Fermer avec la touche Échap
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.show').forEach(function(modal) {
                modal.classList.remove('show');
            });
            document.body.style.overflow = '';
        }
    });
    
    // Validation saisie numérique pour les codes PIN
    document.querySelectorAll('[inputmode="numeric"]').forEach(function(input) {
        input.addEventListener('keypress', function(e) {
            if (e.key < '0' || e.key > '9') {
                e.preventDefault();
            }
        });
    });
</script>

</body>
</html>