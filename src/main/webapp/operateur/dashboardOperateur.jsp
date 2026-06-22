<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.OperateurStatsDAO" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%!
    private static String jsArray(long[] arr) {
        if (arr == null || arr.length == 0) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < arr.length; i++) {
            if (i > 0) sb.append(",");
            sb.append(arr[i]);
        }
        sb.append("]");
        return sb.toString();
    }
%>
<%
    OperateurStatsDAO statsDAO = new OperateurStatsDAO();
    long[] st = statsDAO.getDashboardStats();
    long[] recette7j = statsDAO.getRecette7DerniersJours();
    long[] repartition = statsDAO.getRepartitionTransactionsAujourdhui();
    long nbClients = st[0];
    long nbTxToday = st[1];
    long recetteTotale = st[2];
    long recetteMois = st[3];
    long fraisEnvoiTotal = st[4];
    long fraisRetraitTotal = st[5];
    
    // Date dynamique
    LocalDate aujourdhui = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("EEEE dd MMMM yyyy", Locale.FRENCH);
    String dateFormatee = aujourdhui.format(formatter);
    // Capitaliser la première lettre
    dateFormatee = dateFormatee.substring(0, 1).toUpperCase() + dateFormatee.substring(1);
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Dashboard Opérateur</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="../style/nav.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background-color: #FAFAFA; color: #1A1A1A; min-height: 100vh; display: flex; }

        :root {
            --blanc: #FFFFFF; --gris-tres-clair: #F8F9FA; --gris-clair: #E9ECEF;
            --gris-moyen: #DEE2E6; --gris-fonce: #6C757D; --noir-doux: #212529;
            --marron: #C49450; --marron-clair: #D4A373; --marron-fonce: #A67A3E;
            --marron-tres-clair: #FDF6ED; --vert: #28A745; --rouge: #DC3545;
            --bleu: #0D6EFD; --orange: #FD7E14; --violet: #8B5CF6;
        }

        .main-content { flex: 1; margin-left: 300px; padding: 24px 30px; }

        /* Header */
        .dashboard-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 22px; flex-wrap: wrap; gap: 14px;
        }
        .header-title h1 {
            font-size: 1.7rem; font-weight: 600; color: var(--noir-doux);
            display: flex; align-items: center; gap: 10px; margin-bottom: 3px;
        }
        .header-title h1 i { color: var(--marron); }
        .header-title p { color: var(--gris-fonce); font-size: 0.85rem; }

        .date-display {
            display: flex; align-items: center; gap: 8px;
            padding: 10px 16px; background: var(--blanc);
            border: 1px solid var(--gris-clair); border-radius: 10px;
            color: var(--noir-doux); font-size: 0.85rem; font-weight: 500;
        }
        .date-display i { color: var(--marron); }

        /* Bannière */
        .welcome-banner {
            background: linear-gradient(135deg, #FFF7ED 0%, var(--marron-tres-clair) 100%);
            border-radius: 16px; padding: 18px 24px; margin-bottom: 20px;
            display: flex; align-items: center; justify-content: space-between;
            border: 1px solid rgba(196,148,80,0.15); flex-wrap: wrap; gap: 14px;
        }
        .welcome-text h3 { font-size: 1.15rem; font-weight: 600; color: var(--noir-doux); margin-bottom: 3px; }
        .welcome-text p { color: var(--gris-fonce); font-size: 0.83rem; }
        .welcome-stats { display: flex; gap: 20px; }
        .welcome-stat-item { text-align: center; }
        .welcome-stat-value { font-size: 1.3rem; font-weight: 700; color: var(--marron); }
        .welcome-stat-label { font-size: 0.7rem; color: var(--gris-fonce); text-transform: uppercase; }

        /* Stats Grid */
        .stats-grid {
            display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 20px;
        }
        .stat-card {
            background: var(--blanc); border: 1px solid var(--gris-clair);
            border-radius: 16px; padding: 16px 18px; transition: all 0.2s;
        }
        .stat-card:hover { border-color: var(--marron-clair); box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
        .stat-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
        .stat-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex;
            align-items: center; justify-content: center; font-size: 1.1rem;
        }
        .stat-icon.blue { background: #EFF6FF; color: var(--bleu); }
        .stat-icon.green { background: #F0FDF4; color: var(--vert); }
        .stat-icon.orange { background: #FFF7ED; color: var(--orange); }
        .stat-icon.purple { background: #F5F3FF; color: var(--violet); }
        .stat-icon.gold { background: var(--marron-tres-clair); color: var(--marron); }
        .stat-trend {
            font-size: 0.68rem; font-weight: 600; padding: 3px 8px; border-radius: 16px;
        }
        .stat-trend.up { background: #F0FDF4; color: var(--vert); }
        .stat-value { font-size: 1.5rem; font-weight: 700; color: var(--noir-doux); margin-bottom: 2px; }
        .stat-label { font-size: 0.73rem; color: var(--gris-fonce); }

        /* Charts Row */
        .charts-row {
            display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-bottom: 20px;
        }
        .chart-card {
            background: var(--blanc); border: 1px solid var(--gris-clair);
            border-radius: 16px; padding: 18px 20px;
        }
        .chart-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 14px; flex-wrap: wrap; gap: 8px;
        }
        .chart-header h3 {
            font-size: 0.95rem; font-weight: 600; color: var(--noir-doux);
            display: flex; align-items: center; gap: 7px;
        }
        .chart-header h3 i { color: var(--marron); }
        .chart-container { position: relative; height: 280px; }
        .chart-container canvas { max-height: 280px; }

        /* Recette totale card */
        .recette-totale-card {
            background: linear-gradient(135deg, var(--marron) 0%, var(--marron-fonce) 100%);
            border-radius: 16px; padding: 20px 24px; color: white;
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 20px; flex-wrap: wrap; gap: 14px;
        }
        .recette-totale-left h4 {
            font-size: 0.8rem; font-weight: 500; text-transform: uppercase;
            letter-spacing: 0.5px; opacity: 0.85; margin-bottom: 6px;
        }
        .recette-totale-left .montant {
            font-size: 2rem; font-weight: 700;
        }
        .recette-totale-left .montant small { font-size: 1rem; font-weight: 500; opacity: 0.8; }
        .recette-totale-right {
            display: flex; gap: 20px;
        }
        .recette-detail { text-align: center; }
        .recette-detail .val { font-size: 1.2rem; font-weight: 700; }
        .recette-detail .lbl { font-size: 0.7rem; opacity: 0.8; text-transform: uppercase; }

        /* Responsive */
        @media (max-width: 1200px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 1000px) { .main-content { margin-left: 90px; padding: 18px; } }
        @media (max-width: 800px) { .charts-row { grid-template-columns: 1fr; } }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .dashboard-header { flex-direction: column; align-items: flex-start; }
            .welcome-banner { flex-direction: column; align-items: flex-start; }
            .recette-totale-card { flex-direction: column; text-align: center; }
            .recette-totale-right { justify-content: center; }
        }
    </style>
</head>
<body>
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
                <a href="#" class="nav-item active"><i class="fas fa-chart-pie"></i><span>Tableau de bord</span></a>
                <a href="recette-operateur.jsp" class="nav-item"><i class="fas fa-coins"></i><span>Recette opérateur</span></a>
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
    
    <main class="main-content">
        <!-- Header -->
        <div class="dashboard-header">
            <div class="header-title">
                <h1><i class="fas fa-chart-pie"></i> Tableau de bord</h1>
                <p>Vue d'ensemble de l'activité KantyMoney</p>
            </div>
            <div class="date-display">
                <i class="far fa-calendar-alt"></i>
                <span><%= dateFormatee %></span>
            </div>
        </div>

        <!-- Bannière Recette Totale -->
        <div class="recette-totale-card">
            <div class="recette-totale-left">
                <h4>Recette totale</h4>
                <div class="montant"><%= MoneyFormat.format(recetteTotale) %> <small>Ar</small></div>
            </div>
            <div class="recette-totale-right">
                <div class="recette-detail">
                    <div class="val"><%= MoneyFormat.format(fraisEnvoiTotal) %> Ar</div>
                    <div class="lbl">Frais d'envoi</div>
                </div>
                <div class="recette-detail">
                    <div class="val"><%= MoneyFormat.format(fraisRetraitTotal) %> Ar</div>
                    <div class="lbl">Frais de retrait</div>
                </div>
                <div class="recette-detail">
                    <div class="val"><%= MoneyFormat.format(recetteMois) %> Ar</div>
                    <div class="lbl">Ce mois</div>
                </div>
            </div>
        </div>
        
        <!-- Statistiques -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                    <span class="stat-trend up">Total</span>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(nbClients) %></div>
                <div class="stat-label">Clients enregistrés</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon green"><i class="fas fa-arrow-right-arrow-left"></i></div>
                    <span class="stat-trend up">Aujourd'hui</span>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(nbTxToday) %></div>
                <div class="stat-label">Transactions du jour</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon gold"><i class="fas fa-paper-plane"></i></div>
                    <span class="stat-trend up">Cumulé</span>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(fraisEnvoiTotal) %> Ar</div>
                <div class="stat-label">Total frais d'envoi</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon purple"><i class="fas fa-hand-holding-dollar"></i></div>
                    <span class="stat-trend up">Cumulé</span>
                </div>
                <div class="stat-value"><%= MoneyFormat.format(fraisRetraitTotal) %> Ar</div>
                <div class="stat-label">Total frais de retrait</div>
            </div>
        </div>

        <!-- Graphiques -->
        <div class="charts-row">
            <!-- Évolution de la recette (courbe) -->
            <div class="chart-card">
                <div class="chart-header">
                    <h3><i class="fas fa-chart-line"></i> Évolution de la recette</h3>
                    <span style="font-size:0.73rem;color:var(--gris-fonce);">7 derniers jours</span>
                </div>
                <div class="chart-container">
                    <canvas id="recetteChart"></canvas>
                </div>
            </div>
            
            <!-- Répartition des transactions (donut) -->
            <div class="chart-card">
                <div class="chart-header">
                    <h3><i class="fas fa-chart-pie"></i> Répartition des transactions</h3>
                    <span style="font-size:0.73rem;color:var(--gris-fonce);">Aujourd'hui</span>
                </div>
                <div class="chart-container">
                    <canvas id="transactionChart"></canvas>
                </div>
            </div>
        </div>
    </main>
    
    <!-- MODAL DÉCONNEXION -->
    <div id="logoutModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);z-index:3000;align-items:center;justify-content:center;">
        <div style="background:#fff;border-radius:22px;max-width:420px;width:92%;padding:28px;box-shadow:0 24px 60px rgba(20,20,35,.28);text-align:center;position:relative;">
            <button onclick="closeLogoutModal()" style="position:absolute;right:14px;top:14px;border:1px solid #E9ECEF;background:#fff;border-radius:8px;padding:6px 9px;cursor:pointer;"><i class="fas fa-times"></i></button>
            <div style="width:64px;height:64px;border-radius:50%;background:#FFF3E0;color:#FD7E14;display:flex;align-items:center;justify-content:center;font-size:1.6rem;margin:0 auto 14px;"><i class="fas fa-power-off"></i></div>
            <h3 style="margin:0 0 6px;color:#1a1a2e;">Se déconnecter ?</h3>
            <p style="margin:0;color:#6C757D;font-size:0.88rem;">Votre session opérateur sera fermée.</p>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:18px;">
                <button onclick="closeLogoutModal()" style="padding:12px;border-radius:10px;border:2px solid #DEE2E6;background:#fff;cursor:pointer;font-weight:600;">Annuler</button>
                <button onclick="confirmLogout()" style="padding:12px;border-radius:10px;border:none;background:var(--marron);color:#fff;cursor:pointer;font-weight:600;">Déconnexion</button>
            </div>
        </div>
    </div>

    <script>
        let logoutTarget = null;
        function openLogoutModal(url){ logoutTarget = url; document.getElementById('logoutModal').style.display = 'flex'; document.body.style.overflow = 'hidden'; }
        function closeLogoutModal(){ document.getElementById('logoutModal').style.display = 'none'; document.body.style.overflow = ''; }
        function confirmLogout(){ if (logoutTarget) window.location.href = logoutTarget; }
        document.getElementById('logoutModal')?.addEventListener('click', function(e){ if (e.target === this) closeLogoutModal(); });

        // Graphique courbe - Évolution recette 7 jours
        const recetteCtx = document.getElementById('recetteChart').getContext('2d');
        new Chart(recetteCtx, {
            type: 'line',
            data: {
                labels: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
                datasets: [{
                    label: 'Recette (Ar)',
                    data: <%= jsArray(recette7j) %>,
                    borderColor: '#C49450',
                    backgroundColor: 'rgba(196,148,80,0.06)',
                    borderWidth: 2.5,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#C49450',
                    pointBorderColor: '#FFFFFF',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: '#F1F3F5' },
                        ticks: {
                            callback: function(value) {
                                if (value >= 1000000) return (value / 1000000).toFixed(1) + 'M Ar';
                                if (value >= 1000) return (value / 1000).toFixed(0) + 'k Ar';
                                return value + ' Ar';
                            }
                        }
                    },
                    x: { grid: { display: false } }
                }
            }
        });
        
        // Graphique donut (pizza) - Répartition des transactions
        const transactionCtx = document.getElementById('transactionChart').getContext('2d');
        new Chart(transactionCtx, {
            type: 'doughnut',
            data: {
                labels: ['Envois', 'Retraits'],
                datasets: [{
                    data: <%= jsArray(repartition) %>,
                    backgroundColor: ['#0D6EFD', '#FD7E14'],
                    borderColor: ['#0D6EFD', '#FD7E14'],
                    borderWidth: 1,
                    hoverBorderWidth: 3,
                    hoverBorderColor: ['#0D6EFD', '#FD7E14']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: { family: 'Inter', size: 11 },
                            padding: 16,
                            usePointStyle: true,
                            pointStyleWidth: 10
                        }
                    }
                },
                cutout: '70%'
            }
        });
    </script>
</body>
</html>