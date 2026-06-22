<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Connexion</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(160deg, #f5f7fa 0%, #faf5f0 40%, #fdf6ed 100%);
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        /* Cercles décoratifs */
        body::before {
            content: '';
            position: absolute;
            top: -180px;
            right: -120px;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(196,148,80,0.06) 0%, transparent 70%);
            border-radius: 50%;
        }
        body::after {
            content: '';
            position: absolute;
            bottom: -200px;
            left: -100px;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(26,26,46,0.03) 0%, transparent 70%);
            border-radius: 50%;
        }

        /* ===== CARD PRINCIPALE ===== */
        .login-card {
            display: flex;
            width: 960px;
            max-width: 95vw;
            height: 600px;
            max-height: 90vh;
            background: white;
            border-radius: 28px;
            box-shadow: 0 30px 80px rgba(26,26,46,0.12), 0 0 0 1px rgba(0,0,0,0.03);
            overflow: hidden;
            position: relative;
            z-index: 1;
        }

        /* ===== PANNEAU GAUCHE ===== */
        .panel-left {
            width: 420px;
            background: linear-gradient(170deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: white;
            padding: 48px 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
            flex-shrink: 0;
        }

        .panel-left::before {
            content: '';
            position: absolute;
            top: -30%;
            right: -40%;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(196,148,80,0.15) 0%, transparent 70%);
            border-radius: 50%;
        }
        .panel-left::after {
            content: '';
            position: absolute;
            bottom: -20%;
            left: -30%;
            width: 250px;
            height: 250px;
            background: radial-gradient(circle, rgba(212,163,115,0.08) 0%, transparent 70%);
            border-radius: 50%;
        }

        .panel-left .brand {
            position: relative;
            z-index: 1;
            margin-bottom: 48px;
        }
        .panel-left .brand h1 {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #C49450, #E8C87A);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .panel-left .brand span {
            display: block;
            font-size: 0.7rem;
            color: #6C7A8D;
            letter-spacing: 2.5px;
            text-transform: uppercase;
            margin-top: 4px;
        }

        .panel-left .illustration {
            position: relative;
            z-index: 1;
            text-align: center;
            margin-bottom: 40px;
        }
        .panel-left .illustration .circle-big {
            width: 100px;
            height: 100px;
            background: rgba(196,148,80,0.12);
            border: 2px solid rgba(196,148,80,0.25);
            border-radius: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
            font-size: 2.8rem;
            color: #C49450;
        }

        .panel-left .info-list {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .panel-left .info-item {
            display: flex;
            align-items: center;
            gap: 14px;
            font-size: 0.85rem;
            color: #B0B9C6;
        }
        .panel-left .info-item i {
            color: #C49450;
            font-size: 1rem;
            width: 20px;
            text-align: center;
        }

        /* ===== PANNEAU DROIT ===== */
        .panel-right {
            flex: 1;
            padding: 48px 52px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .panel-right .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #6C757D;
            text-decoration: none;
            font-size: 0.82rem;
            font-weight: 500;
            margin-bottom: 32px;
            transition: all 0.25s;
            width: fit-content;
        }
        .panel-right .back-link:hover { color: #C49450; gap: 12px; }

        .panel-right .form-title {
            margin-bottom: 32px;
        }
        .panel-right .form-title h3 {
            font-size: 1.8rem;
            font-weight: 700;
            color: #1a1a2e;
            letter-spacing: -0.5px;
            margin-bottom: 6px;
        }
        .panel-right .form-title p {
            font-size: 0.88rem;
            color: #6C757D;
        }

        /* Messages */
        .msg {
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-size: 0.82rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: fadeIn 0.35s ease;
        }
        @keyframes fadeIn { from{opacity:0;transform:translateY(-6px);} to{opacity:1;transform:translateY(0);} }
        .msg.err { background: #FEF2F2; color: #991B1B; border: 1px solid #FECACA; }
        .msg.ok { background: #ECFDF3; color: #166534; border: 1px solid #BBF7D0; }
        .msg.info { background: #EFF6FF; color: #1E40AF; border: 1px solid #BFDBFE; }

        /* Champs */
        .field {
            margin-bottom: 20px;
        }
        .field label {
            display: block;
            font-size: 0.8rem;
            font-weight: 600;
            color: #1a1a2e;
            margin-bottom: 7px;
            display: flex;
            align-items: center;
            gap: 7px;
        }
        .field label i { color: #C49450; font-size: 0.85rem; }

        .input-wrap {
            position: relative;
        }
        .input-wrap input {
            width: 100%;
            padding: 14px 16px;
            background: #F8F9FA;
            border: 2px solid #E9ECEF;
            border-radius: 14px;
            font-size: 0.92rem;
            font-family: 'Inter', sans-serif;
            color: #212529;
            outline: none;
            transition: all 0.25s;
        }
        .input-wrap input:focus {
            border-color: #C49450;
            background: white;
            box-shadow: 0 0 0 4px rgba(196,148,80,0.06);
        }
        .input-wrap input::placeholder { color: #ADB5BD; }

        .input-wrap .eye-btn {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #6C757D;
            cursor: pointer;
            font-size: 0.9rem;
            padding: 4px;
        }
        .input-wrap .eye-btn:hover { color: #C49450; }

        /* Checkbox */
        .row-options {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 24px 0 28px;
        }
        .remember {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.82rem;
            color: #6C757D;
            cursor: pointer;
        }
        .remember input { width: 17px; height: 17px; accent-color: #C49450; cursor: pointer; }
        .forgot {
            color: #C49450;
            text-decoration: none;
            font-size: 0.82rem;
            font-weight: 500;
            transition: all 0.2s;
        }
        .forgot:hover { color: #A67A3E; }

        /* Bouton */
        .btn-login {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            border: none;
            border-radius: 14px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s;
            box-shadow: 0 6px 20px rgba(196,148,80,0.25);
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(196,148,80,0.35);
        }

        /* Bouton données de test */
        .test-data-btn {
            width: 100%;
            padding: 12px;
            background: #FDF6ED;
            color: #C49450;
            border: 2px dashed #D4A373;
            border-radius: 14px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-family: 'Inter', sans-serif;
            transition: all 0.3s;
            margin-top: 12px;
        }
        .test-data-btn:hover {
            background: #C49450;
            color: white;
            border-color: #C49450;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(196,148,80,0.2);
        }

        /* Register */
        .register-redirect {
            text-align: center;
            margin-top: 28px;
            padding-top: 24px;
            border-top: 1px solid #E9ECEF;
            font-size: 0.85rem;
            color: #6C757D;
        }
        .register-redirect a {
            color: #C49450;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: all 0.2s;
        }
        .register-redirect a:hover { gap: 8px; color: #A67A3E; }

        /* Responsive */
        @media (max-width: 800px) {
            .login-card { flex-direction: column; height: auto; max-height: none; }
            .panel-left { width: 100%; padding: 36px 28px; text-align: center; }
            .panel-left .info-list { align-items: center; }
            .panel-left .brand { margin-bottom: 28px; }
            .panel-left .illustration { margin-bottom: 24px; }
            .panel-right { padding: 36px 28px; }
        }
    </style>
</head>
<body>

    <div class="login-card">

        <!-- ===== PANNEAU GAUCHE ===== -->
        <div class="panel-left">
            <div class="brand">
                <h1>KantyMoney</h1>
                <span>Mobile Money</span>
            </div>

            <div class="illustration">
                <div class="circle-big">
                    <i class="fas fa-mobile-alt"></i>
                </div>
            </div>

            <div class="info-list">
                <div class="info-item">
                    <i class="fas fa-bolt"></i>
                    Transferts instantanés
                </div>
                <div class="info-item">
                    <i class="fas fa-shield-alt"></i>
                    Sécurité bancaire
                </div>
                <div class="info-item">
                    <i class="fas fa-store"></i>
                    +200 points de retrait
                </div>
                <div class="info-item">
                    <i class="fas fa-headset"></i>
                    Support client 7j/7
                </div>
            </div>
        </div>

        <!-- ===== PANNEAU DROIT ===== -->
        <div class="panel-right">

            <a href="index.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Retour à l'accueil
            </a>

            <div class="form-title">
                <h3>Connexion</h3>
                <p>Accédez à votre espace KantyMoney</p>
            </div>

            <%-- SUCCÈS --%>
            <% String success = (String) session.getAttribute("success");
               if (success != null) { %>
                <div class="msg ok"><i class="fas fa-check-circle"></i> <%= success %></div>
            <% session.removeAttribute("success"); } %>

            <%-- DÉCONNEXION --%>
            <% if ("true".equals(request.getParameter("logout"))) { %>
                <div class="msg info"><i class="fas fa-sign-out-alt"></i> Vous avez été déconnecté avec succès</div>
            <% } %>

            <%-- COMPTE SUPPRIMÉ --%>
            <% if ("1".equals(request.getParameter("compte_supprime"))) { %>
                <div class="msg ok"><i class="fas fa-check-circle"></i> Votre compte a été supprimé. Merci d'avoir utilisé KantyMoney.</div>
            <% } %>

            <%-- ERREUR --%>
            <% String error = (String) request.getAttribute("error");
               if (error != null) { %>
                <div class="msg err"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>

            <form action="login" method="POST" id="frmLogin">
                <div class="field">
                    <label><i class="fas fa-mobile-alt"></i> Numéro de téléphone</label>
                    <div class="input-wrap">
                        <input type="tel" id="numtel" name="numtel" placeholder="0324432167" pattern="[0-9]{10}" maxlength="10" value="<%= request.getParameter("numtel") != null ? request.getParameter("numtel") : "" %>" required>
                    </div>
                </div>

                <div class="field">
                    <label><i class="fas fa-lock"></i> Code secret</label>
                    <div class="input-wrap">
                        <input type="password" id="code" name="code_secret" placeholder="••••" pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required>
                        <button type="button" class="eye-btn" id="btnEye"><i class="far fa-eye" id="eyeIcon"></i></button>
                    </div>
                </div>

                <div class="row-options">
                    <label class="remember">
                        <input type="checkbox" name="remember"> Se souvenir de moi
                    </label>
                    <a href="#" class="forgot" onclick="showForgot()">Code oublié ?</a>
                </div>

                <button type="submit" class="btn-login">
                    <i class="fas fa-sign-in-alt"></i> Se connecter
                </button>

                <!-- Bouton données de test -->
                <button type="button" class="test-data-btn" id="testDataBtn">
                    <i class="fas fa-flask"></i>
                    Utiliser les données de test
                </button>
            </form>

            <div class="register-redirect">
                Pas encore de compte ?
                <a href="register.jsp">Créer un compte <i class="fas fa-arrow-right"></i></a>
            </div>
        </div>
    </div>

    <script>
        const btnEye = document.getElementById('btnEye');
        const inputCode = document.getElementById('code');
        const eyeIcon = document.getElementById('eyeIcon');

        btnEye.addEventListener('click', function(){
            if(inputCode.type === 'password'){
                inputCode.type = 'text';
                eyeIcon.className = 'far fa-eye-slash';
            } else {
                inputCode.type = 'password';
                eyeIcon.className = 'far fa-eye';
            }
        });

        // Bouton données de test - Remplit et soumet automatiquement
        document.getElementById('testDataBtn').addEventListener('click', function() {
            // Remplir les champs avec les données de test
            document.getElementById('numtel').value = '0323203232';
            document.getElementById('code').value = '0000';
            
            // Animation visuelle
            const btn = this;
            const originalHTML = btn.innerHTML;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Connexion en cours...';
            btn.style.pointerEvents = 'none';
            
            // Soumettre le formulaire après un court délai
            setTimeout(function() {
                document.getElementById('frmLogin').submit();
            }, 600);
        });

        document.getElementById('frmLogin').addEventListener('submit', function(e){
            const tel = document.getElementById('numtel').value;
            const pin = document.getElementById('code').value;
            if(!/^[0-9]{10}$/.test(tel)){
                e.preventDefault();
                alert('Le numéro doit contenir exactement 10 chiffres');
                return;
            }
            if(!/^[0-9]{4}$/.test(pin)){
                e.preventDefault();
                alert('Le code secret doit contenir exactement 4 chiffres');
                return;
            }
        });

        document.getElementById('code').addEventListener('keypress', function(e){
            if(e.key < '0' || e.key > '9') e.preventDefault();
        });
        document.getElementById('numtel').addEventListener('keypress', function(e){
            if(e.key < '0' || e.key > '9') e.preventDefault();
        });

        function showForgot(){
            alert('Pour réinitialiser votre code secret, contactez le service client au 032 44 321 67');
        }
    </script>
</body>
</html>