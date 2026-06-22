<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Espace Opérateur</title>
    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            height: 100vh;
            width: 100vw;
            overflow: hidden;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #FAFAFA;
            color: #1A1A1A;
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
            --marron-fonce: #A67A3E;
            --marron-tres-clair: #FDF6ED;
            --erreur: #DC3545;
            --succes: #28A745;
            --info: #0D6EFD;
        }

        .login-fullscreen {
            display: flex;
            height: 100vh;
            width: 100vw;
        }

        /* ===== PARTIE GAUCHE - ILLUSTRATION ===== */
        .login-left {
            flex: 1.1;
            background: linear-gradient(145deg, var(--marron-tres-clair) 0%, #FFF5EB 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px;
            position: relative;
            overflow: hidden;
        }

        .login-left::before {
            content: '';
            position: absolute;
            bottom: -20%;
            right: -20%;
            width: 80%;
            height: 80%;
            background: radial-gradient(circle, rgba(196, 148, 80, 0.08) 0%, transparent 70%);
            border-radius: 50%;
        }

        .left-content {
            position: relative;
            z-index: 2;
            max-width: 520px;
            text-align: center;
        }

        .left-logo {
            margin-bottom: 40px;
        }

        .left-logo h1 {
            font-weight: 700;
            font-size: 3.5rem;
            color: var(--noir-doux);
            letter-spacing: -1px;
        }

        .left-logo .accent {
            color: var(--marron);
        }

        .left-logo .badge-operateur {
            display: inline-block;
            background: var(--marron);
            color: white;
            font-size: 0.75rem;
            font-weight: 600;
            padding: 6px 16px;
            border-radius: 30px;
            margin-top: 12px;
            letter-spacing: 2px;
        }

        .illustration-icon {
            font-size: 5.5rem;
            color: var(--marron);
            margin-bottom: 30px;
            opacity: 0.85;
        }

        .left-content h2 {
            font-size: 2.3rem;
            font-weight: 600;
            color: var(--noir-doux);
            margin-bottom: 20px;
            line-height: 1.3;
        }

        .left-content p {
            font-size: 1.1rem;
            color: var(--gris-fonce);
            margin-bottom: 50px;
            line-height: 1.6;
        }

        .features-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
            text-align: left;
        }

        .feature-item {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 1rem;
            color: var(--noir-doux);
        }

        .feature-item i {
            color: var(--marron);
            font-size: 1.3rem;
            width: 28px;
            text-align: center;
        }

        /* ===== PARTIE DROITE - FORMULAIRE ===== */
        .login-right {
            flex: 0.9;
            background: var(--blanc);
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px 80px;
            position: relative;
        }

        .form-container {
            max-width: 440px;
            width: 100%;
            margin: 0 auto;
        }

        .form-header {
            margin-bottom: 40px;
            text-align: center;
        }

        .form-header .icon-wrapper {
            width: 70px;
            height: 70px;
            background: var(--marron-tres-clair);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            border: 1px solid rgba(196, 148, 80, 0.15);
        }

        .form-header .icon-wrapper i {
            font-size: 32px;
            color: var(--marron);
        }

        .form-header h3 {
            font-size: 2rem;
            font-weight: 600;
            color: var(--noir-doux);
            margin-bottom: 8px;
        }

        .form-header p {
            color: var(--gris-fonce);
            font-size: 0.95rem;
        }

        .secure-badge {
            display: inline-block;
            background: var(--marron-tres-clair);
            color: var(--marron);
            font-size: 0.75rem;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 30px;
            margin-top: 12px;
        }

        /* Messages */
        .message {
            padding: 14px 18px;
            border-radius: 14px;
            margin-bottom: 28px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.9rem;
            font-weight: 500;
            animation: slideDown 0.4s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .error-message {
            background: #FEF2F2;
            color: var(--erreur);
            border-left: 4px solid var(--erreur);
        }

        .success-message {
            background: #F0FDF4;
            color: var(--succes);
            border-left: 4px solid var(--succes);
        }

        .info-message {
            background: #EFF6FF;
            color: var(--info);
            border-left: 4px solid var(--info);
        }

        /* Formulaire */
        .form-group {
            margin-bottom: 26px;
        }

        .form-group label {
            display: block;
            color: var(--noir-doux);
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-group label i {
            color: var(--marron);
            font-size: 1rem;
            width: 18px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper input {
            width: 100%;
            padding: 16px 18px;
            background: var(--gris-tres-clair);
            border: 2px solid var(--gris-moyen);
            border-radius: 16px;
            font-size: 1rem;
            color: var(--noir-doux);
            transition: all 0.25s ease;
            outline: none;
            font-family: 'Inter', sans-serif;
        }

        .input-wrapper input:focus {
            border-color: var(--marron);
            background: var(--blanc);
            box-shadow: 0 0 0 4px rgba(196, 148, 80, 0.1);
        }

        .input-wrapper input::placeholder {
            color: var(--gris-fonce);
            opacity: 0.5;
            font-weight: 400;
        }

        .password-toggle {
            position: absolute;
            right: 18px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--gris-fonce);
            cursor: pointer;
            padding: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: color 0.25s ease;
        }

        .password-toggle:hover {
            color: var(--marron);
        }

        .login-btn {
            width: 100%;
            padding: 18px;
            background: var(--marron);
            color: white;
            border: none;
            border-radius: 16px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 6px 16px rgba(196, 148, 80, 0.2);
            font-family: 'Inter', sans-serif;
            margin-top: 32px;
        }

        .login-btn:hover {
            background: var(--marron-fonce);
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(196, 148, 80, 0.3);
        }

        /* Bouton données de test */
        .test-data-btn {
            width: 100%;
            padding: 14px;
            background: var(--blanc);
            color: var(--marron);
            border: 2px dashed var(--marron-clair);
            border-radius: 16px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-family: 'Inter', sans-serif;
            margin-top: 16px;
            background: var(--marron-tres-clair);
        }

        .test-data-btn:hover {
            background: var(--marron);
            color: white;
            border-color: var(--marron);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(196, 148, 80, 0.2);
        }

        .test-data-btn i {
            font-size: 1.1rem;
        }

        .back-link {
            text-align: center;
            margin-top: 32px;
            padding-top: 28px;
            border-top: 1px solid var(--gris-clair);
        }

        .back-link a {
            color: var(--gris-fonce);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: color 0.25s;
        }

        .back-link a:hover {
            color: var(--marron);
        }

        .back-link span {
            color: var(--gris-moyen);
            margin: 0 8px;
        }

        .security-note {
            text-align: center;
            margin-top: 20px;
            color: var(--gris-fonce);
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        .back-home {
            position: absolute;
            bottom: 30px;
            left: 80px;
            color: var(--gris-fonce);
            text-decoration: none;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: color 0.25s;
        }

        .back-home:hover {
            color: var(--marron);
        }

        /* Animation des champs */
        .form-group {
            animation: fadeInUp 0.4s ease-out;
            animation-fill-mode: both;
        }

        .form-group:nth-child(1) { animation-delay: 0.1s; }
        .form-group:nth-child(2) { animation-delay: 0.2s; }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .login-left {
                padding: 40px;
            }
            .login-right {
                padding: 40px 50px;
            }
            .left-content h2 {
                font-size: 1.8rem;
            }
            .back-home {
                left: 50px;
            }
        }

        @media (max-width: 900px) {
            .login-fullscreen {
                flex-direction: column;
                overflow-y: auto;
            }
            .login-left {
                flex: none;
                padding: 50px 30px;
            }
            .login-right {
                flex: none;
                padding: 50px 30px;
            }
            .back-home {
                position: static;
                margin-top: 20px;
                justify-content: center;
            }
            .left-logo h1 {
                font-size: 2.5rem;
            }
        }

        @media (max-width: 500px) {
            .login-left {
                padding: 40px 24px;
            }
            .login-right {
                padding: 40px 24px;
            }
            .form-header h3 {
                font-size: 1.6rem;
            }
        }
    </style>
</head>
<body>
    <!-- MODAL NOTIFICATION -->
    <div id="notifModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(6px);z-index:3000;align-items:center;justify-content:center;">
        <div style="background:#fff;border-radius:18px;max-width:520px;width:92%;padding:22px;box-shadow:0 24px 60px rgba(20,20,35,.28);text-align:center;position:relative;">
            <button type="button" onclick="closeNotif()" style="position:absolute;right:12px;top:12px;border:1px solid #E9ECEF;background:#fff;border-radius:10px;padding:6px 9px;cursor:pointer;">
                <i class="fas fa-times"></i>
            </button>
            <div id="notifIcon" style="width:64px;height:64px;border-radius:50%;background:#FEF2F2;color:#DC3545;display:flex;align-items:center;justify-content:center;font-size:1.9rem;margin:0 auto 12px;">
                <i class="fas fa-circle-exclamation"></i>
            </div>
            <h3 id="notifTitle" style="margin:0 0 8px;font-size:1.15rem;">Erreur</h3>
            <p id="notifMsg" style="margin:0;color:#6C757D;line-height:1.5;"></p>
            <div style="display:flex;gap:10px;margin-top:16px;justify-content:center;">
                <button type="button" onclick="closeNotif()" style="padding:12px 16px;border-radius:12px;border:none;background:linear-gradient(135deg,#C49450,#D4A373);color:#fff;font-weight:700;cursor:pointer;min-width:140px;">
                    OK
                </button>
            </div>
        </div>
    </div>
    <div class="login-fullscreen">
        <!-- PARTIE GAUCHE - ILLUSTRATION -->
        <div class="login-left">
            <div class="left-content">
                <div class="left-logo">
                    <h1>Kanty<span class="accent">Money</span></h1>
                    <span class="badge-operateur">ESPACE OPÉRATEUR</span>
                </div>
                
                <div class="illustration-icon">
                    <i class="fas fa-building"></i>
                </div>
                
                <h2>Gérez votre plateforme<br>en toute simplicité</h2>
                
                <p>Accédez à votre tableau de bord opérateur pour superviser les transactions, suivre les recettes et gérer l'ensemble de l'activité KantyMoney.</p>
                
                <div class="features-list">
                    <div class="feature-item">
                        <i class="fas fa-chart-pie"></i>
                        <span>Tableau de bord en temps réel</span>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-coins"></i>
                        <span>Suivi des recettes opérateur</span>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-users"></i>
                        <span>Gestion des utilisateurs</span>
                    </div>
                    <div class="feature-item">
                        <i class="fas fa-file-pdf"></i>
                        <span>Rapports détaillés</span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- PARTIE DROITE - FORMULAIRE -->
        <div class="login-right">
            <div class="form-container">
                <div class="form-header">
                    <div class="icon-wrapper">
                        <i class="fas fa-lock"></i>
                    </div>
                    <h3>Connexion</h3>
                    <p>Espace réservé aux opérateurs</p>
                    <span class="secure-badge">
                        <i class="fas fa-shield-alt"></i>
                        Accès sécurisé
                    </span>
                </div>

                <%-- Affichage du message après déconnexion --%>
                <%
                    String logout = request.getParameter("logout");
                    if ("true".equals(logout)) {
                %>
                    <div class="message info-message">
                        <i class="fas fa-sign-out-alt"></i>
                        Vous avez été déconnecté avec succès
                    </div>
                <%
                    }
                %>

                <%-- Affichage du message session expirée --%>
                <%
                    String expired = request.getParameter("expired");
                    if ("true".equals(expired)) {
                %>
                    <div class="message info-message">
                        <i class="fas fa-clock"></i>
                        Votre session a expiré. Veuillez vous reconnecter.
                    </div>
                <%
                    }
                %>

                <%-- Affichage des messages d'erreur --%>
                <%
                    String error = (String) request.getAttribute("error");
                    if (error != null) {
                %>
                    <div class="message error-message">
                        <i class="fas fa-exclamation-circle"></i>
                        <%= error %>
                    </div>
                <%
                    }
                %>

                <%-- Formulaire de connexion --%>
               <form action="<%= request.getContextPath() %>/auth" method="POST" id="loginForm">
                    <input type="hidden" name="action" value="login">
                    
                    <!-- Email -->
                    <div class="form-group">
                        <label for="mail">
                            <i class="fas fa-envelope"></i>
                            Adresse email
                        </label>
                        <div class="input-wrapper">
                            <input type="email" 
                                   id="mail" 
                                   name="mail" 
                                   placeholder="admin@kantymoney.mg"
                                   value="<%= request.getAttribute("mail") != null ? request.getAttribute("mail") : "" %>"
                                   required>
                        </div>
                    </div>

                    <!-- Mot de passe -->
                    <div class="form-group">
                        <label for="mot_de_passe">
                            <i class="fas fa-lock"></i>
                            Mot de passe
                        </label>
                        <div class="input-wrapper">
                            <input type="password" 
                                   id="mot_de_passe" 
                                   name="mot_de_passe" 
                                   placeholder="••••••••"
                                   required>
                            <button type="button" class="password-toggle" id="togglePassword">
                                <i class="far fa-eye" id="toggleIcon"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Bouton de connexion -->
                    <button type="submit" class="login-btn">
                        <i class="fas fa-sign-in-alt"></i>
                        Accéder à l'espace opérateur
                    </button>

                    <!-- Bouton données de test -->
                    <button type="button" class="test-data-btn" id="testDataBtn">
                        <i class="fas fa-flask"></i>
                        Utiliser les données de test
                    </button>
                </form>

                <div class="back-link">
                   
                   <a href="../index.jsp">
                        <i class="fas fa-user"></i>
                       Retour à l'espace client
                    </a>
                </div>

                <div class="security-note">
                    <i class="fas fa-shield-alt"></i>
                    Connexion sécurisée - Espace réservé aux opérateurs
                </div>
            </div>
            
            <a href="../index_op.jsp" class="back-home">
                <i class="fas fa-arrow-left"></i>
                Retour à l'accueil Opérateur
            </a>
        </div>
    </div>

    <script>
        // Toggle password visibility
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('mot_de_passe');
        const toggleIcon = document.getElementById('toggleIcon');

        togglePassword.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            
            if (type === 'text') {
                toggleIcon.className = 'far fa-eye-slash';
            } else {
                toggleIcon.className = 'far fa-eye';
            }
        });

        // Bouton données de test - Remplit et soumet automatiquement
        document.getElementById('testDataBtn').addEventListener('click', function() {
            // Remplir les champs avec les données de test
            document.getElementById('mail').value = 'kantymoney@admin.com';
            document.getElementById('mot_de_passe').value = 'kanty2026';
            
            // Ajouter une petite animation visuelle
            const btn = this;
            const originalHTML = btn.innerHTML;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Connexion en cours...';
            btn.style.pointerEvents = 'none';
            
            // Soumettre le formulaire après un court délai
            setTimeout(function() {
                document.getElementById('loginForm').submit();
            }, 600);
        });

        // Validation du formulaire
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            const mail = document.getElementById('mail').value.trim();
            const mdp = document.getElementById('mot_de_passe').value.trim();
            
            if (!mail || !mdp) {
                e.preventDefault();
                showNotif('error', 'Validation', 'Veuillez remplir tous les champs');
                return false;
            }
            
            // Validation basique de l'email
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(mail)) {
                e.preventDefault();
                showNotif('error', 'Validation', 'Veuillez entrer une adresse email valide');
                return false;
            }
            
            return true;
        });
        
        // Focus automatique sur le premier champ vide
        window.onload = function() {
            const mail = document.getElementById('mail').value;
            if (!mail) {
                document.getElementById('mail').focus();
            } else {
                document.getElementById('mot_de_passe').focus();
            }
        };
        
        // Double-clic sur le logo pour pré-remplir (démo)
        document.querySelector('.left-logo').addEventListener('dblclick', function() {
            document.getElementById('mail').value = 'katymoney@admin.com';
            document.getElementById('mot_de_passe').value = 'kanty2026';
        });

        // Notification helpers
        function showNotif(type, title, msg) {
            const modal = document.getElementById('notifModal');
            const iconWrap = document.getElementById('notifIcon');
            const titleEl = document.getElementById('notifTitle');
            const msgEl = document.getElementById('notifMsg');
            const ok = type === 'success';
            iconWrap.style.background = ok ? '#F0FDF4' : '#FEF2F2';
            iconWrap.style.color = ok ? '#28A745' : '#DC3545';
            iconWrap.innerHTML = ok ? '<i class="fas fa-circle-check"></i>' : '<i class="fas fa-circle-exclamation"></i>';
            titleEl.textContent = title || (ok ? 'Succès' : 'Erreur');
            msgEl.textContent = msg || '';
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        function closeNotif() {
            const modal = document.getElementById('notifModal');
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }
        document.getElementById('notifModal').addEventListener('click', function(e) { if (e.target === this) closeNotif(); });
        document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeNotif(); });
    </script>
</body>
</html>