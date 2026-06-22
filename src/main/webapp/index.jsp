<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Mobile Money à Madagascar</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(160deg, #f5f7fa 0%, #faf5f0 40%, #fdf6ed 100%);
            color: #212529;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Cercles décoratifs */
        body::before {
            content: '';
            position: fixed;
            top: -250px;
            right: -180px;
            width: 650px;
            height: 650px;
            background: radial-gradient(circle, rgba(196,148,80,0.05) 0%, transparent 70%);
            border-radius: 50%;
            pointer-events: none;
            z-index: 0;
        }
        body::after {
            content: '';
            position: fixed;
            bottom: -280px;
            left: -200px;
            width: 700px;
            height: 700px;
            background: radial-gradient(circle, rgba(26,26,46,0.025) 0%, transparent 70%);
            border-radius: 50%;
            pointer-events: none;
            z-index: 0;
        }

        /* ===== NAVBAR ===== */
        .navbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 48px;
            background: rgba(255,255,255,0.8);
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(0,0,0,0.04);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo h2 {
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: -0.3px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-links { display: flex; gap: 4px; }
        .nav-links a {
            color: #555;
            text-decoration: none;
            font-size: 0.82rem;
            font-weight: 500;
            padding: 9px 15px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 7px;
            transition: all 0.25s;
        }
        .nav-links a i { color: #999; font-size: 0.85rem; transition: all 0.25s; }
        .nav-links a:hover { color: #C49450; background: #FDF6ED; }
        .nav-links a:hover i { color: #C49450; }

        .nav-auth { display: flex; align-items: center; gap: 10px; }

        .btn-login {
            padding: 9px 18px;
            background: transparent;
            color: #1a1a2e;
            text-decoration: none;
            border-radius: 10px;
            font-size: 0.82rem;
            font-weight: 500;
            border: 2px solid #E9ECEF;
            display: flex;
            align-items: center;
            gap: 7px;
            transition: all 0.25s;
        }
        .btn-login:hover { border-color: #C49450; color: #C49450; }

        .btn-register {
            padding: 9px 20px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-size: 0.82rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 7px;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(196,148,80,0.25);
        }
        .btn-register:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(196,148,80,0.35); }

        .burger { display: none; font-size: 1.3rem; cursor: pointer; color: #333; }

        /* ===== HERO ===== */
        .hero {
            position: relative;
            z-index: 1;
            text-align: center;
            padding: 80px 24px 80px;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 20px;
            background: white;
            border: 1px solid rgba(196,148,80,0.2);
            border-radius: 30px;
            font-size: 0.8rem;
            color: #C49450;
            font-weight: 500;
            margin-bottom: 32px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.03);
        }
        .hero-badge .dot { color: #28A745; font-size: 0.45rem; }

        .hero h1 {
            font-size: 3.8rem;
            font-weight: 800;
            color: #1a1a2e;
            line-height: 1.12;
            margin-bottom: 20px;
            letter-spacing: -1.5px;
        }
        .hero h1 .hl {
            background: linear-gradient(135deg, #C49450, #D4A373);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero p {
            font-size: 1.08rem;
            color: #6C757D;
            max-width: 540px;
            margin: 0 auto 38px;
            line-height: 1.6;
        }

        .hero-btns {
            display: flex;
            gap: 14px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-or {
            padding: 16px 32px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            text-decoration: none;
            border-radius: 14px;
            font-size: 0.92rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s;
            box-shadow: 0 6px 20px rgba(196,148,80,0.25);
        }
        .btn-or:hover { transform: translateY(-2px); box-shadow: 0 12px 30px rgba(196,148,80,0.35); }

        .btn-ghost {
            padding: 16px 32px;
            background: white;
            color: #1a1a2e;
            text-decoration: none;
            border-radius: 14px;
            font-size: 0.92rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
            border: 2px solid #E9ECEF;
            transition: all 0.3s;
        }
        .btn-ghost:hover { border-color: #C49450; color: #C49450; }

        /* ===== SECTIONS ===== */
        section { scroll-margin-top: 80px; position: relative; z-index: 1; }

        .sec {
            padding: 64px 40px;
            max-width: 1100px;
            margin: 0 auto;
        }

        .sec-title {
            text-align: center;
            font-size: 2rem;
            font-weight: 700;
            color: #1a1a2e;
            margin-bottom: 48px;
            letter-spacing: -0.5px;
        }
        .sec-title span {
            background: linear-gradient(135deg, #C49450, #D4A373);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* ===== SERVICES ===== */
        .svc-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
        }
        .svc {
            background: white;
            border: 1px solid #EEE;
            border-radius: 20px;
            padding: 30px 20px;
            text-align: center;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
        }
        .svc:hover { border-color: #D4A373; transform: translateY(-6px); box-shadow: 0 14px 30px rgba(0,0,0,0.06); }

        .svc-icon-wrap {
            width: 62px;
            height: 62px;
            background: linear-gradient(135deg, #FDF6ED, #FFF5EB);
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            color: #C49450;
            font-size: 1.5rem;
        }
        .svc h3 { font-size: 1rem; font-weight: 600; color: #1a1a2e; margin-bottom: 7px; }
        .svc p { font-size: 0.8rem; color: #6C757D; line-height: 1.5; }

        /* ===== FEATURES ===== */
        .feat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
        }
        .feat {
            display: flex;
            gap: 15px;
            background: white;
            border: 1px solid #EEE;
            border-radius: 16px;
            padding: 20px;
            transition: all 0.25s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.015);
        }
        .feat:hover { border-color: #D4A373; box-shadow: 0 8px 22px rgba(0,0,0,0.04); }

        .feat-icon {
            width: 44px;
            height: 44px;
            background: #FDF6ED;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #C49450;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
        .feat h4 { font-size: 0.88rem; font-weight: 600; color: #1a1a2e; margin-bottom: 4px; }
        .feat p { font-size: 0.77rem; color: #6C757D; line-height: 1.4; }

        /* ===== STEPS ===== */
        .steps-row {
            display: flex;
            gap: 22px;
            justify-content: center;
        }
        .step-card {
            flex: 1;
            max-width: 310px;
            text-align: center;
            background: white;
            border: 1px solid #EEE;
            border-radius: 20px;
            padding: 32px 20px;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
        }
        .step-card:hover { border-color: #C49450; transform: translateY(-4px); }

        .step-num {
            width: 54px;
            height: 54px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            color: white;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            font-weight: 700;
            margin: 0 auto 16px;
            box-shadow: 0 6px 18px rgba(196,148,80,0.25);
        }
        .step-card h4 { font-size: 0.95rem; font-weight: 600; color: #1a1a2e; margin-bottom: 6px; }
        .step-card p { font-size: 0.81rem; color: #6C757D; }

        /* ===== FRAIS ===== */
        .frais-panel {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            border-radius: 24px;
            padding: 48px;
            text-align: center;
            box-shadow: 0 20px 50px rgba(26,26,46,0.2);
        }
        .frais-panel h3 {
            font-size: 1.6rem;
            font-weight: 700;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 14px;
        }
        .frais-panel h3 i { color: #C49450; }
        .frais-panel p {
            font-size: 0.92rem;
            color: #A8B2C1;
            max-width: 480px;
            margin: 0 auto 24px;
            line-height: 1.5;
        }

        /* ===== STATS ===== */
        .stats-row {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 48px;
            position: relative;
            z-index: 1;
        }
        .stat {
            text-align: center;
            padding: 20px 32px;
        }
        .stat .num {
            font-size: 2.5rem;
            font-weight: 800;
            color: #1a1a2e;
            letter-spacing: -1px;
        }
        .stat .num span {
            background: linear-gradient(135deg, #C49450, #D4A373);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .stat .lbl { font-size: 0.82rem; color: #6C757D; margin-top: 4px; font-weight: 500; }

        /* ===== FOOTER ===== */
        .footer-bar {
            background: #1a1a2e;
            text-align: center;
            padding: 20px;
            color: #5A6678;
            font-size: 0.73rem;
            position: relative;
            z-index: 1;
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 1000px) {
            .svc-grid { grid-template-columns: repeat(2, 1fr); }
            .feat-grid { grid-template-columns: repeat(2, 1fr); }
            .steps-row { flex-direction: column; align-items: center; }
            .step-card { max-width: 100%; }
        }
        @media (max-width: 768px) {
            .nav-links { display: none; }
            .burger { display: block; }
            .navbar { padding: 14px 20px; }
            .hero h1 { font-size: 2.4rem; }
            .hero { padding: 52px 16px 52px; }
            .sec { padding: 40px 16px; }
            .svc-grid, .feat-grid { grid-template-columns: 1fr; }
            .frais-panel { padding: 30px 18px; }
            .stats-row { gap: 10px; }
            .stat .num { font-size: 2rem; }
        }
    </style>
</head>
<body>

<!-- ===== NAVBAR ===== -->
<header class="navbar">
    <div class="logo">
        <h2>KantyMoney</h2>
    </div>

    <nav class="nav-links">
        <a href="#services"><i class="fas fa-cube"></i> Services</a>
        <a href="#fonctionnalites"><i class="fas fa-star"></i> Fonctionnalités</a>
        <a href="#marche"><i class="fas fa-gear"></i> Comment ça marche</a>
    </nav>

    <div class="nav-auth">
        <a href="login.jsp" class="btn-login">
            <i class="fas fa-sign-in-alt"></i> Connexion
        </a>
        <a href="register.jsp" class="btn-register">
            <i class="fas fa-user-plus"></i> Inscription
        </a>
    </div>

    <div class="burger"><i class="fas fa-bars"></i></div>
</header>

<!-- ===== HERO ===== -->
<div class="hero">
    <div class="hero-badge">
        <i class="fas fa-circle dot"></i> Disponible dans tout Madagascar
    </div>
    <h1>
        Votre argent,<br>
        <span class="hl">en toute simplicité</span>.
    </h1>
    <p>
        KantyMoney est la solution de mobile money malgache qui vous permet 
        d'envoyer, recevoir et gérer votre argent facilement, en toute sécurité.
    </p>
 <div class="hero-btns">
    <a href="register.jsp" class="btn-or">
        <i class="fas fa-rocket"></i> Ouvrir un compte gratuit
    </a>
    <a href="index_op.jsp" class="btn-ghost">
        <i class="fas fa-user-tie"></i> Vous êtes opérateur ? Cliquez ici
    </a>
</div>
</div>

<!-- ===== SERVICES ===== -->
<section class="sec" id="services">
    <h2 class="sec-title">Nos <span>services</span> essentiels</h2>
    <div class="svc-grid">
        <div class="svc">
            <div class="svc-icon-wrap"><i class="fas fa-paper-plane"></i></div>
            <h3>Envoyer</h3>
            <p>Transferts instantanés vers n'importe quel numéro KantyMoney. Frais transparents.</p>
        </div>
        <div class="svc">
            <div class="svc-icon-wrap"><i class="fas fa-download"></i></div>
            <h3>Recevoir</h3>
            <p>Recevez des fonds directement sur votre compte. Notification par email à chaque réception.</p>
        </div>
        <div class="svc">
            <div class="svc-icon-wrap"><i class="fas fa-hand-holding-dollar"></i></div>
            <h3>Retirer</h3>
            <p>Retirez votre argent chez nos nombreux partenaires répartis dans tout Madagascar.</p>
        </div>
        <div class="svc">
            <div class="svc-icon-wrap"><i class="fas fa-wallet"></i></div>
            <h3>Consulter</h3>
            <p>Vérifiez votre solde en temps réel et suivez toutes vos transactions passées.</p>
        </div>
    </div>
</section>

<!-- ===== FONCTIONNALITÉS ===== -->
<section class="sec" id="fonctionnalites">
    <h2 class="sec-title">Des <span>fonctionnalités</span> pensées pour vous</h2>
    <div class="feat-grid">
        <div class="feat">
            <div class="feat-icon"><i class="fas fa-clock-rotate-left"></i></div>
            <div>
                <h4>Historique complet</h4>
                <p>Retrouvez l'intégralité de vos transactions passées en un clin d'œil</p>
            </div>
        </div>
        <div class="feat">
            <div class="feat-icon"><i class="fas fa-search"></i></div>
            <div>
                <h4>Recherche avancée</h4>
                <p>Trouvez une transaction spécifique par date ou par nom de contact</p>
            </div>
        </div>
        <div class="feat">
            <div class="feat-icon"><i class="fas fa-file-pdf"></i></div>
            <div>
                <h4>Relevé PDF mensuel</h4>
                <p>Générez et téléchargez vos relevés bancaires au format PDF</p>
            </div>
        </div>
        <div class="feat">
            <div class="feat-icon"><i class="fas fa-bell"></i></div>
            <div>
                <h4>Notifications email</h4>
                <p>Restez informé en temps réel de chaque mouvement sur votre compte</p>
            </div>
        </div>
        <div class="feat">
            <div class="feat-icon"><i class="fas fa-chart-line"></i></div>
            <div>
                <h4>Recette opérateur</h4>
                <p>Visualisez en toute transparence les commissions perçues par l'opérateur</p>
            </div>
        </div>
        <div class="feat">
            <div class="feat-icon"><i class="fas fa-lock"></i></div>
            <div>
                <h4>Sécurité renforcée</h4>
                <p>Vos transactions sont protégées par un cryptage de bout en bout</p>
            </div>
        </div>
    </div>
</section>

<!-- ===== ÉTAPES ===== -->
<section class="sec" id="marche">
    <h2 class="sec-title">Comment ça <span>marche</span> ?</h2>
    <div class="steps-row">
        <div class="step-card">
            <div class="step-num">1</div>
            <h4>Inscrivez-vous</h4>
            <p>Créez votre compte gratuitement en moins de 2 minutes</p>
        </div>
        <div class="step-card">
            <div class="step-num">2</div>
            <h4>Alimentez</h4>
            <p>Déposez de l'argent chez l'un de nos nombreux partenaires</p>
        </div>
        <div class="step-card">
            <div class="step-num">3</div>
            <h4>Profitez</h4>
            <p>Envoyez, recevez et retirez votre argent en toute liberté</p>
        </div>
    </div>
</section>

<!-- ===== STATS ===== -->
<div class="stats-row">
    <div class="stat">
        <div class="num"><span>+50 000</span></div>
        <div class="lbl">Utilisateurs actifs</div>
    </div>
    <div class="stat">
        <div class="num"><span>+200</span></div>
        <div class="lbl">Points de retrait</div>
    </div>
    <div class="stat">
        <div class="num"><span>24/7</span></div>
        <div class="lbl">Service disponible</div>
    </div>
</div>



<!-- ===== FOOTER ===== -->
<footer class="footer-bar">
    &copy; 2026 KantyMoney &mdash; Tous droits réservés
</footer>

</body>
</html>