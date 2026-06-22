<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.util.MoneyFormat" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Envoi réussi</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav-client.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background-color: #FAFAFA; min-height: 100vh; display: flex; }

        :root {
            --blanc: #FFFFFF; --gris-fonce: #6C757D; --noir-doux: #212529;
            --marron: #C49450; --marron-fonce: #A67A3E; --marron-tres-clair: #FDF6ED;
        }

        .main-content { flex: 1; margin-left: 280px; padding: 40px; display: flex; justify-content: center; align-items: center; }
        
        .success-container {
            max-width: 500px; width: 100%; background: var(--blanc); border-radius: 28px;
            padding: 48px 36px; text-align: center; border: 1px solid #E9ECEF;
            box-shadow: 0 10px 30px rgba(0,0,0,0.04);
        }

        .success-icon {
            width: 90px; height: 90px; background: #F0FDF4; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 24px; font-size: 3rem; color: #28A745;
        }

        .success-container h2 { font-size: 1.8rem; font-weight: 700; color: var(--noir-doux); margin-bottom: 8px; }
        .success-container .subtitle { color: var(--gris-fonce); margin-bottom: 32px; font-size: 0.95rem; }

        .resume-card {
            background: #F8F9FA; border-radius: 18px; padding: 24px; margin-bottom: 28px; text-align: left;
        }

        .resume-row {
            display: flex; justify-content: space-between; padding: 12px 0;
            border-bottom: 1px solid #DEE2E6; font-size: 0.95rem;
        }
        .resume-row:last-child { border-bottom: none; }
        .resume-row.total { font-weight: 700; font-size: 1.15rem; color: var(--noir-doux); border-top: 2px solid var(--marron); padding-top: 16px; margin-top: 8px; }
        .resume-label { color: var(--gris-fonce); }
        .resume-value { font-weight: 500; color: var(--noir-doux); }

        .btn-primary {
            width: 100%; padding: 16px; background: var(--marron); color: white; border: none;
            border-radius: 16px; font-size: 1rem; font-weight: 600; cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 10px;
            text-decoration: none; transition: all 0.3s; font-family: 'Inter', sans-serif;
        }
        .btn-primary:hover { background: var(--marron-fonce); }

        .btn-secondary {
            width: 100%; padding: 14px; background: white; color: var(--noir-doux);
            border: 2px solid #DEE2E6; border-radius: 16px; font-size: 0.95rem; font-weight: 500;
            cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;
            text-decoration: none; margin-top: 12px; font-family: 'Inter', sans-serif;
        }
        .btn-secondary:hover { border-color: var(--marron); color: var(--marron); }

        @media (max-width: 768px) {
            .main-content { margin-left: 0; padding: 20px; }
        }
    </style>
</head>
<body>
    
    <main class="main-content">
        <div class="success-container">
            <div class="success-icon">
                <i class="fas fa-check-circle"></i>
            </div>
            <h2>Envoi réussi !</h2>
            <p class="subtitle">Votre transfert a été effectué avec succès</p>
            
            <div class="resume-card">
                <div class="resume-row">
                    <span class="resume-label">Montant envoyé</span>
                    <span class="resume-value"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("montantEnvoye"))) %> Ar</span>
                </div>
                <div class="resume-row">
                    <span class="resume-label">Frais d'envoi</span>
                    <span class="resume-value"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("fraisEnvoi"))) %> Ar</span>
                </div>
                <% if ((int) request.getAttribute("fraisRetrait") > 0) { %>
                <div class="resume-row">
                    <span class="resume-label">Frais de retrait (offerts)</span>
                    <span class="resume-value"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("fraisRetrait"))) %> Ar</span>
                </div>
                <% } %>
                <div class="resume-row total">
                    <span class="resume-label">Total débité</span>
                    <span class="resume-value"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("totalDebite"))) %> Ar</span>
                </div>
                <div class="resume-row" style="color: #28A745;">
                    <span class="resume-label">Montant reçu par le bénéficiaire</span>
                    <span class="resume-value" style="color: #28A745;"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("montantRecu"))) %> Ar</span>
                </div>
            </div>
            
            <a href="dashboardclient.jsp" class="btn-primary">
                <i class="fas fa-home"></i>
                Retour au tableau de bord
            </a>
            <a href="envoi" class="btn-secondary">
                <i class="fas fa-paper-plane"></i>
                Nouvel envoi
            </a>
        </div>
    </main>
</body>
</html>