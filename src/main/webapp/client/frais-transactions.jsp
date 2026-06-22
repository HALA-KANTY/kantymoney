<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.steeven.dao.ClientDAO" %>
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
            if (!part.isEmpty() && initiales.length() < 2) {
                initiales += part.charAt(0);
            }
        }
    }
    if (numtel != null && numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }
    List<String[]> tranchesEnvoi = (List<String[]>) request.getAttribute("tranchesEnvoi");
    List<String[]> tranchesRetrait = (List<String[]>) request.getAttribute("tranchesRetrait");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Frais de transaction</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav-client.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
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

        body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #f5f7fa 0%, #faf5f0 100%); color: #1A1A1A; min-height: 100vh; display: flex; }
        .main-content { flex: 1; margin-left: 280px; padding: 28px 36px; }
        .page-header { margin-bottom: 22px; }
        .page-header h1 { font-size: 1.7rem; font-weight: 700; color: #1a1a2e; display: flex; align-items: center; gap: 10px; margin-bottom: 6px; }
        .page-header h1 i { color: #C49450; }
        .page-header p { color: #6C757D; font-size: .9rem; }
        .calc-card { background: #fff; border: 1px solid #E9ECEF; border-radius: 18px; padding: 18px; margin-bottom: 18px; box-shadow: 0 4px 16px rgba(0,0,0,.03); }
        .calc-row { display: grid; grid-template-columns: 1.2fr 1fr 1fr; gap: 12px; align-items: end; }
        .grp label { display: block; font-size: .78rem; color: #6C757D; font-weight: 600; margin-bottom: 6px; text-transform: uppercase; letter-spacing: .4px; }
        .grp input { width: 100%; padding: 12px 14px; border: 2px solid #DEE2E6; border-radius: 10px; font-size: .92rem; }
        .result-box { background: #F8F9FA; border: 1px solid #E9ECEF; border-radius: 12px; padding: 12px; }
        .result-box .k { font-size: .75rem; color: #6C757D; margin-bottom: 4px; }
        .result-box .v { font-size: 1.1rem; font-weight: 700; color: #1a1a2e; }
        .tables-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .card { background: #fff; border: 1px solid #E9ECEF; border-radius: 18px; overflow: hidden; }
        .card-head { padding: 14px 16px; background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #fff; font-size: .92rem; font-weight: 600; display: flex; align-items: center; gap: 8px; }
        .card-head i { color: #C49450; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px 14px; text-align: center; border-bottom: 1px solid #E9ECEF; font-size: .88rem; }
        th { font-size: .74rem; color: #6C757D; text-transform: uppercase; letter-spacing: .4px; background: #F8F9FA; }
        tr:last-child td { border-bottom: none; }
        @media (max-width: 1000px) { .main-content { margin-left: 90px; padding: 18px; } .tables-grid { grid-template-columns: 1fr; } .calc-row { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-header"><h2>KantyMoney</h2><span>Espace Client</span></div>
    <div class="user-profile">
        <div class="user-avatar"><span><%= initiales.toUpperCase() %></span></div>
        <div class="user-info"><h4><%= nom %></h4><p><%= numtelFormatte %></p></div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section">
            <div class="nav-section-title">Principal</div>
            <a href="<%= request.getContextPath() %>/client/dashboardclient.jsp" class="nav-item"><i class="fas fa-chart-pie"></i><span>Tableau de bord</span></a>
            <a href="<%= request.getContextPath() %>/historique" class="nav-item"><i class="fas fa-clock-rotate-left"></i><span>Historique</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Transactions</div>
            <a href="<%= request.getContextPath() %>/envoi" class="nav-item"><i class="fas fa-paper-plane"></i><span>Envoyer</span></a>
            <a href="<%= request.getContextPath() %>/retrait" class="nav-item"><i class="fas fa-hand-holding-dollar"></i><span>Retirer</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Outils</div>
            <a href="<%= request.getContextPath() %>/client/releve.jsp" class="nav-item"><i class="fas fa-file-pdf"></i><span>Relevé PDF</span></a>
            <a href="<%= request.getContextPath() %>/frais-transactions" class="nav-item active"><i class="fas fa-percent"></i><span>Frais de transaction</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Compte</div>
            <a href="<%= request.getContextPath() %>/parametres" class="nav-item"><i class="fas fa-user-gear"></i><span>Paramètres</span></a>
            <a href="<%= request.getContextPath() %>/login?logout=true" class="nav-item logout"><i class="fas fa-sign-out-alt"></i><span>Déconnexion</span></a>
        </div>
    </nav>
</aside>

<main class="main-content">
    <div class="page-header">
        <h1><i class="fas fa-percent"></i> Frais de transaction</h1>
        <p>Consultez les tranches et calculez instantanément les frais applicables.</p>
    </div>

    <div class="calc-card">
        <div class="calc-row">
            <div class="grp">
                <label>Montant a tester (Ar)</label>
                <input id="montantInput" type="number" min="1" step="1" placeholder="Ex: 12536">
            </div>
            <div class="result-box">
                <div class="k">Frais d'envoi</div>
                <div class="v" id="resultEnvoi">-</div>
            </div>
            <div class="result-box">
                <div class="k">Frais de retrait</div>
                <div class="v" id="resultRetrait">-</div>
            </div>
        </div>
    </div>

    <div class="tables-grid">
        <div class="card">
            <div class="card-head"><i class="fas fa-paper-plane"></i> Frais d'envoi par tranche</div>
            <table>
                <thead><tr><th>Min</th><th>Max</th><th>Frais</th></tr></thead>
                <tbody>
                <% if (tranchesEnvoi != null) { for (String[] f : tranchesEnvoi) { %>
                    <tr><td><%= f[1] %></td><td><%= f[2] %></td><td><%= f[3] %> Ar</td></tr>
                <% } } %>
                </tbody>
            </table>
        </div>

        <div class="card">
            <div class="card-head"><i class="fas fa-hand-holding-dollar"></i> Frais de retrait par tranche</div>
            <table>
                <thead><tr><th>Min</th><th>Max</th><th>Frais</th></tr></thead>
                <tbody>
                <% if (tranchesRetrait != null) { for (String[] f : tranchesRetrait) { %>
                    <tr><td><%= f[1] %></td><td><%= f[2] %></td><td><%= f[3] %> Ar</td></tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script>
    const fmtAr = new Intl.NumberFormat('fr-FR', { maximumFractionDigits: 0 });

    const tranchesEnvoi = [
        <% if (tranchesEnvoi != null) { for (int i = 0; i < tranchesEnvoi.size(); i++) { String[] f = tranchesEnvoi.get(i); %>
        { min: <%= f[1] %>, max: <%= f[2] %>, frais: <%= f[3] %> }<%= (i < tranchesEnvoi.size() - 1) ? "," : "" %>
        <% } } %>
    ];
    const tranchesRetrait = [
        <% if (tranchesRetrait != null) { for (int i = 0; i < tranchesRetrait.size(); i++) { String[] f = tranchesRetrait.get(i); %>
        { min: <%= f[1] %>, max: <%= f[2] %>, frais: <%= f[3] %> }<%= (i < tranchesRetrait.size() - 1) ? "," : "" %>
        <% } } %>
    ];

    function findFee(amount, tranches) {
        for (const t of tranches) {
            if (amount >= t.min && amount <= t.max) return t.frais;
        }
        return null;
    }

    const input = document.getElementById("montantInput");
    const resultEnvoi = document.getElementById("resultEnvoi");
    const resultRetrait = document.getElementById("resultRetrait");

    input.addEventListener("input", function () {
        const amount = parseInt(this.value, 10);
        if (Number.isNaN(amount) || amount <= 0) {
            resultEnvoi.textContent = "-";
            resultRetrait.textContent = "-";
            return;
        }
        const feeEnvoi = findFee(amount, tranchesEnvoi);
        const feeRetrait = findFee(amount, tranchesRetrait);
        resultEnvoi.textContent = feeEnvoi !== null ? (fmtAr.format(feeEnvoi) + " Ar") : "Aucune tranche";
        resultRetrait.textContent = feeRetrait !== null ? (fmtAr.format(feeRetrait) + " Ar") : "Aucune tranche";
    });
</script>
</body>
</html>
