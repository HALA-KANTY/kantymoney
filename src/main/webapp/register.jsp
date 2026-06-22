<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Inscription</title>
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

        body::before {
            content: '';
            position: absolute;
            top: -180px; right: -120px;
            width: 500px; height: 500px;
            background: radial-gradient(circle, rgba(196,148,80,0.06) 0%, transparent 70%);
            border-radius: 50%;
        }
        body::after {
            content: '';
            position: absolute;
            bottom: -200px; left: -100px;
            width: 600px; height: 600px;
            background: radial-gradient(circle, rgba(26,26,46,0.03) 0%, transparent 70%);
            border-radius: 50%;
        }

        /* ===== CARD ===== */
        .register-card {
            display: flex;
            width: 1000px;
            max-width: 96vw;
            height: 620px;
            max-height: 90vh;
            background: white;
            border-radius: 28px;
            box-shadow: 0 30px 80px rgba(26,26,46,0.12), 0 0 0 1px rgba(0,0,0,0.03);
            overflow: hidden;
            position: relative;
            z-index: 1;
        }

        /* ===== GAUCHE ===== */
        .panel-left {
            width: 400px;
            background: linear-gradient(170deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: white;
            padding: 40px 34px;
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
            top: -30%; right: -40%;
            width: 300px; height: 300px;
            background: radial-gradient(circle, rgba(196,148,80,0.15) 0%, transparent 70%);
            border-radius: 50%;
        }
        .panel-left::after {
            content: '';
            position: absolute;
            bottom: -20%; left: -30%;
            width: 250px; height: 250px;
            background: radial-gradient(circle, rgba(212,163,115,0.08) 0%, transparent 70%);
            border-radius: 50%;
        }

        .panel-left .brand { position: relative; z-index: 1; margin-bottom: 32px; }
        .panel-left .brand h1 {
            font-size: 1.8rem; font-weight: 800; letter-spacing: -0.5px;
            background: linear-gradient(135deg, #C49450, #E8C87A);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
        }
        .panel-left .brand span {
            display: block; font-size: 0.66rem; color: #6C7A8D;
            letter-spacing: 2.5px; text-transform: uppercase; margin-top: 4px;
        }

        .panel-left .illustration { position: relative; z-index: 1; text-align: center; margin-bottom: 28px; }
        .panel-left .illustration .circle-big {
            width: 80px; height: 80px;
            background: rgba(196,148,80,0.12);
            border: 2px solid rgba(196,148,80,0.25);
            border-radius: 24px;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto; font-size: 2.2rem; color: #C49450;
        }

        .panel-left .info-list { position: relative; z-index: 1; display: flex; flex-direction: column; gap: 12px; }
        .panel-left .info-item { display: flex; align-items: center; gap: 10px; font-size: 0.8rem; color: #B0B9C6; }
        .panel-left .info-item i { color: #C49450; font-size: 0.9rem; width: 16px; text-align: center; }

        /* ===== DROITE ===== */
        .panel-right {
            flex: 1;
            padding: 30px 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        /* Bouton retour */
        .back-link {
            position: absolute;
            top: 16px; left: 20px;
            display: inline-flex;
            align-items: center; gap: 7px;
            color: #6C757D; text-decoration: none;
            font-size: 0.78rem; font-weight: 500;
            padding: 7px 14px;
            border-radius: 8px;
            background: #F8F9FA;
            border: 1px solid #E9ECEF;
            transition: all 0.25s;
            z-index: 2;
        }
        .back-link:hover { color: #C49450; border-color: #C49450; background: #FDF6ED; }

        .form-title { margin-bottom: 18px; }
        .form-title h3 { font-size: 1.5rem; font-weight: 700; color: #1a1a2e; letter-spacing: -0.5px; margin-bottom: 2px; }
        .form-title p { font-size: 0.82rem; color: #6C757D; }

        /* Messages */
        .msg {
            padding: 9px 12px; border-radius: 8px; margin-bottom: 10px;
            font-size: 0.76rem; font-weight: 500;
            display: flex; align-items: center; gap: 8px;
            animation: fadeIn 0.35s ease;
        }
        @keyframes fadeIn { from{opacity:0;transform:translateY(-5px);} to{opacity:1;transform:translateY(0);} }
        .msg.err { background: #FEF2F2; color: #991B1B; border: 1px solid #FECACA; }
        .msg.ok { background: #ECFDF3; color: #166534; border: 1px solid #BBF7D0; }

        /* Champs compacts */
        .field { margin-bottom: 10px; }
        .field label {
            display: block; font-size: 0.74rem; font-weight: 600;
            color: #1a1a2e; margin-bottom: 4px;
            display: flex; align-items: center; gap: 5px;
        }
        .field label i { color: #C49450; font-size: 0.75rem; }

        .input-wrap { position: relative; }
        .input-wrap input,
        .input-wrap select {
            width: 100%; padding: 9px 12px;
            background: #F8F9FA; border: 2px solid #E9ECEF;
            border-radius: 10px; font-size: 0.84rem;
            font-family: 'Inter', sans-serif; color: #212529;
            outline: none; transition: all 0.25s;
        }
        .input-wrap input:focus,
        .input-wrap select:focus {
            border-color: #C49450; background: white;
            box-shadow: 0 0 0 3px rgba(196,148,80,0.06);
        }
        .input-wrap input::placeholder { color: #ADB5BD; }

        .input-wrap select {
            appearance: none; cursor: pointer;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236C757D' stroke-width='2'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: right 12px center;
        }

        .row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }

        .hint { font-size: 0.7rem; color: #6C757D; margin-top: 3px; display: flex; align-items: center; gap: 4px; }

        /* Checkbox */
        .chk-row {
            display: flex; align-items: flex-start; gap: 8px;
            margin: 14px 0 16px;
        }
        .chk-row input { width: 15px; height: 15px; accent-color: #C49450; margin-top: 2px; cursor: pointer; }
        .chk-row label { font-size: 0.76rem; color: #555; line-height: 1.4; cursor: pointer; }
        .chk-row label a { color: #C49450; text-decoration: none; font-weight: 600; }
        .chk-row label a:hover { text-decoration: underline; }

        /* Bouton */
        .btn-register {
            width: 100%; padding: 12px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white; border: none; border-radius: 10px;
            font-size: 0.88rem; font-weight: 600; cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            font-family: 'Inter', sans-serif; transition: all 0.3s;
            box-shadow: 0 4px 16px rgba(196,148,80,0.25);
        }
        .btn-register:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(196,148,80,0.35); }

        /* Redirection */
        .login-redirect {
            text-align: center; margin-top: 16px; padding-top: 14px;
            border-top: 1px solid #E9ECEF; font-size: 0.78rem; color: #6C757D;
        }
        .login-redirect a {
            color: #C49450; text-decoration: none; font-weight: 600;
            display: inline-flex; align-items: center; gap: 4px; transition: all 0.2s;
        }
        .login-redirect a:hover { gap: 7px; color: #A67A3E; }

        .secure-note {
            text-align: center; margin-top: 8px;
            font-size: 0.7rem; color: #ADB5BD;
            display: flex; align-items: center; justify-content: center; gap: 4px;
        }

        /* Responsive */
        @media (max-width: 850px) {
            .register-card { flex-direction: column; height: auto; max-height: none; }
            .panel-left { width: 100%; padding: 28px 20px; text-align: center; }
            .panel-left .info-list { align-items: center; }
            .panel-left .brand { margin-bottom: 20px; }
            .panel-left .illustration { margin-bottom: 16px; }
            .panel-right { padding: 28px 20px; overflow-y: visible; }
        }
        @media (max-width: 500px) {
            .row-2 { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <div class="register-card">

        <!-- ===== PANNEAU GAUCHE ===== -->
        <div class="panel-left">
          <a href="index.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Accueil
            </a>
            <div class="brand">
                <h1>KantyMoney</h1>
                <span>Mobile Money</span>
            </div>

            <div class="illustration">
                <div class="circle-big">
                    <i class="fas fa-user-plus"></i>
                </div>
            </div>

            <div class="info-list">
                <div class="info-item">
                    <i class="fas fa-gift"></i> Compte 100% gratuit
                </div>
                <div class="info-item">
                    <i class="fas fa-bolt"></i> Inscription en 2 minutes
                </div>
                <div class="info-item">
                    <i class="fas fa-shield-alt"></i> Données sécurisées
                </div>
                <div class="info-item">
                    <i class="fas fa-headset"></i> Support client 7j/7
                </div>
            </div>
        </div>

        <!-- ===== PANNEAU DROIT ===== -->
        <div class="panel-right">

          

            <div class="form-title">
                <h3>Inscription</h3>
                <p>Créez votre compte KantyMoney</p>
            </div>

            <%-- ERREUR --%>
            <% String error = (String) request.getAttribute("error");
               if (error != null) { %>
                <div class="msg err"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>

            <%-- SUCCÈS --%>
            <% String success = (String) request.getAttribute("success");
               if (success != null) { %>
                <div class="msg ok"><i class="fas fa-check-circle"></i> <%= success %></div>
            <% } %>

            <form action="register" method="POST" id="frmRegister">

                <div class="field">
                    <label><i class="fas fa-mobile-alt"></i> Numéro de téléphone</label>
                    <div class="input-wrap">
                        <input type="tel" id="numtel" name="numtel" placeholder="0324432167" pattern="[0-9]{10}" maxlength="10" value="<%= request.getParameter("numtel") != null ? request.getParameter("numtel") : "" %>" required>
                    </div>
                </div>

                <div class="field">
                    <label><i class="fas fa-user"></i> Nom complet</label>
                    <div class="input-wrap">
                        <input type="text" id="nom" name="nom" placeholder="Rakoto Bernard" value="<%= request.getParameter("nom") != null ? request.getParameter("nom") : "" %>" required>
                    </div>
                </div>

                <div class="row-2">
                    <div class="field">
                        <label><i class="fas fa-venus-mars"></i> Sexe</label>
                        <div class="input-wrap">
                            <select id="sexe" name="sexe" required>
                                <option value="">Sélectionner</option>
                                <option value="Masculin" <%= "Masculin".equals(request.getParameter("sexe")) ? "selected" : "" %>>Masculin</option>
                                <option value="Féminin" <%= "Féminin".equals(request.getParameter("sexe")) ? "selected" : "" %>>Féminin</option>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label><i class="fas fa-calendar-alt"></i> Âge</label>
                        <div class="input-wrap">
                            <input type="number" id="age" name="age" placeholder="25" min="18" max="120" value="<%= request.getParameter("age") != null ? request.getParameter("age") : "" %>" required>
                        </div>
                    </div>
                </div>

                <div class="field">
                    <label><i class="fas fa-envelope"></i> Adresse email</label>
                    <div class="input-wrap">
                        <input type="email" id="mail" name="mail" placeholder="rakoto@example.com" value="<%= request.getParameter("mail") != null ? request.getParameter("mail") : "" %>" required>
                    </div>
                </div>

                <div class="field">
                    <label><i class="fas fa-lock"></i> Code secret (4 chiffres)</label>
                    <div class="input-wrap">
                        <input type="password" id="code" name="code_secret" placeholder="••••" pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required>
                    </div>
                    <div class="hint"><i class="fas fa-info-circle"></i> Choisissez un code à 4 chiffres facile à retenir</div>
                </div>

                <div class="chk-row">
                    <input type="checkbox" id="terms" required>
                    <label for="terms">J'accepte les <a href="#">conditions d'utilisation</a> et la <a href="#">politique de confidentialité</a></label>
                </div>

                <button type="submit" class="btn-register">
                    <i class="fas fa-user-plus"></i> Créer mon compte
                </button>
            </form>

            <div class="login-redirect">
                Vous avez déjà un compte ?
                <a href="login.jsp">Se connecter <i class="fas fa-arrow-right"></i></a>
            </div>

            <div class="secure-note">
                <i class="fas fa-lock"></i> Vos données sont protégées
            </div>
        </div>
    </div>

    <script>
        document.getElementById('frmRegister').addEventListener('submit', function(e){
            const tel = document.getElementById('numtel').value;
            const age = document.getElementById('age').value;
            const pin = document.getElementById('code').value;
            const email = document.getElementById('mail').value;

            if(!/^[0-9]{10}$/.test(tel)){
                e.preventDefault(); alert('Le numéro doit contenir exactement 10 chiffres'); return;
            }
            if(age < 18 || age > 120){
                e.preventDefault(); alert("L'âge doit être compris entre 18 et 120 ans"); return;
            }
            if(!/^[0-9]{4}$/.test(pin)){
                e.preventDefault(); alert('Le code secret doit contenir exactement 4 chiffres'); return;
            }
            if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)){
                e.preventDefault(); alert('Veuillez entrer une adresse email valide'); return;
            }
        });

        document.getElementById('code').addEventListener('keypress', function(e){
            if(e.key < '0' || e.key > '9') e.preventDefault();
        });
        document.getElementById('numtel').addEventListener('keypress', function(e){
            if(e.key < '0' || e.key > '9') e.preventDefault();
        });
    </script>
</body>
</html>