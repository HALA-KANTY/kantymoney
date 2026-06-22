<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MVOLA - Gestion des Clients</title>
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/2.0.0/uicons-regular-rounded/css/uicons-regular-rounded.css">
    <link rel="stylesheet" href="https://cdn-uicons.flaticon.com/2.0.0/uicons-solid-rounded/css/uicons-solid-rounded.css">
    <style>
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
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', 'Roboto', sans-serif;
        }

        body {
            background: var(--gris-tres-clair);
            min-height: 100vh;
            padding: 24px;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        /* En-tête */
        .header {
            background: var(--blanc);
            padding: 24px 32px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .header h1 {
            color: var(--noir-doux);
            font-size: 28px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header h1 i {
            color: var(--marron);
            font-size: 32px;
        }

        .header-actions {
            display: flex;
            gap: 16px;
        }

        .btn {
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background: var(--marron);
            color: var(--blanc);
        }

        .btn-primary:hover {
            background: var(--marron-clair);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(196, 148, 80, 0.3);
        }

        .btn-secondary {
            background: var(--gris-clair);
            color: var(--noir-doux);
        }

        .btn-secondary:hover {
            background: var(--gris-moyen);
        }

        /* Section Formulaire */
        .form-section {
            background: var(--blanc);
            padding: 28px 32px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            margin-bottom: 24px;
        }

        .form-section h2 {
            color: var(--noir-doux);
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-section h2 i {
            color: var(--marron);
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group label {
            color: var(--noir-doux);
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .form-group label i {
            color: var(--marron);
            font-size: 16px;
        }

        .form-group input,
        .form-group select {
            padding: 12px 16px;
            border: 2px solid var(--gris-moyen);
            border-radius: 10px;
            font-size: 14px;
            color: var(--noir-doux);
            background: var(--blanc);
            transition: all 0.3s ease;
            outline: none;
        }

        .form-group input:focus,
        .form-group select:focus {
            border-color: var(--marron);
            box-shadow: 0 0 0 3px rgba(196, 148, 80, 0.1);
        }

        .form-group input::placeholder {
            color: var(--gris-fonce);
            opacity: 0.6;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 24px;
            grid-column: 1 / -1;
        }

        /* Table des clients */
        .table-section {
            background: var(--blanc);
            padding: 28px 32px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }

        .table-section h2 {
            color: var(--noir-doux);
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .table-section h2 i {
            color: var(--marron);
        }

        .table-wrapper {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: var(--marron-tres-clair);
            border-bottom: 2px solid var(--marron);
        }

        th {
            padding: 16px;
            text-align: left;
            color: var(--noir-doux);
            font-weight: 600;
            font-size: 14px;
            white-space: nowrap;
        }

        td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--gris-moyen);
            color: var(--noir-doux);
            font-size: 14px;
        }

        tbody tr {
            transition: background 0.2s ease;
        }

        tbody tr:hover {
            background: var(--gris-tres-clair);
        }

        .solde-positif {
            color: #10B981;
            font-weight: 600;
        }

        .solde-negatif {
            color: #EF4444;
            font-weight: 600;
        }

        .actions {
            display: flex;
            gap: 8px;
        }

        .btn-icon {
            padding: 8px;
            border-radius: 8px;
            background: transparent;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--gris-fonce);
        }

        .btn-icon.edit {
            color: var(--marron);
        }

        .btn-icon.edit:hover {
            background: var(--marron-tres-clair);
        }

        .btn-icon.delete {
            color: #EF4444;
        }

        .btn-icon.delete:hover {
            background: #FEE2E2;
        }

        .btn-icon i {
            font-size: 18px;
        }

        /* Messages */
        .message {
            padding: 14px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .success {
            background: #D1FAE5;
            color: #065F46;
            border-left: 4px solid #10B981;
        }

        .error {
            background: #FEE2E2;
            color: #991B1B;
            border-left: 4px solid #EF4444;
        }

        /* Responsive */
        @media (max-width: 768px) {
            body {
                padding: 16px;
            }

            .header {
                flex-direction: column;
                gap: 16px;
                text-align: center;
                padding: 20px;
            }

            .header h1 {
                font-size: 24px;
            }

            .form-section,
            .table-section {
                padding: 20px;
            }

            .form-actions {
                flex-direction: column;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }
        }

        @media (max-width: 480px) {
            .header h1 {
                font-size: 20px;
            }

            th, td {
                padding: 12px 8px;
                font-size: 13px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- En-tête -->
        <div class="header">
            <h1>
                <i class="fi fi-rr-users"></i>
                Gestion des Clients MVOLA
            </h1>
            <div class="header-actions">
                <a href="dashboard.jsp" class="btn btn-secondary">
                    <i class="fi fi-rr-arrow-left"></i>
                    Retour
                </a>
            </div>
        </div>

        <!-- Section Formulaire -->
        <div class="form-section">
            <h2>
                <i class="fi fi-rr-user-add"></i>
                <span id="formTitle">Ajouter un nouveau client</span>
            </h2>
            
            <form action="gestionClient" method="POST" id="clientForm">
                <input type="hidden" name="action" id="formAction" value="create">
                
                <div class="form-grid">
                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-mobile-notch"></i>
                            Numéro téléphone
                        </label>
                        <input type="tel" 
                               name="numtel" 
                               id="numtel" 
                               placeholder="0324432167" 
                               pattern="[0-9]{10}"
                               maxlength="10"
                               required>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-user"></i>
                            Nom complet
                        </label>
                        <input type="text" 
                               name="nom" 
                               id="nom" 
                               placeholder="Rakoto Bernard" 
                               required>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-venus-mars"></i>
                            Sexe
                        </label>
                        <select name="sexe" id="sexe" required>
                            <option value="">Sélectionner</option>
                            <option value="Masculin">Masculin</option>
                            <option value="Féminin">Féminin</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-calendar"></i>
                            Âge
                        </label>
                        <input type="number" 
                               name="age" 
                               id="age" 
                               placeholder="25" 
                               min="18" 
                               max="120" 
                               required>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-money"></i>
                            Solde initial
                        </label>
                        <input type="number" 
                               name="solde" 
                               id="solde" 
                               placeholder="0" 
                               min="0" 
                               value="0"
                               required>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-envelope"></i>
                            Email
                        </label>
                        <input type="email" 
                               name="mail" 
                               id="mail" 
                               placeholder="rakoto@example.com" 
                               required>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fi fi-rr-lock"></i>
                            Code secret (4 chiffres)
                        </label>
                        <input type="password" 
                               name="code_secret" 
                               id="code_secret" 
                               placeholder="••••" 
                               pattern="[0-9]{4}"
                               maxlength="4"
                               required>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fi fi-rr-plus"></i>
                            Ajouter le client
                        </button>
                        <button type="button" class="btn btn-secondary" id="cancelBtn" style="display: none;" onclick="resetForm()">
                            <i class="fi fi-rr-cross"></i>
                            Annuler
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Section Table des clients -->
        <div class="table-section">
            <h2>
                <i class="fi fi-rr-list"></i>
                Liste des clients
            </h2>
            
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Téléphone</th>
                            <th>Nom</th>
                            <th>Sexe</th>
                            <th>Âge</th>
                            <th>Solde (Ar)</th>
                            <th>Email</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<String[]> clients = (List<String[]>) request.getAttribute("clients");
                            if (clients != null && !clients.isEmpty()) {
                                for (String[] client : clients) {
                        %>
                            <tr>
                                <td><%= client[0] %></td>
                                <td><%= client[1] %></td>
                                <td><%= client[2] %></td>
                                <td><%= client[3] %> ans</td>
                                <td class="<%= Integer.parseInt(client[4]) >= 0 ? "solde-positif" : "solde-negatif" %>">
                                    <%= MoneyFormat.formatNullable(client[4]) %> Ar
                                </td>
                                <td><%= client[5] %></td>
                                <td>
                                    <div class="actions">
                                        <button class="btn-icon edit" 
                                                onclick="editClient('<%= client[0] %>', '<%= client[1] %>', '<%= client[2] %>', <%= client[3] %>, <%= client[4] %>, '<%= client[5] %>')"
                                                title="Modifier">
                                            <i class="fi fi-rr-pencil"></i>
                                        </button>
                                        <form action="gestionClient" method="POST" style="display: inline;" onsubmit="return confirm('Voulez-vous vraiment supprimer ce client ?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="numtel" value="<%= client[0] %>">
                                            <button type="submit" class="btn-icon delete" title="Supprimer">
                                                <i class="fi fi-rr-trash"></i>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 40px; color: var(--gris-fonce);">
                                    <i class="fi fi-rr-info" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>
                                    Aucun client enregistré
                                </td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Fonction pour éditer un client
        function editClient(numtel, nom, sexe, age, solde, mail) {
            // Changer le titre du formulaire
            document.getElementById('formTitle').innerHTML = '<i class="fi fi-rr-user-pen" style="margin-right: 8px;"></i>Modifier le client';
            
            // Changer l'action du formulaire
            document.getElementById('formAction').value = 'update';
            
            // Remplir les champs
            document.getElementById('numtel').value = numtel;
            document.getElementById('numtel').readOnly = true; // Le numéro ne peut pas être modifié
            
            document.getElementById('nom').value = nom;
            document.getElementById('sexe').value = sexe;
            document.getElementById('age').value = age;
            document.getElementById('solde').value = solde;
            document.getElementById('mail').value = mail;
            
            // Le code secret n'est pas récupéré pour des raisons de sécurité
            document.getElementById('code_secret').required = false;
            document.getElementById('code_secret').placeholder = "Laisser vide pour ne pas changer";
            
            // Changer le texte du bouton
            document.getElementById('submitBtn').innerHTML = '<i class="fi fi-rr-check"></i>Mettre à jour';
            
            // Afficher le bouton Annuler
            document.getElementById('cancelBtn').style.display = 'inline-flex';
            
            // Scroller vers le formulaire
            document.querySelector('.form-section').scrollIntoView({ behavior: 'smooth' });
        }
        
        // Fonction pour réinitialiser le formulaire
        function resetForm() {
            // Réinitialiser le titre
            document.getElementById('formTitle').innerHTML = '<i class="fi fi-rr-user-add" style="margin-right: 8px;"></i>Ajouter un nouveau client';
            
            // Réinitialiser l'action
            document.getElementById('formAction').value = 'create';
            
            // Réinitialiser les champs
            document.getElementById('clientForm').reset();
            document.getElementById('numtel').readOnly = false;
            document.getElementById('solde').value = '0';
            
            // Réactiver le code secret requis
            document.getElementById('code_secret').required = true;
            document.getElementById('code_secret').placeholder = '••••';
            
            // Changer le texte du bouton
            document.getElementById('submitBtn').innerHTML = '<i class="fi fi-rr-plus"></i>Ajouter le client';
            
            // Cacher le bouton Annuler
            document.getElementById('cancelBtn').style.display = 'none';
        }
        
        // Validation du formulaire avant soumission
        document.getElementById('clientForm').addEventListener('submit', function(e) {
            const action = document.getElementById('formAction').value;
            const numtel = document.getElementById('numtel').value;
            const code = document.getElementById('code_secret').value;
            
            if (action === 'create' && !code.match(/^[0-9]{4}$/)) {
                e.preventDefault();
                alert('Le code secret doit contenir exactement 4 chiffres');
                return false;
            }
            
            if (!numtel.match(/^[0-9]{10}$/)) {
                e.preventDefault();
                alert('Le numéro de téléphone doit contenir exactement 10 chiffres');
                return false;
            }
            
            return true;
        });
    </script>
</body>
</html>