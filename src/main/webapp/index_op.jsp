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

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: #FAFAFA;
            color: #1A1A1A;
            overflow-x: hidden;
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
        }

        /* ===== NAVBAR ===== */
        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 1.2rem 5%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--gris-clair);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            animation: slideDown 0.6s ease-out;
        }

        @keyframes slideDown {
            from {
                transform: translateY(-100%);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .logo-area {
            display: flex;
            align-items: baseline;
            gap: 6px;
        }

        .logo-area h1 {
            font-weight: 700;
            font-size: 1.8rem;
            color: var(--noir-doux);
            letter-spacing: -0.5px;
        }

        .logo-area .accent {
            color: var(--marron);
        }

        .logo-area .badge {
            background: var(--marron);
            color: white;
            font-size: 0.65rem;
            font-weight: 600;
            padding: 3px 10px;
            border-radius: 20px;
            margin-left: 8px;
            letter-spacing: 0.5px;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 32px;
        }

        .nav-links a {
            color: var(--noir-doux);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.95rem;
            transition: color 0.2s;
        }

        .nav-links a:hover {
            color: var(--marron);
        }

        .btn-connexion {
            background: var(--marron);
            color: white !important;
            padding: 12px 28px;
            border-radius: 40px;
            font-weight: 600;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
            font-size: 0.95rem;
            box-shadow: 0 4px 12px rgba(196, 148, 80, 0.2);
        }

        .btn-connexion:hover {
            background: var(--marron-fonce);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(196, 148, 80, 0.3);
        }

        /* ===== HERO ===== */
        .hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 100px 5% 60px;
            position: relative;
            overflow: hidden;
        }

        .hero-bg {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 0;
        }

        .hero-bg-circle {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(196, 148, 80, 0.08) 0%, transparent 70%);
            animation: float 20s infinite ease-in-out;
        }

        .circle-1 {
            width: 600px;
            height: 600px;
            top: -200px;
            right: -100px;
        }

        .circle-2 {
            width: 400px;
            height: 400px;
            bottom: -100px;
            left: -50px;
            animation-delay: -5s;
        }

        .circle-3 {
            width: 300px;
            height: 300px;
            top: 50%;
            left: 30%;
            animation-delay: -10s;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0) scale(1);
            }
            50% {
                transform: translateY(-30px) scale(1.05);
            }
        }

        .hero-content {
            position: relative;
            z-index: 10;
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
        }

        .hero-badge {
            background: var(--marron-tres-clair);
            color: var(--marron);
            padding: 8px 20px;
            border-radius: 40px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 28px;
            border: 1px solid rgba(196, 148, 80, 0.2);
            animation: fadeInUp 0.6s ease-out;
        }

        .hero-title {
            font-size: 4rem;
            font-weight: 700;
            line-height: 1.2;
            letter-spacing: -1.5px;
            margin-bottom: 24px;
            color: var(--noir-doux);
            animation: fadeInUp 0.6s ease-out 0.1s both;
        }

        .hero-title .highlight {
            color: var(--marron);
            position: relative;
            display: inline-block;
        }

        .hero-title .highlight::after {
            content: '';
            position: absolute;
            bottom: 8px;
            left: 0;
            width: 100%;
            height: 8px;
            background: rgba(196, 148, 80, 0.2);
            z-index: -1;
            border-radius: 4px;
        }

        .hero-subtitle {
            font-size: 1.25rem;
            color: var(--gris-fonce);
            max-width: 700px;
            margin: 0 auto 40px;
            animation: fadeInUp 0.6s ease-out 0.2s both;
        }

        .hero-actions {
            display: flex;
            gap: 20px;
            justify-content: center;
            animation: fadeInUp 0.6s ease-out 0.3s both;
        }

        .btn-primary {
            background: var(--marron);
            color: white;
            padding: 16px 40px;
            border-radius: 50px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            transition: all 0.3s;
            font-size: 1.1rem;
            box-shadow: 0 8px 20px rgba(196, 148, 80, 0.25);
        }

        .btn-primary:hover {
            background: var(--marron-fonce);
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(196, 148, 80, 0.35);
        }

        .btn-outline {
            background: white;
            color: var(--noir-doux);
            padding: 16px 40px;
            border-radius: 50px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            transition: all 0.3s;
            font-size: 1.1rem;
            border: 1.5px solid var(--gris-moyen);
        }

        .btn-outline:hover {
            border-color: var(--marron);
            color: var(--marron);
            background: var(--marron-tres-clair);
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ===== STATS ===== */
        .stats-section {
            padding: 60px 5%;
            background: var(--blanc);
            border-top: 1px solid var(--gris-clair);
            border-bottom: 1px solid var(--gris-clair);
        }

        .stats-grid {
            display: flex;
            justify-content: center;
            gap: 80px;
            flex-wrap: wrap;
            max-width: 1000px;
            margin: 0 auto;
        }

        .stat-item {
            text-align: center;
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.6s ease-out;
        }

        .stat-item.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 700;
            color: var(--marron);
            line-height: 1.2;
        }

        .stat-label {
            color: var(--gris-fonce);
            font-size: 1rem;
        }

        /* ===== FEATURES ===== */
        .features-section {
            padding: 80px 5%;
        }

        .section-title {
            text-align: center;
            font-size: 2.5rem;
            font-weight: 600;
            color: var(--noir-doux);
            margin-bottom: 50px;
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.6s ease-out;
        }

        .section-title.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .section-title span {
            color: var(--marron);
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 30px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .feature-card {
            background: var(--blanc);
            border: 1px solid var(--gris-clair);
            border-radius: 24px;
            padding: 32px 28px;
            text-align: center;
            transition: all 0.3s;
            opacity: 0;
            transform: translateY(30px);
            transition: all 0.6s ease-out;
        }

        .feature-card.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .feature-card:hover {
            transform: translateY(-8px) !important;
            border-color: var(--marron-clair);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.05);
        }

        .feature-icon {
            width: 80px;
            height: 80px;
            background: var(--marron-tres-clair);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            color: var(--marron);
            font-size: 2rem;
        }

        .feature-card h3 {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--noir-doux);
        }

        .feature-card p {
            color: var(--gris-fonce);
            font-size: 0.95rem;
            line-height: 1.6;
        }

        /* ===== CTA ===== */
        .cta-section {
            padding: 80px 5%;
            background: linear-gradient(135deg, var(--marron-tres-clair), #FFF5EB);
            text-align: center;
        }

        .cta-content {
            max-width: 700px;
            margin: 0 auto;
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.6s ease-out;
        }

        .cta-content.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .cta-content h2 {
            font-size: 2.5rem;
            font-weight: 600;
            color: var(--noir-doux);
            margin-bottom: 16px;
        }

        .cta-content p {
            color: var(--gris-fonce);
            font-size: 1.1rem;
            margin-bottom: 32px;
        }

        /* ===== FOOTER ===== */
        footer {
            background: var(--blanc);
            padding: 30px 5%;
            border-top: 1px solid var(--gris-clair);
            color: var(--gris-fonce);
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
            font-size: 0.9rem;
        }

        footer a {
            color: var(--marron);
            text-decoration: none;
        }

        /* Responsive */
        @media (max-width: 900px) {
            .hero-title {
                font-size: 3rem;
            }
            .nav-links {
                display: none;
            }
        }

        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.2rem;
            }
            .hero-subtitle {
                font-size: 1rem;
            }
            .hero-actions {
                flex-direction: column;
                align-items: center;
            }
            .stats-grid {
                gap: 40px;
            }
            .stat-number {
                font-size: 2.2rem;
            }
            .section-title {
                font-size: 2rem;
            }
            .cta-content h2 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <!-- NAVBAR -->
    <header class="navbar">
        <div class="logo-area">
            <h1>Kanty<span class="accent">Money</span></h1>
            <span class="badge">OPÉRATEUR</span>
        </div>
        
        <div class="nav-links">
            <a href="#features">Fonctionnalités</a>
            <a href="#stats">Statistiques</a>
            <a href="#contact">Contact</a>
        </div>
        
        <a href="operateur/login-operateur.jsp" class="btn-connexion">
            <i class="fas fa-sign-in-alt"></i>
            Espace opérateur
        </a>
    </header>

    <main>
        <!-- HERO -->
        <section class="hero">
            <div class="hero-bg">
                <div class="hero-bg-circle circle-1"></div>
                <div class="hero-bg-circle circle-2"></div>
                <div class="hero-bg-circle circle-3"></div>
            </div>
            
            <div class="hero-content">
                <div class="hero-badge">
                    <i class="fas fa-shield-hal" style="margin-right: 8px;"></i>
                    ESPACE RÉSERVÉ AUX OPÉRATEURS
                </div>
                
                <h1 class="hero-title">
                    Gérez KantyMoney<br>
                    <span class="highlight">en toute simplicité</span>
                </h1>
                
                <p class="hero-subtitle">
                    Accédez à votre tableau de bord opérateur pour gérer les transactions, 
                    suivre les recettes et superviser l'ensemble de l'activité KantyMoney.
                </p>
                
                <div class="hero-actions">
    <a href="operateur/login-operateur.jsp" class="btn-primary">
        <i class="fas fa-lock"></i>
        Accéder à l'espace opérateur
    </a>
    <a href="index.jsp" class="btn-outline">
        <i class="fas fa-users"></i>
        Espace client ? Cliquez ici
    </a>
