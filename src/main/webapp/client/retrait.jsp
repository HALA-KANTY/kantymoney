<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.ClientDAO, java.util.*" %>
<%@ page import="com.steeven.util.MoneyFormat" %>
<%
    if (session == null || session.getAttribute("numtel") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    String numtel = (String) session.getAttribute("numtel");
    ClientDAO clientDAO = new ClientDAO();
    List<String[]> clients = clientDAO.searchClients(numtel);
    
    String nom = "";
    String initiales = "";
    String numtelFormatte = numtel;
    
    if (clients != null && !clients.isEmpty()) {
        String[] client = clients.get(0);
        nom = (client[1] != null) ? client[1] : "";
        String[] parts = nom.split(" ");
        for (String part : parts) {
            if (!part.isEmpty() && initiales.length() < 2) initiales += part.charAt(0);
        }
    }
    
    if (numtel != null && numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }
    
    List<String[]> allRetraits = (List<String[]>) request.getAttribute("retraits");
    
    int totalRetraits = (allRetraits != null) ? allRetraits.size() : 0;
    int pageSize = 8;
    int totalPages = (int) Math.ceil((double) totalRetraits / pageSize);
    int currentPage = 1;
    try { currentPage = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    
    int start = (currentPage - 1) * pageSize;
    int end = Math.min(start + pageSize, totalRetraits);
    List<String[]> retraits = (allRetraits != null && !allRetraits.isEmpty()) ? allRetraits.subList(start, end) : new ArrayList<>();
    
    boolean showInputModal = Boolean.TRUE.equals(request.getAttribute("showInputModal"));
    boolean showConfirmModal = Boolean.TRUE.equals(request.getAttribute("showConfirmModal"));
    boolean showSuccessModal = Boolean.TRUE.equals(request.getAttribute("showSuccessModal"));
    String errorMsg = (String) request.getAttribute("error");
    
    String fDate = request.getAttribute("filterDate") != null ? (String) request.getAttribute("filterDate") : "";
    String listDateQs = "";
    try {
        if (fDate != null && !fDate.isEmpty()) {
            listDateQs += "date=" + java.net.URLEncoder.encode(fDate, "UTF-8");
        }
    } catch (java.io.UnsupportedEncodingException e) { /* ignore */ }
    String retraitPageBase = request.getContextPath() + "/retrait";
    String pageQs = listDateQs.isEmpty() ? "?" : "?" + listDateQs + "&";
    
    String montantStr = (String) request.getAttribute("montant");
    Integer fraisRetrait = (Integer) request.getAttribute("fraisRetrait");
    Integer totalDebiter = (Integer) request.getAttribute("totalDebiter");
    
    Integer successMontant = (Integer) request.getAttribute("successMontant");
    Integer successFraisRetrait = (Integer) request.getAttribute("successFraisRetrait");
    Integer successTotalDebite = (Integer) request.getAttribute("successTotalDebite");
    Integer successNouveauSolde = (Integer) request.getAttribute("successNouveauSolde");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Retrait</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav-client.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #faf5f0 100%);
            height: 100vh; display: flex; overflow: hidden; color: #212529;
        }

          .sidebar {
            width: 280px;
            height: 100vh;
            position: fixed;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
            color: white;
            display: flex;
            flex-direction: column;
            box-shadow: 4px 0 25px rgba(0, 0, 0, 0.1);
            z-index: 100;
            overflow: hidden;
        }
        
        .sidebar-header {
            padding: 32px 24px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }
        
        .sidebar-header h2 {
            font-size: 1.8rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #C49450, #E8C87A);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .sidebar-header span {
            display: block;
            font-size: 0.75rem;
            font-weight: 400;
            color: #A8B2C1;
            margin-top: 6px;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }
        
        .user-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #C49450, #D4A373);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.2rem;
            color: white;
            box-shadow: 0 4px 15px rgba(196, 148, 80, 0.3);
            flex-shrink: 0;
        }
        
        .user-info h4 {
            font-size: 1rem;
            font-weight: 600;
            color: white;
            margin-bottom: 4px;
        }
        
        .user-info p {
            font-size: 0.78rem;
            color: #A8B2C1;
            font-weight: 400;
        }
        
        .sidebar-nav {
            flex: 1;
            padding: 16px 12px;
            overflow-y: auto;
            overflow-x: hidden;
            min-height: 0;
        }
        
        .sidebar-nav::-webkit-scrollbar {
            width: 3px;
        }
        
        .sidebar-nav::-webkit-scrollbar-track {
            background: transparent;
        }
        
        .sidebar-nav::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }
        
        .nav-section {
            margin-bottom: 20px;
        }
        
        .nav-section-title {
            font-size: 0.7rem;
            font-weight: 600;
            color: #6C7A8D;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            padding: 8px 12px;
            margin-bottom: 4px;
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 14px 16px;
            border-radius: 12px;
            color: #B0B9C6;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.93rem;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            margin-bottom: 4px;
            white-space: nowrap;
        }
        
        .nav-item i {
            width: 22px;
            font-size: 1.15rem;
            text-align: center;
            flex-shrink: 0;
        }
        
        .nav-item:hover {
            background: rgba(255, 255, 255, 0.06);
            color: #E8C87A;
            transform: translateX(4px);
        }
        
        .nav-item.active {
            background: rgba(196, 148, 80, 0.15);
            color: #E8C87A;
            font-weight: 600;
            box-shadow: inset 3px 0 0 #C49450;
        }
        
        .nav-item.logout {
            color: #E8878A;
            opacity: 0.8;
        }
        
        .nav-item.logout:hover {
            background: rgba(220, 53, 69, 0.1);
            color: #F4A2A4;
        }
        
        .sidebar-footer {
            padding: 16px 24px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            font-size: 0.7rem;
            color: #5A6678;
            text-align: center;
            letter-spacing: 0.5px;
            flex-shrink: 0;
        }


        /* ===== MAIN ===== */
        .main-content { flex: 1; margin-left: 280px; padding: 24px 32px; height: 100vh; display: flex; flex-direction: column; overflow: hidden; }

        .top-bar {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            border-radius: 18px; padding: 18px 26px; margin-bottom: 16px;
            display: flex; align-items: center; justify-content: space-between; gap: 16px;
            box-shadow: 0 6px 25px rgba(26,26,46,0.2); flex-shrink: 0;
            flex-wrap: wrap;
        }
        .top-bar h1 { font-size: 1.4rem; font-weight: 700; color: white; display: flex; align-items: center; gap: 10px; white-space: nowrap; }
        .top-bar h1 i { color: #C49450; }
        
        .top-bar-right {
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }
        
        .top-bar-filter {
            display: flex; align-items: center; gap: 8px;
            background: rgba(255,255,255,0.08);
            border-radius: 12px; padding: 6px 6px 6px 14px;
            border: 1px solid rgba(255,255,255,0.12);
        }
        
        .top-bar-filter i {
            color: #A8B2C1; font-size: 0.85rem;
        }
        
        .top-bar-filter input[type="date"] {
            background: transparent; border: none; color: white; font-family: 'Inter', sans-serif;
            font-size: 0.85rem; padding: 6px 8px; outline: none; width: 140px;
        }
        
        .top-bar-filter input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(0.8); cursor: pointer;
        }
        
        .top-bar-filter .btn-reset-filter {
            background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.15);
            color: #A8B2C1; border-radius: 8px; padding: 7px 12px;
            cursor: pointer; font-family: 'Inter', sans-serif; font-size: 0.78rem;
            font-weight: 500; display: flex; align-items: center; gap: 5px;
            transition: all 0.2s; white-space: nowrap;
        }
        
        .top-bar-filter .btn-reset-filter:hover {
            background: rgba(255,255,255,0.15); color: white;
        }

        .btn-or {
            padding: 11px 20px; background: linear-gradient(135deg, #C49450, #D4A373);
            color: white; border: none; border-radius: 12px; font-size: 0.85rem; font-weight: 600;
            cursor: pointer; display: flex; align-items: center; gap: 8px;
            transition: all 0.3s; font-family: 'Inter', sans-serif;
            box-shadow: 0 4px 15px rgba(196,148,80,0.25); white-space: nowrap;
        }
        .btn-or:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(196,148,80,0.35); }

        /* ===== TABLEAU ===== */
        .card-table {
            background: white; border: 1px solid #E9ECEF; border-radius: 16px;
            overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            flex: 1; display: flex; flex-direction: column; min-height: 0;
        }
        .card-table-head {
            padding: 14px 22px;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            display: flex; justify-content: space-between; align-items: center; flex-shrink: 0;
        }
        .card-table-head h3 { font-size: 0.92rem; font-weight: 600; color: white; display: flex; align-items: center; gap: 8px; }
        .card-table-head h3 i { color: #C49450; }
        .tx-table-wrapper { overflow-x: hidden; }
        .tx-table { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .tx-table th, .tx-table td {
            padding: 14px 16px;
            border-bottom: 1px solid #E9ECEF;
            font-size: 0.9rem;
            text-align: center;
        }
        .tx-table th {
            font-size: 0.75rem;
            color: #6C757D;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            background: #F8F9FA;
        }
        .tx-table tbody tr:hover { background: #FDF6ED; }
        .badge-retrait { background: #FFF7ED; color: #FD7E14; border-radius: 20px; padding: 5px 11px; font-size: 0.8rem; font-weight: 600; }

        .cell-ref { font-weight: 700; color: #C49450; }
        .cell-montant { font-weight: 700; color: #DC3545; text-align: right; }
        .cell-date { text-align: right; color: #6C757D; font-size: 0.8rem; }
        .cell-action { display: flex; gap: 6px; justify-content: center; }

        .btn-icon {
            width: 34px; height: 34px; border-radius: 8px;
            border: 1.5px solid #DEE2E6; background: white;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: all 0.2s; font-size: 0.8rem;
        }
        .btn-icon.cancel { color: #FD7E14; }
        .btn-icon.cancel:hover { background: #FFF3E0; border-color: #FD7E14; color: #FD7E14; }

        /* ===== PAGINATION ===== */
        .pag {
            display: flex; justify-content: center; gap: 5px;
            padding: 11px 22px; border-top: 1px solid #E9ECEF;
            background: #F8F9FA; flex-shrink: 0;
        }
        .pag a, .pag span {
            min-width: 32px; height: 32px; border-radius: 8px;
            font-size: 0.78rem; font-weight: 500; text-decoration: none;
            color: #212529; border: 2px solid #DEE2E6; background: white;
            display: flex; align-items: center; justify-content: center; transition: all 0.2s;
        }
        .pag a:hover { background: #FDF6ED; border-color: #C49450; color: #C49450; }
        .pag .active { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: white; border-color: #1a1a2e; font-weight: 600; }
        .pag .off { opacity: 0.3; pointer-events: none; }

        /* ===== MODAUX ===== */
        .overlay {
    position: fixed;
    inset: 0;
    background: rgba(26, 26, 46, 0.75);
    backdrop-filter: blur(8px);
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.overlay.on {
    opacity: 1;
    visibility: visible;
}

.dlg {
    background: white;
    border-radius: 28px;
    max-height: 85vh;
    overflow-y: auto;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.35);
    transform: scale(0.95) translateY(20px);
    transition: all 0.3s cubic-bezier(0.34, 1.2, 0.64, 1);
    width: calc(100% - 32px);
    max-width: 680px;
}

.overlay.on .dlg {
    transform: scale(1) translateY(0);
}

.dlg-head {
    padding: 20px 24px;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-radius: 28px 28px 0 0;
    position: sticky;
    top: 0;
    z-index: 10;
}

.dlg-head h3 {
    font-size: 1.1rem;
    font-weight: 700;
    color: white;
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 0;
}

.dlg-head h3 i {
    color: #C49450;
    font-size: 1.2rem;
}

.dlg-close {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    background: rgba(255, 255, 255, 0.05);
    cursor: pointer;
    color: #A8B2C1;
    font-size: 1rem;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
}

.dlg-close:hover {
    background: rgba(220, 53, 69, 0.2);
    color: #F4A2A4;
    transform: scale(1.05) rotate(90deg);
}

.dlg-body {
    padding: 24px;
}

/* Steps améliorés */
.steps {
    display: flex;
    justify-content: center;
    gap: 8px;
    margin-bottom: 24px;
    align-items: center;
}

.step {
    width: 34px;
    height: 34px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.8rem;
    font-weight: 700;
    transition: all 0.3s ease;
}

.step.on {
    background: linear-gradient(135deg, #C49450, #D4A373);
    color: white;
    box-shadow: 0 4px 12px rgba(196, 148, 80, 0.4);
    transform: scale(1.05);
}

.step.ok {
    background: linear-gradient(135deg, #28A745, #20C997);
    color: white;
    box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
}

.step.off {
    background: #F1F3F5;
    color: #ADB5BD;
}

.step-line {
    width: 40px;
    height: 2px;
    background: #E9ECEF;
    transition: all 0.3s ease;
}

.step-line.ok {
    background: linear-gradient(90deg, #28A745, #20C997);
}

/* Alertes */
.alert-err {
    background: #FEF3F2;
    border-left: 4px solid #DC3545;
    color: #DC3545;
    padding: 12px 16px;
    border-radius: 12px;
    font-size: 0.85rem;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 10px;
    animation: shake 0.3s ease;
}

@keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-5px); }
    75% { transform: translateX(5px); }
}

.alert-err i {
    font-size: 1.1rem;
}

/* Formulaires améliorés */
.f-group {
    margin-bottom: 20px;
}

.f-group label {
    display: block;
    font-size: 0.85rem;
    font-weight: 600;
    color: #2C3E50;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.f-group label i {
    color: #C49450;
    font-size: 0.9rem;
}

.f-input {
    position: relative;
}

.f-input input {
    width: 100%;
    padding: 12px 14px;
    background: #F8F9FA;
    border: 2px solid #E9ECEF;
    border-radius: 14px;
    font-size: 0.95rem;
    font-family: 'Inter', sans-serif;
    outline: none;
    transition: all 0.25s;
}

.f-input input:hover {
    background: #FFFFFF;
}

.f-input input:focus {
    border-color: #C49450;
    background: white;
    box-shadow: 0 0 0 4px rgba(196, 148, 80, 0.1);
}

.f-input .unit {
    position: absolute;
    right: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: #C49450;
    font-weight: 700;
    font-size: 0.85rem;
    background: white;
    padding: 0 4px;
}

/* Boutons améliorés */
.btn-full {
    width: 100%;
    padding: 14px;
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
    transition: all 0.3s;
    font-family: 'Inter', sans-serif;
    box-shadow: 0 4px 15px rgba(196, 148, 80, 0.25);
    position: relative;
    overflow: hidden;
}

.btn-full::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
    transition: left 0.5s;
}

.btn-full:hover::before {
    left: 100%;
}

.btn-full:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(196, 148, 80, 0.4);
}

.btn-full:active {
    transform: translateY(1px);
}

.btn-full.green {
    background: linear-gradient(135deg, #28A745, #20C997);
    box-shadow: 0 4px 15px rgba(40, 167, 69, 0.25);
}

.btn-full.green:hover {
    box-shadow: 0 8px 25px rgba(40, 167, 69, 0.35);
}

.btn-ghost {
    width: 100%;
    padding: 12px;
    background: white;
    color: #2C3E50;
    border: 2px solid #E9ECEF;
    border-radius: 14px;
    font-size: 0.9rem;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: all 0.25s;
    font-family: 'Inter', sans-serif;
    margin-top: 12px;
}

.btn-ghost:hover {
    border-color: #C49450;
    color: #C49450;
    background: #FFF8F0;
    transform: translateY(-1px);
}

/* Résumé amélioré */
.resume {
    background: linear-gradient(135deg, #F8F9FA 0%, #FFFFFF 100%);
    border-radius: 16px;
    padding: 18px;
    margin-bottom: 20px;
    border: 1px solid #E9ECEF;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.02);
}

.resume-row {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px solid #E9ECEF;
    font-size: 0.88rem;
}

.resume-row:last-child {
    border-bottom: none;
}

.resume-row.total {
    font-weight: 700;
    font-size: 1rem;
    color: #1a1a2e;
    border-top: 2px solid #C49450;
    padding-top: 12px;
    margin-top: 5px;
}

.resume-label {
    color: #6C757D;
}

.resume-value {
    font-weight: 600;
    color: #1a1a2e;
}

/* Success amélioré */
.success-head {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    text-align: center;
    padding: 32px 24px;
    border-radius: 28px 28px 0 0;
    position: relative;
    overflow: hidden;
}

.success-head::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
    animation: pulse 3s ease infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 0.3; }
    50% { transform: scale(1.5); opacity: 0.1; }
}

.success-head i {
    font-size: 4rem;
    color: #28A745;
    margin-bottom: 12px;
    filter: drop-shadow(0 4px 8px rgba(0,0,0,0.2));
    animation: bounce 0.5s ease;
}

@keyframes bounce {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.2); }
}

.success-head h3 {
    color: white;
    font-size: 1.3rem;
    font-weight: 700;
    margin: 0;
}

.new-solde {
    font-size: 2rem;
    font-weight: 800;
    background: linear-gradient(135deg, #C49450, #D4A373);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    text-align: center;
    margin: 16px 0;
    letter-spacing: -0.5px;
}

/* Animation de chargement */
.btn-full.loading {
    opacity: 0.7;
    cursor: not-allowed;
    transform: none;
}

.btn-full.loading i {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}

/* Scrollbar personnalisée */
.dlg::-webkit-scrollbar {
    width: 8px;
}

.dlg::-webkit-scrollbar-track {
    background: #F1F3F5;
    border-radius: 10px;
}

.dlg::-webkit-scrollbar-thumb {
    background: #C49450;
    border-radius: 10px;
}

.dlg::-webkit-scrollbar-thumb:hover {
    background: #D4A373;
}
        /* Annulation */
        .cancel-icon-circle {
            width: 72px; height: 72px; border-radius: 50%;
            background: #FFF3E0; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 14px; font-size: 2rem; color: #FD7E14;
        }
        .ref-highlight {
            display: inline-block; background: #FDF6ED; color: #C49450;
            padding: 6px 16px; border-radius: 20px; font-weight: 700; font-size: 0.95rem;
            letter-spacing: 0.5px; border: 1px dashed rgba(196,148,80,0.3);
        }
        .contact-card {
            background: #F8F9FA; border: 1px solid #E9ECEF;
            border-radius: 12px; padding: 14px; margin-top: 14px; text-align: left;
        }
        .contact-card .cc-row { display: flex; align-items: center; gap: 10px; padding: 6px 0; font-size: 0.84rem; color: #555; }
        .contact-card .cc-row i { color: #C49450; width: 18px; text-align: center; }

        /* Modal deconnexion */
        .logout-modal .dlg-head h3 i { color: #FD7E14; }
        .logout-content { text-align: center; padding: 8px 4px 0; }
        .logout-icon {
            width: 72px; height: 72px; border-radius: 50%;
            background: #FFF3E0; color: #FD7E14;
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem; margin: 0 auto 12px;
        }
        .logout-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 16px; }
        .btn-outline {
            padding: 12px; border-radius: 10px; border: 2px solid #DEE2E6; background: #fff;
            color: #6C757D; font-weight: 600; cursor: pointer; font-family: 'Inter', sans-serif;
        }
        .btn-outline:hover { border-color: #C49450; color: #C49450; background: #FDF6ED; }

        /* Template visuel plus moderne pour modals retrait */
        .dlg {
            border: 1px solid #E9ECEF;
            border-radius: 26px;
            box-shadow: 0 24px 65px rgba(20, 20, 35, 0.28);
        }
        .dlg-head {
            background: linear-gradient(135deg, #151f3d 0%, #1f2a4f 100%);
            padding: 20px 26px;
        }
        .dlg-body { padding: 24px 26px 26px; }
        .f-input input { background: #FFFFFF; }
        .resume {
            background: linear-gradient(180deg, #FAFBFE 0%, #F8F9FA 100%);
            border: 1px solid #E6EAF1;
        }

        /* Error */
        .alert-err {
            padding: 11px 14px; border-radius: 10px; margin-bottom: 14px;
            background: #FEF2F2; color: #991B1B; border: 1px solid #FECACA;
            font-size: 0.83rem; display: flex; align-items: center; gap: 8px;
        }

        @media (max-width: 1000px) {
            .sidebar { width: 80px; }
            .sidebar-header span, .sidebar-header h2, .user-info, .nav-section-title, .nav-item span, .sidebar-footer { display: none; }
            .nav-item { justify-content: center; padding: 14px; }
            .nav-item i { font-size: 1.3rem; width: auto; }
            .user-profile { justify-content: center; }
            .main-content { margin-left: 80px; padding: 14px; }
        }
        @media (max-width: 768px) {
            .main-content { margin-left: 0; }
            .dlg { max-width: 95% !important; }
        }
    </style>
</head>
<body>

<!-- ===== SIDEBAR ===== -->
<aside class="sidebar">
    <div class="sidebar-header"><h2>KantyMoney</h2><span>Espace Client</span></div>
    <div class="user-profile">
        <div class="user-avatar"><%= initiales.toUpperCase() %></div>
        <div class="user-info"><h4><%= nom %></h4><p><%= numtelFormatte %></p></div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section">
            <div class="nav-section-title">Principal</div>
            <a href="<%= request.getContextPath() %>/client/dashboardclient.jsp" class="nav-item"><i class="fas fa-chart-pie"></i><span>Tableau de bord</span></a>
            <a href="<%= request.getContextPath() %>/historique" class="nav-item"><i class="fas fa-clock-rotate-left"></i><span>Historique</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Transactions</div>
            <a href="<%= request.getContextPath() %>/envoi" class="nav-item"><i class="fas fa-paper-plane"></i><span>Envoyer</span></a>
            <a href="<%= request.getContextPath() %>/retrait" class="nav-item active"><i class="fas fa-hand-holding-dollar"></i><span>Retirer</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Outils</div>
            <a href="<%= request.getContextPath() %>/client/releve.jsp" class="nav-item"><i class="fas fa-file-pdf"></i><span>Relevé PDF</span></a>
            <a href="<%= request.getContextPath() %>/frais-transactions" class="nav-item"><i class="fas fa-percent"></i><span>Frais de transaction</span></a>
        </div>
        <div class="nav-section">
            <div class="nav-section-title">Compte</div>
            <a href="<%= request.getContextPath() %>/parametres" class="nav-item"><i class="fas fa-user-gear"></i><span>Paramètres</span></a>
            <a href="#" class="nav-item logout" onclick="openLogoutModal('<%= request.getContextPath() %>/login?logout=true'); return false;"><i class="fas fa-sign-out-alt"></i><span>Déconnexion</span></a>
        </div>
    </nav>
  
</aside>

<!-- ===== MAIN ===== -->
<main class="main-content">
    <!-- Top Bar avec filtre intégré -->
    <div class="top-bar">
        <h1><i class="fas fa-hand-holding-dollar"></i> Retrait d'argent</h1>
        <div class="top-bar-right">
            <div class="top-bar-filter">
                <i class="fas fa-calendar-day"></i>
                <input type="date" id="filterDate" name="date" value="<%= fDate %>" onchange="applyDateFilter()" placeholder="Filtrer par date">
                <% if (fDate != null && !fDate.isEmpty()) { %>
                <button class="btn-reset-filter" onclick="resetFilter()" title="Réinitialiser le filtre">
                    <i class="fas fa-undo"></i> Réinitialiser
                </button>
                <% } %>
            </div>
            <button class="btn-or" id="btnNew"><i class="fas fa-plus-circle"></i> Nouveau retrait</button>
        </div>
    </div>

    <div class="card-table">
        <div class="card-table-head">
            <h3><i class="fas fa-list-ul"></i> Mes retraits</h3>
            <span style="font-size:0.76rem;color:#A8B2C1;background:rgba(255,255,255,0.08);padding:5px 12px;border-radius:20px;"><%= totalRetraits %> retrait<%= totalRetraits > 1 ? "s" : "" %></span>
        </div>
        <div class="tx-table-wrapper">
            <table class="tx-table">
                <thead>
                    <tr>
                        <th>ID Transaction</th>
                        <th>Montant</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
            <% if (retraits != null && !retraits.isEmpty()) {
                for (String[] r : retraits) {
                    int mt = 0;
                    try { mt = Integer.parseInt(r[3]); } catch(Exception ig){}
            %>
                <tr>
                    <td class="cell-ref"><%= r[1] %></td>
                    <td class="cell-montant"><%= MoneyFormat.format(mt) %> Ar</td>
                    <td class="cell-date"><%= r[4] %></td>
                    <td>
                        <button class="btn-icon cancel" onclick="openCancel('<%= r[1] %>')" title="Annuler ce retrait">
                            <i class="fas fa-ban"></i>
                        </button>
                    </td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="4">Aucun retrait pour le moment</td>
                </tr>
            <% } %>
                </tbody>
            </table>
        </div>
        <% if (totalPages > 1) { %>
        <div class="pag">
            <a href="<%= retraitPageBase %><%= pageQs %>page=<%= currentPage-1 %>" class="<%= currentPage<=1 ? "off" : "" %>"><i class="fas fa-chevron-left"></i></a>
            <% for (int i=1; i<=totalPages; i++) { %>
                <a href="<%= retraitPageBase %><%= pageQs %>page=<%= i %>" class="<%= i==currentPage ? "active" : "" %>"><%= i %></a>
            <% } %>
            <a href="<%= retraitPageBase %><%= pageQs %>page=<%= currentPage+1 %>" class="<%= currentPage>=totalPages ? "off" : "" %>"><i class="fas fa-chevron-right"></i></a>
        </div>
        <% } %>
    </div>
</main>

<!-- ===== MODAL ÉTAPE 1 ===== -->
<div class="overlay <%= showInputModal ? "on" : "" %>" id="mdlStep1">
    <div class="dlg" style="max-width:680px;">
        <div class="dlg-head">
            <h3><i class="fas fa-hand-holding-dollar"></i> Nouveau retrait</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body">
            <div class="steps">
                <div class="step on">1</div><div class="step-line"></div>
                <div class="step off">2</div><div class="step-line"></div>
                <div class="step off"><i class="fas fa-check"></i></div>
            </div>
            <p style="color:#6C757D;font-size:0.84rem;margin-bottom:16px;">Veuillez saisir le montant que vous souhaitez retirer.</p>
            <form action="<%= request.getContextPath() %>/retrait" method="post">
                <input type="hidden" name="action" value="calculer">
                <div class="f-group">
                    <label><i class="fas fa-coins"></i> Montant à retirer</label>
                    <div class="f-input"><input type="number" name="montant" placeholder="10 000" min="1" step="1" value="<%= montantStr != null ? montantStr : "" %>" required><span class="unit">Ar</span></div>
                </div>
                <button type="submit" class="btn-full"><i class="fas fa-arrow-right"></i> Continuer</button>
            </form>
        </div>
    </div>
</div>

<!-- ===== MODAL ÉTAPE 2 ===== -->
<div class="overlay <%= showConfirmModal ? "on" : "" %>" id="mdlStep2">
    <div class="dlg" style="max-width:680px;">
        <div class="dlg-head">
            <h3><i class="fas fa-check-circle"></i> Confirmer le retrait</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body">
            <div class="steps">
                <div class="step ok"><i class="fas fa-check"></i></div><div class="step-line ok"></div>
                <div class="step on">2</div><div class="step-line"></div>
                <div class="step off"><i class="fas fa-check"></i></div>
            </div>
            <% if (errorMsg != null) { %><div class="alert-err"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div><% } %>
            <div class="resume">
                <div class="resume-row"><span class="resume-label">Montant</span><span class="resume-value"><%= MoneyFormat.formatNullable(montantStr) %> Ar</span></div>
                <div class="resume-row"><span class="resume-label">Frais retrait</span><span class="resume-value"><%= fraisRetrait != null ? MoneyFormat.format(fraisRetrait) : "0" %> Ar</span></div>
                <div class="resume-row total"><span class="resume-label">Total à débiter</span><span class="resume-value"><%= totalDebiter != null ? MoneyFormat.format(totalDebiter) : "0" %> Ar</span></div>
            </div>
            <form action="<%= request.getContextPath() %>/retrait" method="post" id="frmConfirm">
                <input type="hidden" name="action" value="confirmer">
                <input type="hidden" name="montant" value="<%= montantStr != null ? montantStr : "" %>">
                <div class="f-group">
                    <label><i class="fas fa-lock"></i> Code secret (PIN)</label>
                    <div class="f-input"><input type="password" id="pin" name="code_secret" placeholder="••••" pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required><button type="button" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;border:none;color:#6C757D;cursor:pointer;" onclick="togglePin()"><i class="far fa-eye" id="pinIcon"></i></button></div>
                </div>
                <button type="submit" class="btn-full"><i class="fas fa-check-circle"></i> Confirmer le retrait</button>
            </form>
            <button class="btn-ghost" onclick="goBack()"><i class="fas fa-arrow-left"></i> Modifier le montant</button>
        </div>
    </div>
</div>

<!-- ===== MODAL SUCCÈS ===== -->
<div class="overlay <%= showSuccessModal ? "on" : "" %>" id="mdlSuccess">
    <div class="dlg" style="max-width:680px;">
        <div class="success-head">
            <i class="fas fa-check-circle"></i>
            <h3>Retrait effectué !</h3>
        </div>
        <div class="dlg-body" style="text-align:center;">
            <div class="resume" style="text-align:left;">
                <div class="resume-row"><span class="resume-label">Montant retiré</span><span class="resume-value" style="color:#DC3545;">-<%= successMontant != null ? MoneyFormat.format(successMontant) : "0" %> Ar</span></div>
                <div class="resume-row"><span class="resume-label">Frais</span><span class="resume-value"><%= successFraisRetrait != null ? MoneyFormat.format(successFraisRetrait) : "0" %> Ar</span></div>
                <div class="resume-row total"><span class="resume-label">Total débité</span><span class="resume-value"><%= successTotalDebite != null ? MoneyFormat.format(successTotalDebite) : "0" %> Ar</span></div>
            </div>
            <p style="color:#6C757D;font-size:0.85rem;">Nouveau solde</p>
            <div class="new-solde"><%= successNouveauSolde != null ? MoneyFormat.format(successNouveauSolde) : "0" %> Ar</div>
            <button class="btn-full green" onclick="closeAll()" style="margin-top:12px;"><i class="fas fa-check"></i> OK</button>
        </div>
    </div>
</div>

<!-- ===== MODAL ANNULATION ===== -->
<div class="overlay" id="mdlCancel">
    <div class="dlg" style="max-width:680px;">
        <div class="dlg-head">
            <h3><i class="fas fa-ban" style="color:#FD7E14;"></i> Annuler un retrait</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body" style="text-align:center;">
            <div class="cancel-icon-circle"><i class="fas fa-headset"></i></div>
            <h4 style="font-weight:700;color:#1a1a2e;margin-bottom:6px;">Service Client KantyMoney</h4>
            <p style="color:#6C757D;font-size:0.85rem;margin-bottom:14px;">
                Pour annuler votre retrait, veuillez contacter notre service client en communiquant la référence ci-dessous :
            </p>
            <div class="ref-highlight" id="cancelRef">#REF</div>
            <div class="contact-card">
                <div class="cc-row"><i class="fas fa-phone"></i> <strong>032 44 321 67</strong></div>
                <div class="cc-row"><i class="fas fa-envelope"></i> support@kantymoney.mg</div>
                <div class="cc-row"><i class="fas fa-clock"></i> Lundi - Dimanche · 7h - 21h</div>
            </div>
            <button class="btn-full" onclick="closeAll()" style="margin-top:16px;"><i class="fas fa-check"></i> J'ai compris</button>
        </div>
    </div>
</div>

<!-- ===== MODAL DECONNEXION ===== -->
<div class="overlay logout-modal" id="mdlLogout">
    <div class="dlg" style="max-width:520px;">
        <div class="dlg-head">
            <h3><i class="fas fa-right-from-bracket"></i> Déconnexion</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body">
            <div class="logout-content">
                <div class="logout-icon"><i class="fas fa-power-off"></i></div>
                <h4 style="color:#1a1a2e;margin-bottom:6px;">Voulez-vous vous déconnecter ?</h4>
                <p style="color:#6C757D;font-size:0.88rem;">Votre session actuelle sera fermée.</p>
            </div>
            <div class="logout-actions">
                <button class="btn-outline" onclick="closeAll()">Annuler</button>
                <button class="btn-full" onclick="confirmLogout()">Se déconnecter</button>
            </div>
        </div>
    </div>
</div>

<script>
function togglePin(){
    const e=document.getElementById("pin"), d=document.getElementById("pinIcon");
    e.type=e.type==="password"?"text":"password";
    d.className=e.type==="password"?"far fa-eye":"far fa-eye-slash";
}
document.getElementById("pin")?.addEventListener("keypress",e=>{if(e.key<"0"||e.key>"9")e.preventDefault();});
document.getElementById("frmConfirm")?.addEventListener("submit",function(e){
    const p=document.getElementById("pin").value;
    if(!/^[0-9]{4}$/.test(p)){e.preventDefault();alert("Code secret à 4 chiffres requis");}
});

function openModal(id){document.getElementById(id).classList.add("on");document.body.style.overflow="hidden";}
function closeAll(){
    ["mdlStep1","mdlStep2","mdlSuccess","mdlCancel"].forEach(id=>{
        const m=document.getElementById(id); if(m)m.classList.remove("on");
    });
    document.body.style.overflow="";
}
function goBack(){document.getElementById("mdlStep2").classList.remove("on");openModal("mdlStep1");}

document.querySelectorAll(".overlay").forEach(o=>o.addEventListener("click",function(e){if(e.target===this)closeAll();}));
document.addEventListener("keydown",e=>{if(e.key==="Escape")closeAll();});

document.getElementById("btnNew")?.addEventListener("click",()=>openModal("mdlStep1"));

function openCancel(ref){
    document.getElementById("cancelRef").textContent="#"+ref;
    openModal("mdlCancel");
}

// Filtre automatique par date
function applyDateFilter() {
    const dateVal = document.getElementById('filterDate').value;
    const baseUrl = '<%= request.getContextPath() %>/retrait';
    if (dateVal) {
        window.location.href = baseUrl + '?date=' + encodeURIComponent(dateVal);
    } else {
        window.location.href = baseUrl;
    }
}

// Réinitialiser le filtre
function resetFilter() {
    window.location.href = '<%= request.getContextPath() %>/retrait';
}

let logoutTarget = null;
function openLogoutModal(url){
    logoutTarget = url;
    openModal("mdlLogout");
}
function confirmLogout(){
    if (logoutTarget) window.location.href = logoutTarget;
}
</script>
</body>
</html>