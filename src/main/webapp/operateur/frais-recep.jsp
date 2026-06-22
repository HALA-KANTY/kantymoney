<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Gestion des Frais de Retrait</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background-color: #FAFAFA; color: #1A1A1A; min-height: 100vh; display: flex; }

        :root {
            --blanc: #FFFFFF; --gris-tres-clair: #F8F9FA; --gris-clair: #E9ECEF;
            --gris-moyen: #DEE2E6; --gris-fonce: #6C757D; --noir-doux: #212529;
            --marron: #C49450; --marron-clair: #D4A373; --marron-fonce: #A67A3E;
            --marron-tres-clair: #FDF6ED; --vert: #28A745; --rouge: #DC3545; --bleu: #0D6EFD;
        }

        .main-content { flex: 1; margin-left: 300px; padding: 28px 36px; }

        .page-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 24px; flex-wrap: wrap; gap: 16px;
        }
        .page-header h1 {
            font-size: 1.8rem; font-weight: 600; color: var(--noir-doux);
            display: flex; align-items: center; gap: 12px;
        }
        .page-header h1 i { color: var(--marron); font-size: 1.8rem; }

        .header-actions {
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }
        .search-wrapper {
            position: relative; display: flex; align-items: center;
        }
        .search-wrapper input {
            padding: 11px 14px 11px 38px; border: 2px solid var(--gris-moyen);
            border-radius: 10px; font-family: 'Inter', sans-serif; font-size: 0.88rem;
            width: 220px; transition: all 0.2s; background: var(--blanc);
        }
        .search-wrapper input:focus {
            outline: none; border-color: var(--marron);
            box-shadow: 0 0 0 3px rgba(196,148,80,0.1);
        }
        .search-wrapper .search-icon {
            position: absolute; left: 12px; color: var(--gris-fonce); font-size: 0.85rem;
        }

        .btn-add {
            padding: 12px 22px; background: var(--marron); color: white; border: none;
            border-radius: 10px; font-size: 0.9rem; font-weight: 600; cursor: pointer;
            display: flex; align-items: center; gap: 8px; transition: all 0.25s;
            font-family: 'Inter', sans-serif; white-space: nowrap;
        }
        .btn-add:hover { background: var(--marron-fonce); }

        /* ===== TABLEAU ===== */
        .table-container {
            background: var(--blanc); border: 1px solid var(--gris-clair);
            border-radius: 18px; overflow: hidden;
        }
        .table-header {
            padding: 16px 24px; border-bottom: 1px solid var(--gris-clair);
            display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;
        }
        .table-header h3 { font-size: 1rem; font-weight: 600; color: var(--noir-doux); display: flex; align-items: center; gap: 8px; }
        .table-header h3 i { color: var(--marron); }
        .count-badge {
            background: var(--marron-tres-clair); color: var(--marron);
            border-radius: 20px; padding: 4px 14px; font-size: 0.8rem; font-weight: 600;
        }
        .table-wrapper { overflow-x: auto; }
        table {
            width: 100%; border-collapse: collapse; min-width: 700px;
        }
        th, td {
            padding: 14px 18px; border-bottom: 1px solid var(--gris-clair);
            font-size: 0.88rem; text-align: left;
        }
        th {
            font-size: 0.75rem; color: var(--gris-fonce); text-transform: uppercase;
            letter-spacing: 0.5px; background: var(--gris-tres-clair); font-weight: 600;
        }
        tbody tr { transition: background 0.15s; }
        tbody tr:hover { background: var(--marron-tres-clair); }
        tbody tr:last-child td { border-bottom: none; }

        .tranche-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: var(--marron-tres-clair); color: var(--marron);
            padding: 5px 12px; border-radius: 20px; font-weight: 600; font-size: 0.85rem;
        }
        .montant-cell { font-weight: 600; color: var(--noir-doux); }
        .frais-cell { font-weight: 700; color: var(--marron); font-size: 0.92rem; }

        .action-buttons { display: flex; gap: 6px; }
        .btn-action {
            padding: 7px 14px; border-radius: 8px; font-size: 0.8rem; font-weight: 600;
            cursor: pointer; display: inline-flex; align-items: center; gap: 5px;
            transition: all 0.2s; border: 1.5px solid; font-family: 'Inter', sans-serif;
        }
        .btn-edit {
            background: var(--blanc); color: var(--bleu); border-color: var(--gris-moyen);
        }
        .btn-edit:hover { background: var(--bleu); color: white; border-color: var(--bleu); }
        .btn-delete {
            background: var(--blanc); color: var(--rouge); border-color: #FECACA;
        }
        .btn-delete:hover { background: var(--rouge); color: white; border-color: var(--rouge); }

        .empty-state {
            text-align: center; padding: 50px 20px; color: var(--gris-fonce);
        }
        .empty-state i { font-size: 3rem; color: var(--gris-moyen); margin-bottom: 12px; display: block; }
        .empty-state h3 { font-size: 1.1rem; font-weight: 600; color: var(--noir-doux); margin-bottom: 6px; }
        .empty-state p { font-size: 0.88rem; }

        .pagination-container {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 24px; border-top: 1px solid var(--gris-clair); flex-wrap: wrap; gap: 10px;
        }
        .pagination-info { color: var(--gris-fonce); font-size: 0.85rem; }
        .pagination-buttons { display: flex; gap: 5px; }
        .page-btn {
            width: 34px; height: 34px; border-radius: 8px; border: 2px solid var(--gris-moyen);
            background: var(--blanc); cursor: pointer; font-family: 'Inter', sans-serif;
            font-weight: 600; font-size: 0.82rem; transition: all 0.2s;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .page-btn:hover:not(:disabled) { border-color: var(--marron); color: var(--marron); }
        .page-btn.active { background: var(--marron); color: white; border-color: var(--marron); }
        .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
        .page-btn.nav { font-size: 1rem; }

        /* ===== MODAUX ===== */
        .modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.4); backdrop-filter: blur(4px);
            display: flex; align-items: center; justify-content: center; z-index: 2000;
            opacity: 0; visibility: hidden; transition: all 0.3s;
        }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        .modal {
            background: var(--blanc); border-radius: 22px; width: 90%; max-width: 460px;
            transform: scale(0.9) translateY(20px); transition: all 0.3s;
            box-shadow: 0 30px 60px rgba(0,0,0,0.15);
        }
        .modal-overlay.active .modal { transform: scale(1) translateY(0); }
        .modal-header {
            padding: 22px 26px 18px; border-bottom: 1px solid var(--gris-clair);
            display: flex; align-items: center; justify-content: space-between;
        }
        .modal-header h3 { font-size: 1.2rem; font-weight: 600; color: var(--noir-doux); display: flex; align-items: center; gap: 8px; }
        .modal-header h3 i { color: var(--marron); }
        .modal-close {
            width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center;
            justify-content: center; cursor: pointer; border: none;
            background: var(--gris-tres-clair); color: var(--gris-fonce); transition: all 0.2s;
        }
        .modal-close:hover { background: var(--rouge); color: white; }
        .modal-body { padding: 24px 26px; }
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block; color: var(--noir-doux); font-size: 0.85rem;
            font-weight: 600; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;
        }
        .form-group label i { color: var(--marron); }
        .input-wrapper { position: relative; }
        .input-wrapper input {
            width: 100%; padding: 13px 16px; background: var(--gris-tres-clair);
            border: 2px solid var(--gris-moyen); border-radius: 12px; font-size: 0.95rem;
            color: var(--noir-doux); transition: all 0.25s; outline: none;
            font-family: 'Inter', sans-serif;
        }
        .input-wrapper input:focus {
            border-color: var(--marron); background: var(--blanc);
            box-shadow: 0 0 0 3px rgba(196,148,80,0.1);
        }
        .input-wrapper .unit {
            position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
            color: var(--gris-fonce); font-size: 0.85rem; font-weight: 500;
        }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .modal-footer { padding: 16px 26px 24px; display: flex; gap: 10px; }
        .btn-modal-primary {
            flex: 1; padding: 13px 18px; background: var(--marron); color: white;
            border: none; border-radius: 12px; font-size: 0.95rem; font-weight: 600;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            gap: 8px; transition: all 0.25s; font-family: 'Inter', sans-serif;
        }
        .btn-modal-primary:hover { background: var(--marron-fonce); }
        .btn-modal-secondary {
            padding: 13px 20px; background: var(--blanc); color: var(--gris-fonce);
            border: 2px solid var(--gris-moyen); border-radius: 12px; font-size: 0.95rem;
            font-weight: 500; cursor: pointer; display: flex; align-items: center;
            justify-content: center; gap: 8px; transition: all 0.25s;
            font-family: 'Inter', sans-serif;
        }
        .btn-modal-secondary:hover { border-color: var(--marron); color: var(--marron); }

        .confirm-icon {
            width: 64px; height: 64px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 16px; font-size: 2rem;
        }
        .confirm-icon.warning { background: #FFF3CD; color: #FFC107; }
        .confirm-text { text-align: center; margin-bottom: 8px; }
        .confirm-text strong { color: var(--noir-doux); font-size: 1.1rem; }
        .confirm-detail { text-align: center; color: var(--gris-fonce); font-size: 0.9rem; }
        .btn-confirm-danger {
            flex: 1; padding: 13px 18px; background: var(--rouge); color: white;
            border: none; border-radius: 12px; font-size: 0.95rem; font-weight: 600;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            gap: 8px; transition: all 0.25s; font-family: 'Inter', sans-serif;
        }
        .btn-confirm-danger:hover { background: #C82333; }

        @media (max-width: 1000px) { .main-content { margin-left: 90px; padding: 20px; } }
        @media (max-width: 768px) {
            .page-header { flex-direction: column; align-items: flex-start; }
            .header-actions { width: 100%; }
            .search-wrapper { flex: 1; }
            .search-wrapper input { width: 100%; }
            .form-row { grid-template-columns: 1fr; }
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
                <a href="gestion-clients" class="nav-item"><i class="fas fa-users"></i><span>Utilisateurs</span></a>
                <a href="<%= request.getContextPath() %>/operateur/transactions" class="nav-item"><i class="fas fa-arrow-right-arrow-left"></i><span>Transactions</span></a>
                <a href="gestionFraisRecep" class="nav-item active"><i class="fas fa-hand-holding-dollar"></i><span>Frais de retrait</span></a>
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
        <div class="page-header">
            <h1>
                <i class="fas fa-hand-holding-dollar"></i>
                Gestion des Frais de Retrait
            </h1>
            
            <div class="header-actions">
                <div class="search-wrapper">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" id="searchInput" placeholder="Rechercher une tranche...">
                </div>
                <button class="btn-add" onclick="openModal('add')">
                    <i class="fas fa-plus-circle"></i>
                    Ajouter
                </button>
            </div>
        </div>
        
        <%
            List<String[]> tranches = (List<String[]>) request.getAttribute("listeFrais");
            int total = (tranches != null) ? tranches.size() : 0;
        %>
        
        <!-- TABLEAU -->
        <div class="table-container">
            <div class="table-header">
                <h3><i class="fas fa-list-ul"></i> Liste des frais de retrait</h3>
                <span class="count-badge" id="displayedCount"><%= total %> tranche<%= total > 1 ? "s" : "" %></span>
            </div>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th style="width: 120px;">Tranche</th>
                            <th>Montant minimum</th>
                            <th>Montant maximum</th>
                            <th>Frais de retrait</th>
                            <th style="text-align: center; width: 180px;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <% if (tranches != null && !tranches.isEmpty()) {
                            for (String[] t : tranches) { %>
                            <tr class="tarif-item" data-search="tranche <%= t[0] %> <%= t[1] %> <%= t[2] %> <%= t[3] %>">
                                <td>
                                    <span class="tranche-badge">
                                        <i class="fas fa-tag"></i> N°<%= t[0] %>
                                    </span>
                                </td>
                                <td class="montant-cell"><%= MoneyFormat.formatNullable(t[1]) %> Ar</td>
                                <td class="montant-cell"><%= MoneyFormat.formatNullable(t[2]) %> Ar</td>
                                <td class="frais-cell"><%= MoneyFormat.formatNullable(t[3]) %> Ar</td>
                                <td style="text-align: center;">
                                    <div class="action-buttons" style="justify-content: center;">
                                        <button class="btn-action btn-edit" onclick='openModal("edit", "<%= t[0] %>", <%= t[1] %>, <%= t[2] %>, <%= t[3] %>)'>
                                            <i class="fas fa-pen"></i> Modifier
                                        </button>
                                        <button class="btn-action btn-delete" onclick='openConfirmDelete("<%= t[0] %>", "<%= MoneyFormat.formatNullable(t[1]) %>", "<%= MoneyFormat.formatNullable(t[2]) %>", "<%= MoneyFormat.formatNullable(t[3]) %>")'>
                                            <i class="fas fa-trash"></i> Supprimer
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <%  }
                        } else { %>
                            <tr id="emptyRow">
                                <td colspan="5">
                                    <div class="empty-state">
                                        <i class="fas fa-tags"></i>
                                        <h3>Aucun tarif configuré</h3>
                                        <p>Commencez par ajouter votre première tranche tarifaire pour les retraits</p>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <div class="pagination-container" id="paginationContainer" style="<%= (tranches == null || tranches.isEmpty()) ? "display:none;" : "" %>">
                <div class="pagination-info" id="paginationInfo"></div>
                <div class="pagination-buttons" id="paginationButtons"></div>
            </div>
        </div>
    </main>
    
    <!-- MODAL FORMULAIRE (Ajout / Modification) -->
    <div class="modal-overlay" id="modalOverlay">
        <div class="modal">
            <div class="modal-header">
                <h3 id="modalTitle"><i class="fas fa-plus-circle"></i> Nouveau tarif de retrait</h3>
                <button class="modal-close" onclick="closeModal()"><i class="fas fa-times"></i></button>
            </div>
            <form action="<%= request.getContextPath() %>/operateur/gestionFraisRecep" method="POST" id="fraisForm">
                <input type="hidden" name="action" id="formAction" value="create">
                <input type="hidden" name="idRec" id="tarifId">
                <div class="modal-body">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="montantMin"><i class="fas fa-arrow-down"></i> Montant minimum</label>
                            <div class="input-wrapper">
                                <input type="number" name="montant1" id="montantMin" placeholder="0" required>
                                <span class="unit">Ar</span>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="montantMax"><i class="fas fa-arrow-up"></i> Montant maximum</label>
                            <div class="input-wrapper">
                                <input type="number" name="montant2" id="montantMax" placeholder="50000" required>
                                <span class="unit">Ar</span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="fraisRetrait"><i class="fas fa-coins"></i> Frais de retrait</label>
                        <div class="input-wrapper">
                            <input type="number" name="frais_rec" id="fraisRetrait" placeholder="1000" required>
                            <span class="unit">Ar</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-modal-secondary" onclick="closeModal()"><i class="fas fa-times"></i> Annuler</button>
                    <button type="submit" class="btn-modal-primary" id="submitBtn"><i class="fas fa-save"></i> Enregistrer</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL CONFIRMATION SUPPRESSION -->
    <div class="modal-overlay" id="confirmDeleteModal">
        <div class="modal">
            <div class="modal-header">
                <h3><i class="fas fa-triangle-exclamation" style="color: var(--rouge);"></i> Confirmer la suppression</h3>
                <button class="modal-close" onclick="closeConfirmDelete()"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <div class="confirm-icon warning">
                    <i class="fas fa-trash-can"></i>
                </div>
                <div class="confirm-text">
                    <strong>Supprimer cette tranche tarifaire ?</strong>
                </div>
                <div class="confirm-detail" id="confirmDetail">
                    Cette action est irréversible.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-secondary" onclick="closeConfirmDelete()">
                    <i class="fas fa-times"></i> Annuler
                </button>
                <form action="<%= request.getContextPath() %>/operateur/gestionFraisRecep" method="POST" id="deleteForm" style="flex:1;display:flex;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="idRec" id="deleteIdRec">
                    <button type="submit" class="btn-confirm-danger">
                        <i class="fas fa-trash"></i> Supprimer définitivement
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL NOTIFICATION (succès / erreur) -->
    <div class="modal-overlay" id="notifModal">
        <div class="modal" style="max-width:520px;">
            <div class="modal-header">
                <h3 id="notifTitle"><i class="fas fa-circle-check"></i> Succès</h3>
                <button class="modal-close" onclick="closeNotif()"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <p id="notifMsg" style="color: var(--gris-fonce); line-height: 1.5;"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-primary" onclick="closeNotif()" style="flex:1;">
                    <i class="fas fa-check"></i> OK
                </button>
            </div>
        </div>
    </div>

    <!-- MODAL CONFIRMATION DÉCONNEXION -->
    <div id="logoutModal" class="modal-overlay">
        <div class="modal" style="max-width:520px;">
            <div class="modal-header">
                <h3><i class="fas fa-power-off"></i> Déconnexion</h3>
                <button class="modal-close" onclick="closeLogoutModal()"><i class="fas fa-times"></i></button>
            </div>
            <div class="modal-body">
                <p style="color: var(--gris-fonce); line-height: 1.5;">Voulez-vous vous déconnecter ? Votre session opérateur sera fermée.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal-secondary" onclick="closeLogoutModal()"><i class="fas fa-times"></i> Annuler</button>
                <button type="button" class="btn-modal-primary" onclick="confirmLogout()"><i class="fas fa-check"></i> Se déconnecter</button>
            </div>
        </div>
    </div>
    
    <script>
        // ===== MODAL FORMULAIRE =====
        const modal = document.getElementById('modalOverlay');
        const modalTitle = document.getElementById('modalTitle');
        const formAction = document.getElementById('formAction');
        const tarifId = document.getElementById('tarifId');
        const montantMin = document.getElementById('montantMin');
        const montantMax = document.getElementById('montantMax');
        const fraisRetrait = document.getElementById('fraisRetrait');
        const submitBtn = document.getElementById('submitBtn');

        // ===== MODAL CONFIRMATION SUPPRESSION =====
        const confirmDeleteModal = document.getElementById('confirmDeleteModal');
        const confirmDetail = document.getElementById('confirmDetail');
        const deleteIdRec = document.getElementById('deleteIdRec');

        // ===== MODAL NOTIFICATION =====
        const notifModal = document.getElementById('notifModal');
        const notifTitle = document.getElementById('notifTitle');
        const notifMsg = document.getElementById('notifMsg');

        function showNotif(type, title, msg) {
            const ok = type === 'success';
            notifTitle.innerHTML = (ok ? '<i class="fas fa-circle-check"></i> ' : '<i class="fas fa-circle-exclamation"></i> ') + (title || (ok ? 'Succès' : 'Erreur'));
            notifTitle.querySelector('i').style.color = ok ? 'var(--vert)' : 'var(--rouge)';
            notifMsg.textContent = msg || '';
            notifModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeNotif() {
            notifModal.classList.remove('active');
            document.body.style.overflow = '';
        }

        notifModal.addEventListener('click', function(e) { if (e.target === notifModal) closeNotif(); });

        // Déconnexion (confirmation)
        let logoutTarget = null;
        function openLogoutModal(url){
            logoutTarget = url;
            document.getElementById('logoutModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeLogoutModal(){
            document.getElementById('logoutModal').classList.remove('active');
            document.body.style.overflow = '';
        }
        function confirmLogout(){
            if (logoutTarget) window.location.href = logoutTarget;
        }
        document.getElementById('logoutModal')?.addEventListener('click', function(e){ if (e.target === this) closeLogoutModal(); });
        
        function openModal(mode, id, m1, m2, frais) {
            if (mode === 'add') {
                modalTitle.innerHTML = '<i class="fas fa-plus-circle"></i> Nouveau tarif de retrait';
                submitBtn.innerHTML = '<i class="fas fa-save"></i> Enregistrer';
                submitBtn.style.background = 'var(--marron)';
                formAction.value = 'create';
                tarifId.value = '';
                montantMin.value = '';
                montantMax.value = '';
                fraisRetrait.value = '';
            } else {
                modalTitle.innerHTML = '<i class="fas fa-pen"></i> Modifier le tarif de retrait';
                submitBtn.innerHTML = '<i class="fas fa-check"></i> Mettre à jour';
                submitBtn.style.background = 'var(--vert)';
                formAction.value = 'update';
                tarifId.value = id || '';
                montantMin.value = m1 || '';
                montantMax.value = m2 || '';
                fraisRetrait.value = frais || '';
            }
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal() {
            modal.classList.remove('active');
            document.body.style.overflow = '';
        }

        function openConfirmDelete(id, min, max, frais) {
            deleteIdRec.value = id;
            confirmDetail.innerHTML = 'Tranche N°<strong>' + id + '</strong> : <strong>' + min + ' Ar</strong> → <strong>' + max + ' Ar</strong> (frais : <strong>' + frais + ' Ar</strong>)<br><br>Cette action est irréversible.';
            confirmDeleteModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeConfirmDelete() {
            confirmDeleteModal.classList.remove('active');
            document.body.style.overflow = '';
        }
        
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                if (confirmDeleteModal.classList.contains('active')) closeConfirmDelete();
                if (modal.classList.contains('active')) closeModal();
            }
        });
        
        modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });
        confirmDeleteModal.addEventListener('click', function(e) { if (e.target === confirmDeleteModal) closeConfirmDelete(); });
        
        document.getElementById('fraisForm').addEventListener('submit', function(e) {
            const m1 = parseFloat(montantMin.value);
            const m2 = parseFloat(montantMax.value);
            const frais = parseFloat(fraisRetrait.value);
            if (m1 >= m2) { e.preventDefault(); showNotif('error', 'Validation', 'Le montant minimum doit être inférieur au montant maximum'); return false; }
            if (m1 < 0 || m2 < 0 || frais < 0) { e.preventDefault(); showNotif('error', 'Validation', 'Les montants ne peuvent pas être négatifs'); return false; }
            return true;
        });
        
        document.querySelectorAll('input[type="number"]').forEach(input => {
            input.addEventListener('input', function() { if (this.value < 0) this.value = 0; });
        });

        // ===== PAGINATION + RECHERCHE DYNAMIQUE =====
        (function() {
            const items = Array.from(document.querySelectorAll('.tarif-item'));
            const emptyRow = document.getElementById('emptyRow');
            const searchInput = document.getElementById('searchInput');
            const displayedCount = document.getElementById('displayedCount');
            const paginationContainer = document.getElementById('paginationContainer');
            const paginationInfo = document.getElementById('paginationInfo');
            const paginationButtons = document.getElementById('paginationButtons');
            const ITEMS_PER_PAGE = 9;
            let currentPage = 1;
            let filteredItems = [...items];

            if (items.length === 0) return;

            function filterItems() {
                const search = searchInput.value.toLowerCase().trim();
                
                filteredItems = items.filter(item => {
                    if (!search) return true;
                    return item.dataset.search.includes(search);
                });
                
                currentPage = 1;
                updateDisplay();
            }

            function updateDisplay() {
                const totalFiltered = filteredItems.length;
                const totalPages = Math.ceil(totalFiltered / ITEMS_PER_PAGE) || 1;
                
                if (currentPage > totalPages) currentPage = totalPages;
                
                const start = (currentPage - 1) * ITEMS_PER_PAGE;
                const end = start + ITEMS_PER_PAGE;
                
                items.forEach(item => item.style.display = 'none');
                
                filteredItems.forEach((item, index) => {
                    if (index >= start && index < end) {
                        item.style.display = '';
                    }
                });
                
                if (emptyRow) {
                    emptyRow.style.display = totalFiltered === 0 ? '' : 'none';
                }
                
                displayedCount.textContent = totalFiltered + ' tranche' + (totalFiltered > 1 ? 's' : '');
                paginationContainer.style.display = totalFiltered === 0 ? 'none' : '';
                
                updatePagination(totalFiltered, totalPages, start, end);
            }

            function updatePagination(totalFiltered, totalPages, start, end) {
                if (totalFiltered === 0) {
                    paginationInfo.textContent = 'Aucun résultat';
                } else {
                    paginationInfo.textContent = (start + 1) + '–' + Math.min(end, totalFiltered) + ' sur ' + totalFiltered + ' tarif(s)';
                }
                
                let html = '';
                html += '<button class="page-btn nav" ' + (currentPage === 1 ? 'disabled' : '') + ' data-page="prev">&laquo;</button>';
                
                const maxButtons = 5;
                let startPage = Math.max(1, currentPage - Math.floor(maxButtons / 2));
                let endPage = Math.min(totalPages, startPage + maxButtons - 1);
                if (endPage - startPage + 1 < maxButtons) {
                    startPage = Math.max(1, endPage - maxButtons + 1);
                }
                
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

            searchInput.addEventListener('input', filterItems);
            filterItems();
        })();

        <%-- Flash serveur -> modal notification --%>
        <%
            Object msgObj = request.getAttribute("message");
            String type = (String) request.getAttribute("messageType");
            if (msgObj != null && type != null) {
                String raw = String.valueOf(msgObj);
                String jsMsg = raw.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n");
                boolean ok = "success".equals(type);
        %>
            showNotif("<%= ok ? "success" : "error" %>", "<%= ok ? "Succès" : "Erreur" %>", "<%= jsMsg %>");
        <%
            }
        %>
    </script>
</body>
</html>