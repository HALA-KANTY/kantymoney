<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.OperateurStatsDAO" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.sql.Date" %>
<%
    OperateurStatsDAO dao = new OperateurStatsDAO();
    String period = request.getParameter("period");
    if (period == null || period.isBlank()) period = "month";
    LocalDate now = LocalDate.now();
    LocalDate start = now.withDayOfMonth(1);
    LocalDate end = now;
    int selMonth = now.getMonthValue();
    int selYear = now.getYear();
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    try { if (request.getParameter("month") != null) selMonth = Integer.parseInt(request.getParameter("month")); } catch (Exception ignored) {}
    try { if (request.getParameter("year") != null) selYear = Integer.parseInt(request.getParameter("year")); } catch (Exception ignored) {}
    if (selMonth < 1 || selMonth > 12) selMonth = now.getMonthValue();

    if ("day".equals(period)) {
        start = now; end = now;
    } else if ("week".equals(period)) {
        start = now.minusDays(6); end = now;
    } else if ("year".equals(period)) {
        start = LocalDate.of(selYear, 1, 1);
        end = LocalDate.of(selYear, 12, 31);
    } else if ("custom".equals(period)) {
        try {
            start = LocalDate.parse(startDate);
            end = LocalDate.parse(endDate);
            if (end.isBefore(start)) { LocalDate tmp = start; start = end; end = tmp; }
        } catch (Exception ignored) {
            start = now.withDayOfMonth(1); end = now;
        }
    } else {
        YearMonth ym = YearMonth.of(selYear, selMonth);
        start = ym.atDay(1); end = ym.atEndOfMonth();
        period = "month";
    }

    long[] r = dao.getRecetteBetween(Date.valueOf(start), Date.valueOf(end));
    long fraisEnvoiTotal = r[0];
    long fraisRetraitTotal = r[1];
    long recetteTotale = r[2];
    long txCount = r[3];
    
    boolean isCustom = "custom".equals(period);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Recette Opérateur</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #FAFAFA; color: #1A1A1A; min-height: 100vh; display: flex; }
        
        :root {
            --blanc: #FFFFFF; --gris-tres-clair: #F8F9FA; --gris-clair: #E9ECEF;
            --gris-moyen: #DEE2E6; --gris-fonce: #6C757D; --noir-doux: #212529;
            --marron: #C49450; --marron-clair: #D4A373; --marron-fonce: #A67A3E;
            --marron-tres-clair: #FDF6ED; --vert: #28A745; --rouge: #DC3545;
        }

        .main-content { flex: 1; margin-left: 300px; padding: 28px 36px; }

        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; flex-wrap: wrap; gap: 16px; }
        .page-title h1 { font-size: 1.8rem; font-weight: 600; color: var(--noir-doux); display: flex; align-items: center; gap: 12px; margin-bottom: 6px; }
        .page-title h1 i { color: var(--marron); font-size: 1.8rem; }
        .page-title p { color: var(--gris-fonce); font-size: 0.9rem; }

       
        /* Filtres intégrés dans le header */
        .header-filters {
            display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        }
        .header-filters select, .header-filters input {
            padding: 9px 12px; border: 2px solid var(--gris-moyen); border-radius: 8px;
            font-family: 'Inter', sans-serif; font-size: 0.85rem; background: var(--blanc);
            transition: all 0.2s;
        }
        .header-filters select:focus, .header-filters input:focus {
            outline: none; border-color: var(--marron); box-shadow: 0 0 0 3px rgba(196,148,80,0.1);
        }
        .header-filters select { min-width: 150px; }
        .header-filters input[type="date"] { width: 145px; }
        .header-filters .filter-icon { color: var(--gris-fonce); font-size: 0.9rem; }

        .filter-inline-form {
            display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        }

        .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 28px; }

        .stat-card {
            background: var(--blanc); border: 1px solid var(--gris-clair); border-radius: 20px;
            padding: 24px 28px; transition: all 0.2s;
        }
        .stat-card:hover { border-color: var(--marron-clair); box-shadow: 0 5px 15px rgba(0,0,0,0.03); }
        .stat-card.total { border-color: var(--marron); background: linear-gradient(135deg, var(--marron-tres-clair) 0%, var(--blanc) 100%); }
        
        .stat-header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
        .stat-icon { width: 48px; height: 48px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; }
        .stat-icon.blue { background: #EFF6FF; color: #0D6EFD; }
        .stat-icon.green { background: #F0FDF4; color: var(--vert); }
        .stat-icon.orange { background: #FFF7ED; color: #FD7E14; }
        .stat-icon.gold { background: var(--marron-tres-clair); color: var(--marron); }
        .stat-label-text { font-size: 0.85rem; font-weight: 500; color: var(--gris-fonce); }

        .stat-value { font-size: 2rem; font-weight: 700; color: var(--noir-doux); line-height: 1.2; }
        .stat-value small { font-size: 1rem; font-weight: 500; color: var(--gris-fonce); margin-left: 4px; }
        .stat-card.total .stat-value { color: var(--marron); font-size: 2.3rem; }

        .period-note {
            background: var(--marron-tres-clair); border: 1px solid rgba(196,148,80,0.2);
            border-radius: 16px; padding: 18px 24px; margin-top: 8px;
            display: flex; align-items: flex-start; gap: 12px;
        }
        .period-note i { color: var(--marron); font-size: 1.2rem; margin-top: 2px; }
        .period-note .note-content h4 { font-size: 0.95rem; font-weight: 600; color: var(--noir-doux); margin-bottom: 6px; }
        .period-note .note-content p { font-size: 0.85rem; color: var(--gris-fonce); line-height: 1.5; }
        .period-note .note-content strong { color: var(--marron); }

        @media (max-width: 1200px) { .stats-grid { grid-template-columns: 1fr; } }
        @media (max-width: 1000px) { .main-content { margin-left: 90px; padding: 20px; } }
        @media (max-width: 768px) { 
            .page-header { flex-direction: column; align-items: flex-start; }
            .header-filters { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="sidebar-header">
        <h2>Kanty<span class="accent">Money</span></h2>
        <span class="badge">OPÉRATEUR</span>
    </div>
    <div class="operator-profile">
        <div class="operator-avatar"><span>HK</span></div>
        <div class="operator-info">
            <h4>HALA Kanty</h4>
            <p>befenosteeven@gmail.com</p>
            <div class="role">Administrateur</div>
        </div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section">
            <div class="nav-section-title">Principal</div>
            <a href="dashboardOperateur.jsp" class="nav-item"><i class="fas fa-chart-pie"></i><span>Tableau de bord</span></a>
            <a href="recette-operateur.jsp" class="nav-item active"><i class="fas fa-coins"></i><span>Recette opérateur</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Gestion</div>
            <a href="gestion-clients" class="nav-item"><i class="fas fa-users"></i><span>Utilisateurs</span></a>
            <a href="<%= request.getContextPath() %>/operateur/transactions" class="nav-item"><i class="fas fa-arrow-right-arrow-left"></i><span>Transactions</span></a>
            <a href="gestionFraisRecep" class="nav-item"><i class="fas fa-hand-holding-dollar"></i><span>Frais de retrait</span></a>
            <a href="gestionFraisEnvoi" class="nav-item"><i class="fas fa-paper-plane"></i><span>Frais d'envoi</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Compte</div>
            <a href="#" class="nav-item logout" onclick="openLogoutModal('<%= request.getContextPath() %>/auth?action=logout'); return false;"><i class="fas fa-sign-out-alt"></i><span>Déconnexion</span></a>
        </div>
    </nav>
    <div class="sidebar-footer">
        <span><i class="far fa-copyright"></i> 2026 KantyMoney</span>
        <div class="status-indicator"><span class="status-dot"></span><span>En ligne</span></div>
    </div>
</aside>

<!-- MAIN -->
<main class="main-content">
    <div class="page-header">
        <div class="page-title">
            <h1><i class="fas fa-coins"></i> Recette Opérateur</h1>
            <p>Somme des commissions perçues sur les transferts et retraits</p>
        </div>
        
        <!-- Filtres + PDF intégrés dans le header -->
        <div class="header-filters">
            <span class="filter-icon"><i class="fas fa-filter"></i></span>
            <form id="filterForm" class="filter-inline-form">
                <select id="periodSelect" onchange="handlePeriodChange()">
                    <option value="day" <%= "day".equals(period) ? "selected" : "" %>>Aujourd'hui</option>
                    <option value="week" <%= "week".equals(period) ? "selected" : "" %>>7 derniers jours</option>
                    <option value="month" <%= "month".equals(period) ? "selected" : "" %>>Ce mois</option>
                    <option value="year" <%= "year".equals(period) ? "selected" : "" %>>Cette année</option>
                    <option value="custom" <%= "custom".equals(period) ? "selected" : "" %>>Personnalisée</option>
                </select>
                <input type="date" id="startDateInput" value="<%= startDate != null ? startDate : "" %>" style="<%= isCustom ? "" : "display:none;" %>" placeholder="Du">
                <input type="date" id="endDateInput" value="<%= endDate != null ? endDate : "" %>" style="<%= isCustom ? "" : "display:none;" %>" placeholder="Au">
            </form>
           
        </div>
    </div>

    <!-- Statistiques -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon blue"><i class="fas fa-paper-plane"></i></div>
                <span class="stat-label-text">Frais d'envoi cumulés</span>
            </div>
            <div class="stat-value"><%= MoneyFormat.format(fraisEnvoiTotal) %> <small>Ar</small></div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon orange"><i class="fas fa-hand-holding-dollar"></i></div>
                <span class="stat-label-text">Frais de retrait cumulés</span>
            </div>
            <div class="stat-value"><%= MoneyFormat.format(fraisRetraitTotal) %> <small>Ar</small></div>
        </div>

        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon green"><i class="fas fa-arrow-right-arrow-left"></i></div>
                <span class="stat-label-text">Nombre de transactions</span>
            </div>
            <div class="stat-value"><%= MoneyFormat.format(txCount) %></div>
        </div>

        <div class="stat-card total">
            <div class="stat-header">
                <div class="stat-icon gold"><i class="fas fa-coins"></i></div>
                <span class="stat-label-text">Recette totale opérateur</span>
            </div>
            <div class="stat-value"><%= MoneyFormat.format(recetteTotale) %> <small>Ar</small></div>
        </div>
    </div>

    <!-- Note -->
    <div class="period-note">
        <i class="fas fa-info-circle"></i>
        <div class="note-content">
            <h4>Détail du calcul</h4>
            <p>
                <strong>Formule :</strong> Recette = Somme des frais d'envoi + Somme des frais de retrait<br>
                <strong>Période :</strong> du <strong><%= start %></strong> au <strong><%= end %></strong>
            </p>
        </div>
    </div>
</main>

<!-- MODAL CONFIRMATION DÉCONNEXION -->
<div id="logoutModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);z-index:3000;align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:22px;max-width:520px;width:92%;padding:24px;box-shadow:0 24px 60px rgba(20,20,35,.28);text-align:center;position:relative;">
        <button type="button" onclick="closeLogoutModal()" style="position:absolute;right:12px;top:12px;border:1px solid #E9ECEF;background:#fff;border-radius:10px;padding:6px 9px;cursor:pointer;">
            <i class="fas fa-times"></i>
        </button>
        <div style="width:70px;height:70px;border-radius:50%;background:#FFF3E0;color:#FD7E14;display:flex;align-items:center;justify-content:center;font-size:1.9rem;margin:0 auto 12px;">
            <i class="fas fa-power-off"></i>
        </div>
        <h3 style="margin:0 0 6px;color:#1a1a2e;">Voulez-vous vous déconnecter ?</h3>
        <p style="margin:0;color:#6C757D;font-size:0.9rem;">Votre session opérateur sera fermée.</p>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:16px;">
            <button type="button" style="padding:12px;border-radius:10px;border:2px solid #DEE2E6;background:#fff;cursor:pointer;font-weight:600;" onclick="closeLogoutModal()">Annuler</button>
            <button type="button" style="padding:12px;border-radius:10px;border:none;background:linear-gradient(135deg,#C49450,#D4A373);color:#fff;cursor:pointer;font-weight:700;" onclick="confirmLogout()">Se déconnecter</button>
        </div>
    </div>
</div>

<script>
function handlePeriodChange() {
    var select = document.getElementById('periodSelect');
    var startInput = document.getElementById('startDateInput');
    var endInput = document.getElementById('endDateInput');
    var form = document.getElementById('filterForm');
    
    if (select.value === 'custom') {
        startInput.style.display = '';
        endInput.style.display = '';
        // Ne pas soumettre automatiquement en mode custom, attendre que l'utilisateur choisisse les dates
        if (startInput.value && endInput.value) {
            submitForm();
        }
    } else {
        startInput.style.display = 'none';
        endInput.style.display = 'none';
        submitForm();
    }
}

function submitForm() {
    var select = document.getElementById('periodSelect');
    var startInput = document.getElementById('startDateInput');
    var endInput = document.getElementById('endDateInput');
    
    var params = new URLSearchParams();
    params.append('period', select.value);
    
    if (select.value === 'custom') {
        if (startInput.value) params.append('startDate', startInput.value);
        if (endInput.value) params.append('endDate', endInput.value);
    }
    
    window.location.href = 'recette-operateur.jsp?' + params.toString();
}

// Écouter les changements de date en mode custom
document.getElementById('startDateInput').addEventListener('change', function() {
    var endInput = document.getElementById('endDateInput');
    if (endInput.value) submitForm();
});
document.getElementById('endDateInput').addEventListener('change', function() {
    var startInput = document.getElementById('startDateInput');
    if (startInput.value) submitForm();
});

// Initialiser l'affichage
document.addEventListener('DOMContentLoaded', function() {
    var select = document.getElementById('periodSelect');
    if (select.value === 'custom') {
        document.getElementById('startDateInput').style.display = '';
        document.getElementById('endDateInput').style.display = '';
    }
});

let logoutTarget = null;
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
document.getElementById('logoutModal')?.addEventListener('click', function(e){ if (e.target === this) closeLogoutModal(); });
</script>

</body>
</html>