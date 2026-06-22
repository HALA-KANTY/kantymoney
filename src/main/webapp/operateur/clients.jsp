<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Gestion des Clients</title>
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
        .page-title h1 {
            font-size: 1.8rem; font-weight: 600; color: var(--noir-doux);
            display: flex; align-items: center; gap: 12px; margin-bottom: 4px;
        }
        .page-title h1 i { color: var(--marron); font-size: 1.8rem; }
        .page-title p { color: var(--gris-fonce); font-size: 0.85rem; }

        /* Recherche intégrée dans le header */
        .header-search {
            display: flex; align-items: center; gap: 8px;
        }
        .header-search input {
            padding: 10px 14px 10px 38px; border: 2px solid var(--gris-moyen);
            border-radius: 10px; font-family: 'Inter', sans-serif; font-size: 0.9rem;
            width: 260px; transition: all 0.2s; background: var(--blanc);
        }
        .header-search input:focus {
            outline: none; border-color: var(--marron);
            box-shadow: 0 0 0 3px rgba(196,148,80,0.1);
        }
        .header-search .search-icon {
            position: absolute; margin-left: 12px; color: var(--gris-fonce); font-size: 0.9rem;
        }
        .search-input-wrapper { position: relative; display: flex; align-items: center; }

        /* Messages */
        .alert {
            padding: 14px 18px; border-radius: 14px; margin-bottom: 20px;
            font-size: 0.9rem; font-weight: 500; display: flex; align-items: center; gap: 10px;
        }
        .alert-success { background: #F0FDF4; color: var(--vert); border-left: 4px solid var(--vert); }
        .alert-error { background: #FEF2F2; color: var(--rouge); border-left: 4px solid var(--rouge); }

        /* Tableau */
        .table-container {
            background: var(--blanc); border: 1px solid var(--gris-clair);
            border-radius: 20px; overflow: hidden;
        }
        .table-header {
            padding: 18px 24px; border-bottom: 1px solid var(--gris-clair);
            display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px;
        }
        .table-header h3 { font-size: 1.05rem; font-weight: 600; color: var(--noir-doux); display: flex; align-items: center; gap: 8px; }
        .table-header h3 i { color: var(--marron); }
        .client-count {
            background: var(--marron-tres-clair); color: var(--marron);
            padding: 4px 14px; border-radius: 20px; font-size: 0.82rem; font-weight: 600;
        }
        .table-wrapper { overflow-x: auto; }
        .client-table { width: 100%; border-collapse: collapse; min-width: 800px; }
        .client-table th {
            text-align: left; padding: 14px 18px; font-size: 0.73rem; font-weight: 600;
            color: var(--gris-fonce); text-transform: uppercase; letter-spacing: 0.4px;
            border-bottom: 1px solid var(--gris-clair); background: var(--blanc);
        }
        .client-table td {
            padding: 14px 18px; border-bottom: 1px solid var(--gris-clair);
            font-size: 0.88rem; color: var(--noir-doux);
        }
        .client-table tr:last-child td { border-bottom: none; }
        .client-table tbody tr:hover { background: var(--gris-tres-clair); }

        .client-cell { display: flex; align-items: center; gap: 12px; }
        .client-avatar {
            width: 42px; height: 42px; background: var(--marron-tres-clair);
            border-radius: 12px; display: flex; align-items: center; justify-content: center;
            color: var(--marron); font-weight: 700; font-size: 1rem; flex-shrink: 0;
        }
        .client-info h4 { font-size: 0.95rem; font-weight: 600; color: var(--noir-doux); margin-bottom: 2px; }
        .client-info .client-details { font-size: 0.73rem; color: var(--gris-fonce); }

        .badge-phone {
            background: var(--gris-tres-clair); padding: 5px 12px; border-radius: 20px;
            font-size: 0.82rem; font-weight: 500; color: var(--noir-doux);
            display: inline-flex; align-items: center; gap: 6px;
        }
        .badge-phone i { color: var(--marron); font-size: 0.75rem; }
        .badge-solde {
            background: var(--marron-tres-clair); padding: 5px 12px; border-radius: 20px;
            font-size: 0.82rem; font-weight: 600; color: var(--marron);
            display: inline-flex; align-items: center; gap: 6px;
        }
        .badge-sexe, .badge-age {
            background: var(--gris-clair); padding: 3px 8px; border-radius: 16px;
            font-size: 0.73rem; color: var(--noir-doux); display: inline-flex; align-items: center; gap: 4px;
        }
        .badges-row { display: flex; gap: 5px; flex-wrap: wrap; }

        /* Boutons action */
        .action-buttons { display: flex; gap: 6px; }
        .btn-action {
            padding: 7px 14px; border-radius: 8px; font-size: 0.8rem; font-weight: 600;
            cursor: pointer; transition: all 0.2s; font-family: 'Inter', sans-serif;
            border: 1.5px solid; display: inline-flex; align-items: center; gap: 5px;
        }
        .btn-depot-action {
            background: #ECFDF3; color: #166534; border-color: #D1FAE5;
        }
        .btn-depot-action:hover { background: #166534; color: white; border-color: #166534; }
        .btn-delete-action {
            background: #FEF2F2; color: var(--rouge); border-color: #FECACA;
        }
        .btn-delete-action:hover { background: var(--rouge); color: white; border-color: var(--rouge); }

        /* Pagination */
        .pagination-container {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 24px; border-top: 1px solid var(--gris-clair); flex-wrap: wrap; gap: 10px;
        }
        .pagination-info { color: var(--gris-fonce); font-size: 0.82rem; }
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

        /* Empty state */
        .empty-state { padding: 60px 30px; text-align: center; }
        .empty-state i { font-size: 4rem; color: var(--gris-moyen); margin-bottom: 16px; display: block; }
        .empty-state h3 { font-size: 1.2rem; font-weight: 600; color: var(--noir-doux); margin-bottom: 6px; }
        .empty-state p { color: var(--gris-fonce); font-size: 0.9rem; }

        /* Modal */
        .modal-overlay {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.4); backdrop-filter: blur(4px);
            display: flex; align-items: center; justify-content: center; z-index: 2000;
            opacity: 0; visibility: hidden; transition: all 0.3s;
        }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        .modal {
            background: var(--blanc); border-radius: 22px; width: 90%; max-width: 420px;
            transform: scale(0.9) translateY(20px); transition: all 0.3s;
            box-shadow: 0 30px 60px rgba(0,0,0,0.15); overflow: hidden;
        }
        .modal-overlay.active .modal { transform: scale(1) translateY(0); }
        .modal-body { padding: 28px; text-align: center; }
        .modal-icon {
            width: 60px; height: 60px; border-radius: 50%; display: flex;
            align-items: center; justify-content: center; margin: 0 auto 16px; font-size: 1.6rem;
        }
        .modal-icon.warning { background: #FEF2F2; color: var(--rouge); }
        .modal-icon.success { background: #F0FDF4; color: var(--vert); }
        .modal-body h3 { font-size: 1.2rem; font-weight: 600; color: var(--noir-doux); margin-bottom: 8px; }
        .modal-body p { color: var(--gris-fonce); font-size: 0.9rem; margin-bottom: 4px; }
        .modal-body .client-name { font-weight: 600; color: var(--noir-doux); }
        .modal-footer {
            padding: 0 28px 28px; display: flex; gap: 10px;
        }
        .btn-modal {
            flex: 1; padding: 12px 18px; border-radius: 12px; font-size: 0.9rem;
            font-weight: 600; cursor: pointer; display: flex; align-items: center;
            justify-content: center; gap: 6px; transition: all 0.2s;
            border: none; font-family: 'Inter', sans-serif;
        }
        .btn-modal-danger { background: var(--rouge); color: white; }
        .btn-modal-danger:hover { background: #c82333; }
        .btn-modal-secondary { background: var(--blanc); color: var(--gris-fonce); border: 2px solid var(--gris-moyen); }
        .btn-modal-secondary:hover { border-color: var(--marron); color: var(--marron); }
        .btn-modal-primary { background: var(--marron); color: white; }
        .btn-modal-primary:hover { background: var(--marron-fonce); }

        .kpi {
            background: #F8F9FA; border: 1px solid #E9ECEF; border-radius: 12px;
            padding: 10px 14px; margin: 12px 0; display: flex;
            justify-content: space-between; font-size: 0.88rem;
        }
        .field { display: flex; flex-direction: column; gap: 5px; margin-top: 10px; text-align: left; }
        .field label { font-size: 0.75rem; color: var(--gris-fonce); font-weight: 600; text-transform: uppercase; }
        .field input, .field select {
            padding: 11px 14px; border-radius: 10px; border: 2px solid var(--gris-moyen);
            font-family: 'Inter', sans-serif; font-size: 0.9rem; outline: none;
            background: var(--blanc);
        }
        .field input:focus, .field select:focus { border-color: var(--marron); }

        .table-header-actions { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .btn-header-add {
            padding: 10px 18px; border-radius: 12px; font-size: 0.88rem; font-weight: 600;
            cursor: pointer; font-family: 'Inter', sans-serif; border: none;
            background: var(--marron); color: white; display: inline-flex; align-items: center; gap: 8px;
            transition: all 0.2s;
        }
        .btn-header-add:hover { background: var(--marron-fonce); }

        .modal.modal-form { max-width: 750px; }
        .modal-body.modal-body--form {
            text-align: left; padding: 24px 28px;
        }
        .modal-body.modal-body--form > h3 { text-align: center; }
        .modal-body.modal-body--form > p:first-of-type { text-align: center; }
        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        .field-hint {
            font-size: 0.78rem; color: var(--gris-fonce); margin-top: 4px; line-height: 1.35;
        }
        .code-pill {
            display: inline-flex; align-items: center; gap: 6px; margin-top: 6px;
            padding: 8px 12px; border-radius: 10px; background: var(--marron-tres-clair);
            border: 1px solid rgba(196,148,80,0.25); font-size: 0.85rem; font-weight: 600; color: var(--marron-fonce);
        }

        /* Disposition horizontale pour le formulaire d'ajout */
        .form-horizontal {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0 24px;
        }
        .form-horizontal .field-full {
            grid-column: 1 / -1;
        }
        .modal-body.modal-body--form .modal-footer-horizontal {
            grid-column: 1 / -1;
            display: flex;
            gap: 10px;
            margin-top: 16px;
            padding: 0;
            border-top: 0;
        }
        .modal-body.modal-body--form .form-header-text {
            grid-column: 1 / -1;
            text-align: center;
            margin-bottom: 8px;
        }

        @media (max-width: 1200px) { .page-header { flex-direction: column; align-items: flex-start; } }
        @media (max-width: 1000px) { .main-content { margin-left: 90px; padding: 20px; } }
        @media (max-width: 768px) { .client-table { min-width: 700px; } .form-horizontal { grid-template-columns: 1fr; } .modal.modal-form { max-width: 420px; } }
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
                <a href="gestion-clients" class="nav-item active"><i class="fas fa-users"></i><span>Utilisateurs</span></a>
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
        <div class="page-header">
            <div class="page-title">
                <h1><i class="fas fa-users"></i> Gestion des Clients</h1>
                <p id="headerSubtitle"><%= request.getAttribute("searchResult") != null ? request.getAttribute("searchResult") : "Liste complète des clients enregistrés sur la plateforme" %></p>
            </div>
            
            <!-- Recherche intégrée dans le header -->
            <div class="header-search">
                <div class="search-input-wrapper">
                    <i class="fas fa-search search-icon"></i>
                    <input type="text" id="searchInput" placeholder="Rechercher nom ou téléphone..." value="<%= request.getAttribute("searchQuery") != null ? request.getAttribute("searchQuery") : "" %>">
                </div>
            </div>
        </div>

        <%
            List<String[]> clients = (List<String[]>) request.getAttribute("clients");
            int totalClients = (clients != null) ? clients.size() : 0;
        %>
        
        <div class="table-container">
            <div class="table-header">
                <h3><i class="fas fa-list"></i> Liste des clients</h3>
                <div class="table-header-actions">
                    <button type="button" class="btn-header-add" onclick="openAddClientModal()">
                        <i class="fas fa-user-plus"></i> Ajouter un client
                    </button>
                    <span class="client-count" id="displayedCount"><%= totalClients %> client<%= totalClients > 1 ? "s" : "" %></span>
                </div>
            </div>
            
            <div class="table-wrapper">
                <table class="client-table" id="clientTable">
                    <thead>
                        <tr>
                            <th>Client</th>
                            <th>Téléphone</th>
                            <th>Informations</th>
                            <th>Solde</th>
                            <th style="text-align: center;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="clientTableBody">
                        <% if (clients != null && !clients.isEmpty()) {
                            for (String[] c : clients) {
                                String numtel = c[0];
                                String nom = c[1];
                                String sexe = c[2];
                                String age = c[3];
                                String solde = c[4];
                                String mail = c[5];
                                
                                String initiales = "";
                                if (nom != null && !nom.trim().isEmpty()) {
                                    String[] noms = nom.trim().split("\\s+");
                                    if (noms.length >= 2) {
                                        initiales = noms[0].substring(0,1) + noms[1].substring(0,1);
                                    } else {
                                        initiales = nom.substring(0, Math.min(2, nom.length()));
                                    }
                                }
                        %>
                        <tr class="client-row" data-search="<%= (nom + " " + numtel).toLowerCase() %>">
                            <td>
                                <div class="client-cell">
                                    <div class="client-avatar"><%= initiales.toUpperCase() %></div>
                                    <div class="client-info">
                                        <h4><%= nom %></h4>
                                        <div class="client-details"><%= mail != null ? mail : "N/A" %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge-phone">
                                    <i class="fas fa-mobile-alt"></i> <%= numtel %>
                                </span>
                            </td>
                            <td>
                                <div class="badges-row">
                                    <span class="badge-sexe"><i class="fas fa-<%= "Masculin".equals(sexe) ? "mars" : "venus" %>"></i> <%= sexe %></span>
                                    <span class="badge-age"><%= age %> ans</span>
                                </div>
                            </td>
                            <td>
                                <span class="badge-solde">
                                    <i class="fas fa-coins"></i> <%= MoneyFormat.formatNullable(solde) %> Ar
                                </span>
                            </td>
                            <td style="text-align: center;">
                                <div class="action-buttons">
                                    <button class="btn-action btn-depot-action" onclick='openDepotModal("<%= numtel %>", "<%= nom.replace("\"", "\\\"") %>", "<%= solde %>")'>Déposer</button>
                                    <button class="btn-action btn-delete-action" onclick='openDeleteModal("<%= numtel %>", "<%= nom.replace("\"", "\\\"") %>")'>Supprimer</button>
                                </div>
                            </td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr id="emptyRow">
                            <td colspan="5">
                                <div class="empty-state">
                                    <i class="fas fa-user-slash"></i>
                                    <h3>Aucun client trouvé</h3>
                                    <p>Essayez une autre recherche ou vérifiez la base de données.</p>
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

    <!-- MODALS -->
    <div class="modal-overlay" id="deleteModal">
        <div class="modal">
            <div class="modal-body">
                <div class="modal-icon warning"><i class="fas fa-exclamation-triangle"></i></div>
                <h3>Confirmer la suppression</h3>
                <p>Êtes-vous sûr de vouloir supprimer le client :</p>
                <p class="client-name" id="deleteClientName"></p>
                <p style="color: var(--rouge); font-size: 0.82rem; margin-top: 6px;">Cette action est irréversible.</p>
            </div>
            <div class="modal-footer">
                <button class="btn-modal btn-modal-secondary" onclick="closeDeleteModal()"><i class="fas fa-times"></i> Annuler</button>
                <form action="<%= request.getContextPath() %>/operateur/gestion-clients" method="POST" style="flex:1;display:flex;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="numtel" id="deleteNumtel">
                    <button type="submit" class="btn-modal btn-modal-danger" style="width:100%;"><i class="fas fa-trash"></i> Supprimer</button>
                </form>
            </div>
        </div>
    </div>

    <div class="modal-overlay" id="successModal">
        <div class="modal">
            <div class="modal-body">
                <div class="modal-icon success"><i class="fas fa-check-circle"></i></div>
                <h3 id="successTitle">Succès</h3>
                <p id="successMsg">Opération effectuée.</p>
            </div>
            <div class="modal-footer">
                <button class="btn-modal btn-modal-primary" onclick="closeSuccessModal()" style="flex:1;"><i class="fas fa-check"></i> OK</button>
            </div>
        </div>
    </div>

    <div class="modal-overlay" id="addClientModal">
        <div class="modal modal-form">
            <div class="modal-body modal-body--form">
                <div class="form-header-text">
                    <div class="modal-icon success" style="margin: 0 auto 10px;"><i class="fas fa-user-plus"></i></div>
                    <h3>Ajouter un client</h3>
                    <p style="font-size:0.85rem;color:var(--gris-fonce);margin-bottom:10px;">Même informations que l'inscription : le solde initial est saisi ici ; le code secret est défini automatiquement.</p>
                </div>
                <form action="<%= request.getContextPath() %>/operateur/gestion-clients" method="POST" id="addClientForm">
                    <input type="hidden" name="action" value="create">
                    <div class="form-horizontal">
                        <div class="field">
                            <label>Numéro de téléphone</label>
                            <input type="tel" name="numtel" id="ac_numtel" placeholder="0324432167" pattern="[0-9]{10}" maxlength="10" inputmode="numeric" required>
                        </div>
                        <div class="field">
                            <label>Nom complet</label>
                            <input type="text" name="nom" id="ac_nom" placeholder="Rakoto Bernard" required>
                        </div>
                        <div class="field">
                            <label>Sexe</label>
                            <select name="sexe" id="ac_sexe" required>
                                <option value="">Sélectionner</option>
                                <option value="Masculin">Masculin</option>
                                <option value="Féminin">Féminin</option>
                            </select>
                        </div>
                        <div class="field">
                            <label>Âge</label>
                            <input type="number" name="age" id="ac_age" placeholder="25" min="18" max="120" required>
                        </div>
                        <div class="field">
                            <label>Adresse email</label>
                            <input type="email" name="mail" id="ac_mail" placeholder="rakoto@example.com" required>
                        </div>
                        <div class="field">
                            <label>Solde initial (Ar)</label>
                            <input type="number" name="solde" id="ac_solde" min="0" step="1" value="0" placeholder="0">
                            <div class="field-hint">Montant crédité dès la création du compte (0 si vide).</div>
                        </div>
                        <div class="field">
                            <label>Code secret</label>
                            <div class="code-pill"><i class="fas fa-lock"></i> 0000 <span style="font-weight:500;color:var(--gris-fonce);font-size:0.8rem;">(automatique, non modifiable ici)</span></div>
                            <div class="field-hint">Le client pourra changer son code depuis son espace personnel.</div>
                        </div>
                        <div class="modal-footer-horizontal">
                            <button type="button" class="btn-modal btn-modal-secondary" onclick="closeAddClientModal()" style="flex:1;"><i class="fas fa-times"></i> Annuler</button>
                            <button type="submit" class="btn-modal btn-modal-primary" style="flex:1;"><i class="fas fa-check"></i> Créer le client</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal-overlay" id="depotModal">
        <div class="modal">
            <div class="modal-body">
                <div class="modal-icon success"><i class="fas fa-coins"></i></div>
                <h3>Faire un dépôt</h3>
                <p style="font-size:0.85rem;color:var(--gris-fonce);">Créditer le solde de l'utilisateur sélectionné.</p>
                <div class="kpi">
                    <span><strong>Client</strong> <span id="depNom"></span></span>
                    <span id="depSolde" style="font-weight:700;"></span>
                </div>
                <form action="<%= request.getContextPath() %>/operateur/gestion-clients" method="POST" id="depForm">
                    <input type="hidden" name="action" value="depot">
                    <input type="hidden" name="numtel" id="depNumtel">
                    <div class="field">
                        <label>Montant à déposer (Ar)</label>
                        <input type="number" name="montant" id="depMontant" min="1" step="1" placeholder="10 000" required>
                    </div>
                    <div class="modal-footer" style="padding:0;border-top:0;margin-top:14px;">
                        <button type="button" class="btn-modal btn-modal-secondary" onclick="closeDepotModal()" style="flex:1;"><i class="fas fa-times"></i> Annuler</button>
                        <button type="submit" class="btn-modal btn-modal-primary" style="flex:1;"><i class="fas fa-check"></i> Confirmer</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

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
        // ===== PAGINATION + RECHERCHE DYNAMIQUE =====
        (function() {
            const rows = Array.from(document.querySelectorAll('.client-row'));
            const emptyRow = document.getElementById('emptyRow');
            const searchInput = document.getElementById('searchInput');
            const displayedCount = document.getElementById('displayedCount');
            const paginationInfo = document.getElementById('paginationInfo');
            const paginationButtons = document.getElementById('paginationButtons');
            const headerSubtitle = document.getElementById('headerSubtitle');
            const ROWS_PER_PAGE = 7; // CHANGÉ : 10 -> 7 lignes par page
            let currentPage = 1;
            let filteredRows = [...rows];

            function filterRows() {
                const search = searchInput.value.toLowerCase().trim();
                
                filteredRows = rows.filter(row => {
                    if (!search) return true;
                    return row.dataset.search.includes(search);
                });
                
                // Mettre à jour le sous-titre
                if (headerSubtitle) {
                    if (search) {
                        headerSubtitle.textContent = filteredRows.length + ' résultat(s) pour "' + search + '"';
                    } else {
                        headerSubtitle.textContent = 'Liste complète des clients enregistrés sur la plateforme';
                    }
                }
                
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
                    if (index >= start && index < end) {
                        row.style.display = '';
                    }
                });
                
                if (emptyRow) {
                    emptyRow.style.display = totalFiltered === 0 ? '' : 'none';
                }
                
                displayedCount.textContent = totalFiltered + ' client' + (totalFiltered > 1 ? 's' : '');
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

            // Recherche dynamique (pas de bouton, pas de délai serveur)
            searchInput.addEventListener('input', filterRows);

            // Initialisation
            filterRows();
        })();

        // ===== MODALS =====
        const deleteModal = document.getElementById('deleteModal');
        const deleteClientName = document.getElementById('deleteClientName');
        const deleteNumtel = document.getElementById('deleteNumtel');

        function openDeleteModal(numtel, nom) {
            deleteNumtel.value = numtel;
            deleteClientName.textContent = nom;
            deleteModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeDeleteModal() {
            deleteModal.classList.remove('active');
            document.body.style.overflow = '';
        }

        const successModal = document.getElementById('successModal');
        function openSuccessModal(title, msg) {
            document.getElementById('successTitle').textContent = title || 'Succès';
            document.getElementById('successMsg').textContent = msg || 'Opération effectuée.';
            successModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeSuccessModal() {
            successModal.classList.remove('active');
            document.body.style.overflow = '';
        }

        const depotModal = document.getElementById('depotModal');
        function openDepotModal(numtel, nom, solde) {
            document.getElementById('depNumtel').value = numtel || '';
            document.getElementById('depNom').textContent = nom ? ('• ' + nom) : '';
            document.getElementById('depSolde').textContent = 'Solde actuel: ' + (solde || '0') + ' Ar';
            document.getElementById('depMontant').value = '';
            depotModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeDepotModal() {
            depotModal.classList.remove('active');
            document.body.style.overflow = '';
        }

        const addClientModal = document.getElementById('addClientModal');
        const addClientForm = document.getElementById('addClientForm');
        function openAddClientModal() {
            addClientForm.reset();
            document.getElementById('ac_solde').value = '0';
            addClientModal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeAddClientModal() {
            addClientModal.classList.remove('active');
            document.body.style.overflow = '';
        }
        addClientForm.addEventListener('submit', function(e) {
            const tel = document.getElementById('ac_numtel').value;
            const age = parseInt(document.getElementById('ac_age').value, 10);
            const email = document.getElementById('ac_mail').value;
            if (!/^[0-9]{10}$/.test(tel)) {
                e.preventDefault(); alert('Le numéro doit contenir exactement 10 chiffres'); return;
            }
            if (isNaN(age) || age < 18 || age > 120) {
                e.preventDefault(); alert("L'âge doit être compris entre 18 et 120 ans"); return;
            }
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                e.preventDefault(); alert('Veuillez entrer une adresse email valide'); return;
            }
        });
        addClientModal.addEventListener('click', function(e) { if (e.target === addClientModal) closeAddClientModal(); });

        // Déconnexion (confirmation)
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

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') { closeDeleteModal(); closeSuccessModal(); closeDepotModal(); closeAddClientModal(); }
        });
        deleteModal.addEventListener('click', function(e) { if (e.target === deleteModal) closeDeleteModal(); });
        successModal.addEventListener('click', function(e) { if (e.target === successModal) closeSuccessModal(); });
        depotModal.addEventListener('click', function(e) { if (e.target === depotModal) closeDepotModal(); });

        <%
            Object msgObj = request.getAttribute("message");
            if (msgObj != null) {
                String rawMsg = String.valueOf(msgObj);
                String jsMsg = rawMsg.replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", "\\n");
                boolean ok = "success".equals(request.getAttribute("messageType"));
        %>
            openSuccessModal("<%= ok ? "Opération réussie" : "Opération échouée" %>", "<%= jsMsg %>");
        <%
            }
        %>
    </script>
</body>
</html>