</div>
            </div>
        </section>
        
        <!-- STATS -->
        <section class="stats-section" id="stats">
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-number"><span class="counter" data-target="52847">0</span></div>
                    <div class="stat-label">Utilisateurs actifs</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><span class="counter" data-target="8234">0</span></div>
                    <div class="stat-label">Transactions / jour</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><span class="counter" data-target="247">0</span></div>
                    <div class="stat-label">Partenaires</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><span class="counter" data-target="42.8">0</span>M Ar</div>
                    <div class="stat-label">Recette totale</div>
                </div>
            </div>
        </section>
        
        <!-- FEATURES -->
        <section class="features-section" id="features">
            <h2 class="section-title">
                Tout ce dont vous avez besoin pour <span>gérer</span>
            </h2>
            
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <h3>Tableau de bord</h3>
                    <p>Visualisez en temps réel l'ensemble des activités et performances de la plateforme.</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-coins"></i>
                    </div>
                    <h3>Recette opérateur</h3>
                    <p>Suivez les commissions perçues sur les envois et retraits en toute transparence.</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3>Gestion utilisateurs</h3>
                    <p>Gérez les comptes clients, validez les inscriptions et suivez les activités.</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-arrow-right-arrow-left"></i>
                    </div>
                    <h3>Transactions</h3>
                    <p>Consultez l'historique complet des transactions et recherchez des opérations spécifiques.</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-file-pdf"></i>
                    </div>
                    <h3>Rapports détaillés</h3>
                    <p>Générez des rapports quotidiens, mensuels ou personnalisés au format PDF.</p>
                </div>
                
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-building"></i>
                    </div>
                    <h3>Gestion partenaires</h3>
                    <p>Ajoutez et gérez les points de retrait et agences partenaires.</p>
                </div>
            </div>
        </section>
        
        <!-- CTA -->
        <section class="cta-section">
            <div class="cta-content">
                <h2>Prêt à gérer votre plateforme ?</h2>
                <p>Connectez-vous à votre espace opérateur et accédez à tous les outils de gestion.</p>
                <a href="operateur/login-operateur.jsp" class="btn-primary">
                    <i class="fas fa-sign-in-alt"></i>
                    Se connecter
                </a>
            </div>
        </section>
    </main>
    
    <!-- FOOTER -->
    <footer id="contact">
        <div>
            <i class="far fa-copyright"></i> 2026 KantyMoney — Espace Opérateur
        </div>
        <div>
            <i class="fas fa-headset"></i> Support opérateur : 032 44 321 67
        </div>
        <div>
            <i class="fas fa-shield"></i> Accès sécurisé
        </div>
    </footer>
    
    <script>
        // Animation au scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                }
            });
        }, observerOptions);
        
        // Observer les éléments
        document.querySelectorAll('.stat-item, .section-title, .feature-card, .cta-content').forEach(el => {
            observer.observe(el);
        });
        
        // Compteur animé
        const counters = document.querySelectorAll('.counter');
        const speed = 200;
        
        const counterObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const counter = entry.target;
                    const target = parseFloat(counter.getAttribute('data-target'));
                    let count = 0;
                    
                    const updateCount = () => {
                        const increment = target / speed;
                        
                        if (count < target) {
                            count += increment;
                            counter.innerText = target % 1 === 0 ? Math.ceil(count) : count.toFixed(1);
                            setTimeout(updateCount, 1);
                        } else {
                            counter.innerText = target % 1 === 0 ? target : target.toFixed(1);
                        }
                    };
                    
                    updateCount();
                    counterObserver.unobserve(counter);
                }
            });
        }, { threshold: 0.5 });
        
        counters.forEach(counter => {
            counterObserver.observe(counter);
        });
        
        // Animation du header au scroll
        let lastScroll = 0;
        const navbar = document.querySelector('.navbar');
        
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > 100) {
                navbar.style.background = 'rgba(255, 255, 255, 0.98)';
                navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.05)';
            } else {
                navbar.style.background = 'rgba(255, 255, 255, 0.95)';
                navbar.style.boxShadow = 'none';
            }
            
            lastScroll = currentScroll;
        });
    </script>
</body>
</html>