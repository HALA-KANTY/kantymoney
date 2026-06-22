<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Gestion des Transactions</title>
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
        .main-content { flex: 1; margin-left: 300px; padding: 24px 32px; }
        .page-header { 
            display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; gap: 12px; flex-wrap: wrap; 
        }
        .page-title h1 { font-size: 2rem; font-weight: 600; display: flex; align-items: center; gap: 10px; margin-bottom: 5px; }
        .page-title h1 i { color: var(--marron); }
        .page-title p { color: var(--gris-fonce); font-size: 1rem; }
        
        .header-filters {
            display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        }
        .header-filters .filter-group {
            display: flex; align-items: center; gap: 6px;
        }
        .header-filters select, .header-filters input {
            padding: 7px 11px; border-radius: 8px; border: 2px solid var(--gris-moyen);
            font-family: 'Inter', sans-serif; font-size: 1rem; background: var(--blanc);
        }
        .header-filters select:focus, .header-filters input:focus {
            border-color: var(--marron); outline: none;
        }
        .header-filters input[type="text"] { width: 160px; }
        .header-filters input[type="date"] { width: 158px; }
        .btn-filter-reset {
            padding: 7px 14px; border-radius: 8px; border: 2px solid var(--gris-moyen); 
            background: var(--blanc); color: var(--gris-fonce); font-weight: 600; 
            font-size: 0.88rem; cursor: pointer; font-family: 'Inter', sans-serif;
            display: flex; align-items: center; gap: 5px; transition: all 0.2s;
        }
        .btn-filter-reset:hover { border-color: var(--marron); color: var(--marron); background: var(--marron-tres-clair); }
        .header-filters .filter-icon { color: var(--gris-fonce); font-size: 1rem; }
        
        .table-container { background: var(--blanc); border: 1px solid var(--gris-clair); border-radius: 18px; overflow: hidden; }
        .table-header { padding: 14px 20px; border-bottom: 1px solid var(--gris-clair); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; }
        .table-header h3 { font-size: 0.95rem; }
        .tx-count { background: var(--marron-tres-clair); color: var(--marron); border-radius: 30px; padding: 4px 11px; font-size: 0.8rem; font-weight: 600; }
        .table-wrapper { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 900px; }
        th, td { padding: 11px 15px; border-bottom: 1px solid var(--gris-clair); font-size: 0.86rem; text-align: left; }
        th { font-size: 0.73rem; color: var(--gris-fonce); text-transform: uppercase; letter-spacing: 0.4px; padding: 8px 15px; }
        tr:last-child td { border-bottom: none; }
        tr { height: 48px; }
        .badge { display: inline-flex; align-items: center; border-radius: 20px; padding: 4px 10px; font-size: 0.78rem; font-weight: 600; }
        .badge-envoi { background: #EFF6FF; color: #0D6EFD; }
        .badge-retrait { background: #FFF7ED; color: #FD7E14; }
        .btn-cancel {
            background: #FEF2F2; color: var(--rouge); border: 1px solid #FECACA; border-radius: 9px; 
            padding: 6px 11px; font-size: 0.82rem; font-weight: 600; cursor: pointer; transition: all 0.2s;
        }
        .btn-cancel:hover { background: var(--rouge); color: white; }
        
        /* Pagination */
        .pagination-container {
            display: flex; justify-content: space-between; align-items: center;
            padding: 12px 20px; border-top: 1px solid var(--gris-clair); flex-wrap: wrap; gap: 10px;
        }
        .pagination-info { color: var(--gris-fonce); font-size: 0.83rem; }
        .pagination-buttons { display: flex; gap: 5px; }
        .page-btn {
            width: 33px; height: 33px; border-radius: 7px; border: 2px solid var(--gris-moyen);
            background: var(--blanc); cursor: pointer; font-family: 'Inter', sans-serif; font-weight: 600;
            font-size: 0.83rem; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center;
        }
        .page-btn:hover:not(:disabled) { border-color: var(--marron); color: var(--marron); }
        .page-btn.active { background: var(--marron); color: white; border-color: var(--marron); }
        .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
        .page-btn.nav { font-size: 0.95rem; }
        .empty-state { text-align: center; padding: 35px 20px; color: var(--gris-fonce); }
        .empty-state i { font-size: 2.8rem; color: var(--gris-moyen); margin-bottom: 10px; display: block; }

        /* Modal styles */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center;
        }
        .modal-overlay.active { display: flex; }
        .modal {
            background: var(--blanc); border-radius: 16px; padding: 28px; width: 90%; max-width: 460px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15); animation: modalIn 0.25s ease-out;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: translateY(-20px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .modal-icon {
            width: 56px; height: 56px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 18px; font-size: 1.5rem;
        }
        .modal-icon.warning { background: #FFF7ED; color: #FD7E14; }
        .modal-icon.success { background: #F0FDF4; color: var(--vert); }
        .modal-icon.error { background: #FEF2F2; color: var(--rouge); }
        .modal h3 { text-align: center; font-size: 1.15rem; margin-bottom: 10px; color: var(--noir-doux); font-weight: 600; }
        .modal .modal-desc { text-align: center; font-size: 0.88rem; color: var(--gris-fonce); margin-bottom: 18px; line-height: 1.5; }
        .modal .tx-details {
            background: var(--gris-tres-clair); border-radius: 10px; padding: 14px; margin-bottom: 22px;
            display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 0.84rem;
        }
        .modal .tx-details .label { color: var(--gris-fonce); font-size: 0.73rem; text-transform: uppercase; font-weight: 600; }
        .modal .tx-details .value { font-weight: 600; color: var(--noir-doux); word-break: break-all; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
        .btn-modal {
            padding: 9px 20px; border-radius: 9px; font-size: 0.86rem; font-weight: 600; 
            cursor: pointer; border: none; transition: all 0.2s; font-family: 'Inter', sans-serif;
        }
        .btn-modal-cancel { background: var(--gris-clair); color: var(--noir-doux); }
        .btn-modal-cancel:hover { background: var(--gris-moyen); }
        .btn-modal-confirm { background: var(--rouge); color: white; }
        .btn-modal-confirm:hover { background: #b02a37; }
        .btn-modal-close { background: var(--marron); color: white; }
        .btn-modal-close:hover { background: var(--marron-fonce); }
        .notification-message {
            text-align: center; padding: 12px; background: var(--gris-tres-clair); 
            border-radius: 10px; margin-bottom: 16px; font-size: 0.88rem;
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
            <a href="dashboardOperateur.jsp" class="nav-item"><i class="fas fa-chart-pie"></i><span>Tableau de bord</span></a>
            <a href="recette-operateur.jsp" class="nav-item"><i class="fas fa-coins"></i><span>Recette opérateur</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Gestion</div>
            <a href="<%= request.getContextPath() %>/operateur/gestion-clients" class="nav-item"><i class="fas fa-users"></i><span>Utilisateurs</span></a>
            <a href="<%= request.getContextPath() %>/operateur/transactions" class="nav-item active"><i class="fas fa-arrow-right-arrow-left"></i><span>Transactions</span></a>
            <a href="<%= request.getContextPath() %>/operateur/gestionFraisRecep" class="nav-item"><i class="fas fa-hand-holding-dollar"></i><span>Frais de retrait</span></a>
            <a href="<%= request.getContextPath() %>/operateur/gestionFraisEnvoi" class="nav-item"><i class="fas fa-paper-plane"></i><span>Frais d'envoi</span></a>
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
    <div class="page-header">
        <div class="page-title">
            <h1><i class="fas fa-arrow-right-arrow-left"></i> Gestion des Transactions</h1>
            <p style="font-size:0.92rem;color:var(--gris-fonce);margin-bottom:4px;">Vue unique des envois et retraits avec annulation opérateur.</p>
            <p id="searchResultLine" style="font-size:0.85rem;color:var(--marron);font-weight:600;"><%= request.getAttribute("searchResult") != null ? request.getAttribute("searchResult") : "" %></p>
        </div>
        
        <!-- Filtres avec soumission automatique -->
        <div class="header-filters">
            <span class="filter-icon"><i class="fas fa-filter"></i></span>
            <div class="filter-group">
                <select id="typeFilter" name="type" onchange="applyFilters()">
                    <%
                        String typeFilter = (String) request.getAttribute("typeFilter");
                        if (typeFilter == null) typeFilter = "all";
                        String filterDateOp = request.getAttribute("filterDate") != null ? (String) request.getAttribute("filterDate") : "";
                        String searchQuery = request.getAttribute("searchQuery") != null ? (String) request.getAttribute("searchQuery") : "";
                    %>
                    <option value="all" <%= "all".equals(typeFilter) ? "selected" : "" %>>Tous</option>
                    <option value="envoi" <%= "envoi".equals(typeFilter) ? "selected" : "" %>>Envois</option>
                    <option value="retrait" <%= "retrait".equals(typeFilter) ? "selected" : "" %>>Retraits</option>
                </select>
            </div>
            <div class="filter-group">
                <label for="dateFilter" class="filter-icon" title="Jour précis"><i class="fas fa-calendar-day"></i></label>
                <input type="date" id="dateFilter" name="date" value="<%= filterDateOp %>" onchange="applyFilters()">
            </div>
            <div class="filter-group">
                <input type="text" id="searchFilter" name="search" placeholder="ID transaction..." value="<%= searchQuery %>" oninput="applyFiltersDebounced()">
            </div>
            <% if (!"all".equals(typeFilter) || !filterDateOp.isEmpty() || !searchQuery.isEmpty()) { %>
            <button type="button" class="btn-filter-reset" onclick="resetFilters()">
                <i class="fas fa-undo"></i> Réinitialiser
            </button>
            <% } %>
        </div>
    </div>

    <%
        List<String[]> transactions = (List<String[]>) request.getAttribute("transactions");
        int total = transactions != null ? transactions.size() : 0;
        String message = (String) request.getAttribute("message");
        String messageType = (String) request.getAttribute("messageType");
    %>
    <div class="table-container">
        <div class="table-header">
            <h3>Transactions</h3>
            <span class="tx-count" id="displayedCount"><%= total %> ligne(s)</span>
        </div>
        <div class="table-wrapper">
            <table id="txTable">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th>ID Transaction</th>
                        <th>Propriétaire</th>
                        <th>Contrepartie</th>
                        <th>Montant</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="txTableBody">
                <% if (transactions != null && !transactions.isEmpty()) {
                    for (String[] tx : transactions) { %>
                    <tr class="tx-row" data-type="<%= tx[0].toLowerCase() %>" data-id="<%= tx[1].toLowerCase() %>"
                        data-txid="<%= tx[1] %>" data-proprietaire="<%= tx[2] %>" 
                        data-contrepartie="<%= tx[3] != null ? tx[3] : "-" %>" 
                        data-montant="<%= MoneyFormat.formatNullable(tx[4]) %>" data-date="<%= tx[5] %>"
                        data-txtype="<%= tx[0] %>">
                        <td>
                            <% if ("ENVOI".equalsIgnoreCase(tx[0])) { %>
                                <span class="badge badge-envoi">ENVOI</span>
                            <% } else { %>
                                <span class="badge badge-retrait">RETRAIT</span>
                            <% } %>
                        </td>
                        <td><%= tx[1] %></td>
                        <td><%= tx[2] %></td>
                        <td><%= tx[3] != null ? tx[3] : "-" %></td>
                        <td><%= MoneyFormat.formatNullable(tx[4]) %> Ar</td>
                        <td><%= tx[5] %></td>
                        <td>
                            <button class="btn-cancel btn-open-modal" type="button"
                                data-txid="<%= tx[1] %>" data-txtype="<%= tx[0] %>"
                                data-proprietaire="<%= tx[2] %>" 
                                data-contrepartie="<%= tx[3] != null ? tx[3] : "-" %>"
                                data-montant="<%= MoneyFormat.formatNullable(tx[4]) %>"
                                data-date="<%= tx[5] %>">
                                <i class="fas fa-ban"></i> Annuler
                            </button>
                        </td>
                    </tr>
                <%  }
                } else { %>
                    <tr id="emptyRow">
                        <td colspan="7">
                            <div class="empty-state">
                                <i class="fas fa-search"></i>
                                <p>Aucune transaction trouvée avec ces filtres.</p>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <div class="pagination-container" id="paginationContainer">
            <div class="pagination-info" id="paginationInfo"></div>
            <div class="pagination-buttons" id="paginationButtons"></div>
        </div>
    </div>
</main>

<!-- MODAL CONFIRMATION DÉCONNEXION -->
<div id="logoutModal" class="modal-overlay">
    <div class="modal">
        <div class="modal-body" style="text-align:center;">
            <div class="modal-icon warning"><i class="fas fa-power-off"></i></div>
            <h3>Voulez-vous vous déconnecter ?</h3>
            <p class="modal-desc">Votre session opérateur sera fermée.</p>
        </div>
        <div class="modal-actions" style="justify-content:center;">
            <button type="button" class="btn-modal btn-modal-cancel" onclick="closeLogoutModal()"><i class="fas fa-times"></i> Annuler</button>
            <button type="button" class="btn-modal btn-modal-close" onclick="confirmLogout()"><i class="fas fa-check"></i> Se déconnecter</button>
        </div>
    </div>
</div>

<!-- Modal de confirmation d'annulation -->
<div class="modal-overlay" id="cancelModal">
    <div class="modal">
        <div class="modal-icon warning">
            <i class="fas fa-exclamation-triangle"></i>
        </div>
        <h3>Confirmer l'annulation</h3>
        <p class="modal-desc">Le montant sera recrédité au propriétaire (hors frais). Cette action est irréversible.</p>
        
        <div class="tx-details">
            <div>
                <div class="label">Type</div>
                <div class="value" id="modalType"></div>
            </div>
            <div>
                <div class="label">ID Transaction</div>
                <div class="value" id="modalTxId"></div>
            </div>
            <div>
                <div class="label">Propriétaire</div>
                <div class="value" id="modalProprietaire"></div>
            </div>
            <div>
                <div class="label">Contrepartie</div>
                <div class="value" id="modalContrepartie"></div>
            </div>
            <div>
                <div class="label">Montant</div>
                <div class="value" id="modalMontant"></div>
            </div>
            <div>
                <div class="label">Date</div>
                <div class="value" id="modalDate"></div>
            </div>
        </div>
        
        <form method="post" action="<%= request.getContextPath() %>/operateur/transactions" id="cancelForm">
            <input type="hidden" name="action" value="annuler">
            <input type="hidden" name="txType" id="cancelTxType">
            <input type="hidden" name="txId" id="cancelTxId">
            <input type="hidden" name="returnType" id="returnType" value="">
            <input type="hidden" name="returnSearch" id="returnSearch" value="">
            <input type="hidden" name="returnDate" id="returnDate" value="">
            <div class="modal-actions">
                <button type="button" class="btn-modal btn-modal-cancel" id="btnCancelModal">Retour</button>
                <button type="submit" class="btn-modal btn-modal-confirm">
                    <i class="fas fa-check"></i> Confirmer l'annulation
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Modal de notification (succès/erreur) -->
<div class="modal-overlay" id="notificationModal">
    <div class="modal">
        <div class="modal-icon" id="notifIcon">
            <i class="fas fa-check-circle"></i>
        </div>
        <h3 id="notifTitle">Succès</h3>
        <div class="notification-message" id="notifMessage"></div>
        <div class="modal-actions" style="justify-content: center;">
            <button type="button" class="btn-modal btn-modal-close" id="btnCloseNotif">Fermer</button>
        </div>
    </div>
</div>

<script>
    // ===== FILTRES AUTOMATIQUES =====
    var baseUrl = '<%= request.getContextPath() %>/operateur/transactions';
    var debounceTimer;
    
    function applyFilters() {
        var type = document.getElementById('typeFilter').value;
        var date = document.getElementById('dateFilter').value;
        var search = document.getElementById('searchFilter').value;
        redirectWithFilters(type, date, search);
    }
    
    function applyFiltersDebounced() {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function() {
            applyFilters();
        }, 500);
    }
    
    function redirectWithFilters(type, date, search) {
        var params = [];
        if (type && type !== 'all') params.push('type=' + encodeURIComponent(type));
        if (date) params.push('date=' + encodeURIComponent(date));
        if (search) params.push('search=' + encodeURIComponent(search));
        var url = baseUrl;
        if (params.length > 0) url += '?' + params.join('&');
        window.location.href = url;
    }
    
    function resetFilters() {
        window.location.href = baseUrl;
    }

    // ===== PAGINATION =====
    (function() {
        const rows = Array.from(document.querySelectorAll('.tx-row'));
        const emptyRow = document.getElementById('emptyRow');
        const displayedCount = document.getElementById('displayedCount');
        const paginationInfo = document.getElementById('paginationInfo');
        const paginationButtons = document.getElementById('paginationButtons');
        const ROWS_PER_PAGE = 10;
        let currentPage = 1;
        let filteredRows = [...rows];

        // Modal annulation
        const cancelModal = document.getElementById('cancelModal');
        const modalType = document.getElementById('modalType');
        const modalTxId = document.getElementById('modalTxId');
        const modalProprietaire = document.getElementById('modalProprietaire');
        const modalContrepartie = document.getElementById('modalContrepartie');
        const modalMontant = document.getElementById('modalMontant');
        const modalDate = document.getElementById('modalDate');
        const cancelTxType = document.getElementById('cancelTxType');
        const cancelTxId = document.getElementById('cancelTxId');
        const btnCancelModal = document.getElementById('btnCancelModal');

        // Modal notification
        const notificationModal = document.getElementById('notificationModal');
        const notifIcon = document.getElementById('notifIcon');
        const notifTitle = document.getElementById('notifTitle');
        const notifMessage = document.getElementById('notifMessage');
        const btnCloseNotif = document.getElementById('btnCloseNotif');

        // Fonction pour ouvrir le modal de notification
        function showNotification(type, title, message) {
            notifIcon.className = 'modal-icon ' + type;
            const icon = notifIcon.querySelector('i');
            if (type === 'success') {
                icon.className = 'fas fa-check-circle';
            } else if (type === 'error') {
                icon.className = 'fas fa-times-circle';
            } else if (type === 'warning') {
                icon.className = 'fas fa-exclamation-triangle';
            }
            notifTitle.textContent = title;
            notifMessage.textContent = message;
            notificationModal.classList.add('active');
        }

        // Déconnexion (confirmation)
        let logoutTarget = null;
        window.openLogoutModal = function(url){
            logoutTarget = url;
            document.getElementById('logoutModal').classList.add('active');
        };
        window.closeLogoutModal = function(){
            document.getElementById('logoutModal').classList.remove('active');
        };
        window.confirmLogout = function(){
            if (logoutTarget) window.location.href = logoutTarget;
        };
        document.getElementById('logoutModal')?.addEventListener('click', function(e){ if (e.target === this) window.closeLogoutModal(); });

        // Ouvrir le modal de confirmation d'annulation
        document.addEventListener('click', function(e) {
            const btn = e.target.closest('.btn-open-modal');
            if (!btn) return;
            
            const txId = btn.dataset.txid;
            const txType = btn.dataset.txtype;
            const proprietaire = btn.dataset.proprietaire;
            const contrepartie = btn.dataset.contrepartie;
            const montant = btn.dataset.montant;
            const date = btn.dataset.date;
            
            modalType.innerHTML = txType === 'ENVOI' 
                ? '<span class="badge badge-envoi">ENVOI</span>' 
                : '<span class="badge badge-retrait">RETRAIT</span>';
            modalTxId.textContent = txId;
            modalProprietaire.textContent = proprietaire;
            modalContrepartie.textContent = contrepartie;
            modalMontant.textContent = montant + ' Ar';
            modalDate.textContent = date;
            
            cancelTxType.value = txType;
            cancelTxId.value = txId;
            document.getElementById('returnType').value = document.getElementById('typeFilter').value || 'all';
            document.getElementById('returnSearch').value = document.getElementById('searchFilter').value || '';
            document.getElementById('returnDate').value = document.getElementById('dateFilter').value || '';
            
            cancelModal.classList.add('active');
        });

        // Fermer les modals
        function closeCancelModal() { cancelModal.classList.remove('active'); }
        function closeNotificationModal() { notificationModal.classList.remove('active'); }
        
        btnCancelModal.addEventListener('click', closeCancelModal);
        btnCloseNotif.addEventListener('click', closeNotificationModal);
        
        cancelModal.addEventListener('click', function(e) {
            if (e.target === cancelModal) closeCancelModal();
        });
        
        notificationModal.addEventListener('click', function(e) {
            if (e.target === notificationModal) closeNotificationModal();
        });

        // Échap pour fermer
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                if (cancelModal.classList.contains('active')) closeCancelModal();
                if (notificationModal.classList.contains('active')) closeNotificationModal();
                if (document.getElementById('logoutModal').classList.contains('active')) window.closeLogoutModal();
            }
        });

        // Afficher la notification si un message existe
        <% if (message != null && messageType != null) { %>
            showNotification('<%= messageType %>', '<%= "success".equals(messageType) ? "Succès" : "Erreur" %>', '<%= message.replace("'", "\\'") %>');
        <% } %>

        function filterRows() {
            filteredRows = [...rows];
            currentPage = 1;
            updateDisplay();
        }

        function updateDisplay() {
            const totalFiltered = filteredRows.length;
            const totalPages = Math.ceil(totalFiltered / ROWS_PER_PAGE) || 1;
            if (currentPage > totalPages) currentPage = totalPages;
            
            const start = (currentPage - 1) * ROWS_PER_PAGE;
            const end = start + ROWS_PER_PAGE;
            
            rows.forEach(row => row.style.display = 'none');
            filteredRows.forEach((row, index) => {
                if (index >= start && index < end) row.style.display = '';
            });
            
            if (emptyRow) emptyRow.style.display = totalFiltered === 0 ? '' : 'none';
            displayedCount.textContent = totalFiltered + ' ligne(s)';
            updatePagination(totalFiltered, totalPages, start, end);
        }

        function updatePagination(totalFiltered, totalPages, start, end) {
            if (totalFiltered === 0) {
                paginationInfo.textContent = 'Aucun résultat';
            } else {
                paginationInfo.textContent = (start + 1) + '–' + Math.min(end, totalFiltered) + ' sur ' + totalFiltered;
            }
            
            let html = '';
            html += '<button class="page-btn nav" ' + (currentPage === 1 ? 'disabled' : '') + ' data-page="prev">&laquo;</button>';
            
            const maxButtons = 5;
            let startPage = Math.max(1, currentPage - Math.floor(maxButtons / 2));
            let endPage = Math.min(totalPages, startPage + maxButtons - 1);
            if (endPage - startPage + 1 < maxButtons) startPage = Math.max(1, endPage - maxButtons + 1);
            
            for (let i = startPage; i <= endPage; i++) {
                html += '<button class="page-btn' + (i === currentPage ? ' active' : '') + '" data-page="' + i + '">' + i + '</button>';
            }
            
            html += '<button class="page-btn nav" ' + (currentPage === totalPages ? 'disabled' : '') + ' data-page="next">&raquo;</button>';
            paginationButtons.innerHTML = html;
            
            paginationButtons.querySelectorAll('.page-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    const page = this.dataset.page;
                    if (page === 'prev') { if (currentPage > 1) currentPage--; }
                    else if (page === 'next') { if (currentPage < totalPages) currentPage++; }
                    else { currentPage = parseInt(page); }
                    updateDisplay();
                    document.querySelector('.table-container').scrollIntoView({ behavior: 'smooth', block: 'start' });
                });
            });
        }

        filterRows();
    })();
</script>
</body>
</html>