<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.steeven.dao.ClientDAO" %>
<%@ page import="java.util.List" %>
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
    
    if (!clients.isEmpty()) {
        String[] client = clients.get(0);
        nom = client[1];
        String[] parts = nom.split(" ");
        for (String part : parts) {
            if (!part.isEmpty() && initiales.length() < 2) initiales += part.charAt(0);
        }
    }
    if (numtel != null && numtel.length() == 10) {
        numtelFormatte = numtel.substring(0, 3) + " " + numtel.substring(3, 5) + " " + numtel.substring(5, 8) + " " + numtel.substring(8);
    }

    java.util.List<String[]> allTxs = (java.util.List<String[]>) request.getAttribute("transactions");
    int totalTxs = (allTxs != null) ? allTxs.size() : 0;
    int pageSize = 8;
    int totalPages = (int) Math.ceil((double) totalTxs / pageSize);
    int currentPage = 1;
    try { currentPage = Integer.parseInt(request.getParameter("page")); } catch(Exception e) {}
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    
    int start = (currentPage - 1) * pageSize;
    int end = Math.min(start + pageSize, totalTxs);
    java.util.List<String[]> txs = (allTxs != null && !allTxs.isEmpty()) ? allTxs.subList(start, end) : new java.util.ArrayList<>();

    boolean showSuccessModal = Boolean.TRUE.equals(request.getAttribute("showSuccessModal"));
    boolean showCreateModal = !showSuccessModal && (Boolean.TRUE.equals(request.getAttribute("showCreateModal")) || request.getAttribute("recepteurTrouve") != null);
    boolean recepteurTrouve = request.getAttribute("recepteurTrouve") != null;
    boolean showStep1Modal = showCreateModal && !recepteurTrouve;
    boolean showStep2Modal = showCreateModal && recepteurTrouve;
    String errorMsg = (String) request.getAttribute("error");
    String successMsg = (String) request.getAttribute("success");
    String infoMsg = (String) request.getAttribute("info");
    
    String fDate = request.getAttribute("filterDate") != null ? (String) request.getAttribute("filterDate") : "";
    String listDateQs = "";
    try {
        if (fDate != null && !fDate.isEmpty()) {
            listDateQs += "date=" + java.net.URLEncoder.encode(fDate, "UTF-8");
        }
    } catch (java.io.UnsupportedEncodingException e) { /* ignore */ }
    String envoiPageBase = request.getContextPath() + "/envoi";
    String pageQs = listDateQs.isEmpty() ? "?" : "?" + listDateQs + "&";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KantyMoney • Envoyer de l'argent</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700;14..32,800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../style/nav-client.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #faf5f0 100%);
            height: 100vh;
            display: flex;
            overflow: hidden;
            color: #212529;
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

        /* Top bar */
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

        /* ===== TABLEAU LISIBLE ===== */
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
        .tx-table-wrapper { overflow-x: auto; }
        .tx-table { width: 100%; border-collapse: collapse; min-width: 760px; }
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
        .badge-envoi { background: #EFF6FF; color: #0D6EFD; border-radius: 20px; padding: 5px 11px; font-size: 0.8rem; font-weight: 600; }

        .cell-ref { font-weight: 700; color: #C49450; letter-spacing: 0.3px; }
        .cell-tel { font-weight: 500; color: #1a1a2e; }
        .cell-montant { text-align: right; font-weight: 700; color: #DC3545; }
        .cell-date { text-align: right; color: #6C757D; font-size: 0.8rem; }
        .cell-raison { color: #555; font-size: 0.82rem; }
        .cell-action { display: flex; gap: 6px; justify-content: center; }

        .btn-icon {
            width: 34px; height: 34px; border-radius: 8px;
            border: 1.5px solid #DEE2E6; background: white;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: all 0.2s; font-size: 0.8rem;
        }
        .btn-icon.edit { color: #0D6EFD; }
        .btn-icon.edit:hover { background: #EFF6FF; border-color: #0D6EFD; color: #0D6EFD; }
        .btn-icon.cancel { color: #FD7E14; }
        .btn-icon.cancel:hover { background: #FFF3E0; border-color: #FD7E14; color: #FD7E14; }

        /* Pagination */
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

       /* ===== MODAUX RESPONSIFS ===== */
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
    transition: all 0.3s ease;
    padding: 16px;
}

.overlay.on {
    opacity: 1;
    visibility: visible;
}

/* Conteneur modal - responsive */
.dlg {
    background: white;
    border-radius: 28px;
    max-height: calc(100vh - 32px);
    overflow-y: auto;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.3);
    transform: scale(0.95) translateY(10px);
    transition: all 0.3s cubic-bezier(0.34, 1.2, 0.64, 1);
    width: 100%;
    max-width: 680px;
    margin: auto;
}

/* Version large pour étape 2 */
.dlg.dlg-wide {
    max-width: 1000px;
}

.overlay.on .dlg {
    transform: scale(1) translateY(0);
}

/* Header modal */
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
    font-size: clamp(1rem, 4vw, 1.1rem);
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
    flex-shrink: 0;
}

.dlg-close:hover {
    background: rgba(220, 53, 69, 0.2);
    color: #F4A2A4;
    transform: scale(1.05);
}

.dlg-body {
    padding: 24px;
}

/* ===== STEPS RESPONSIVE ===== */
.steps {
    display: flex;
    justify-content: center;
    gap: 8px;
    margin-bottom: 24px;
    align-items: center;
    flex-wrap: wrap;
}

.step {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.85rem;
    font-weight: 700;
    transition: all 0.2s;
}

.step.on {
    background: #C49450;
    color: white;
    box-shadow: 0 4px 10px rgba(196, 148, 80, 0.3);
}

.step.ok {
    background: #28A745;
    color: white;
}

.step.off {
    background: #E9ECEF;
    color: #6C757D;
}

.step-line {
    width: 40px;
    height: 2px;
    background: #E9ECEF;
}

.step-line.ok {
    background: #28A745;
}

/* ===== FORMULAIRES ===== */
.f-group {
    margin-bottom: 16px;
}

.f-group label {
    display: block;
    font-size: 0.85rem;
    font-weight: 600;
    color: #1a1a2e;
    margin-bottom: 6px;
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

.f-input input,
.f-input select,
.f-input textarea {
    width: 100%;
    padding: 12px 14px;
    background: #F8F9FA;
    border: 2px solid #DEE2E6;
    border-radius: 12px;
    font-size: 0.9rem;
    font-family: inherit;
    outline: none;
    transition: all 0.25s;
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
    font-weight: 600;
    font-size: 0.85rem;
}

/* Checkbox card */
.chk-card {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 14px;
    background: #FDF6ED;
    border-radius: 12px;
    margin-bottom: 20px;
    border: 1px solid rgba(196, 148, 80, 0.2);
    transition: all 0.2s;
}

.chk-card:hover {
    background: #FFF8F0;
    border-color: rgba(196, 148, 80, 0.4);
}

.chk-card input {
    width: 18px;
    height: 18px;
    accent-color: #C49450;
    margin-top: 2px;
    cursor: pointer;
    flex-shrink: 0;
}

.chk-card label {
    cursor: pointer;
    font-size: 0.85rem;
    line-height: 1.4;
}

.chk-card label strong {
    color: #C49450;
    display: block;
    margin-bottom: 4px;
}

/* Bouton principal */
.btn-full {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #C49450, #D4A373);
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 0.95rem;
    font-weight: 600;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    transition: all 0.3s;
    font-family: inherit;
    box-shadow: 0 4px 15px rgba(196, 148, 80, 0.25);
}

.btn-full:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(196, 148, 80, 0.35);
}

.btn-full:active {
    transform: translateY(0);
}

.form-alert {
    border-radius: 12px;
    padding: 11px 13px;
    margin-bottom: 14px;
    font-size: 0.84rem;
    font-weight: 500;
    display: flex;
    align-items: flex-start;
    gap: 8px;
    line-height: 1.35;
}

.form-alert.error {
    background: #FFF2F2;
    border: 1px solid #F3C2C7;
    color: #842029;
}

.form-alert.success {
    background: #EDF9F0;
    border: 1px solid #BFE5C8;
    color: #0F5132;
}

.form-alert.info {
    background: #F1F6FF;
    border: 1px solid #C7DBFF;
    color: #1C4FA1;
}

/* ===== ÉTAPE 2 - LAYOUT FLEXIBLE ===== */
.etape2-row {
    display: flex;
    flex-wrap: wrap;
    min-height: auto;
}

.etape2-left {
    flex: 1;
    min-width: 280px;
    background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%);
    padding: 28px 24px;
    display: flex;
    flex-direction: column;
}

.etape2-left .link-back {
    color: #C49450;
    text-decoration: none;
    font-size: 0.85rem;
    font-weight: 500;
    margin-bottom: 20px;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    width: fit-content;
    transition: all 0.2s;
}

.etape2-left .link-back:hover {
    color: #D4A373;
    transform: translateX(-3px);
}

.etape2-right {
    flex: 1.2;
    min-width: 300px;
    padding: 28px 24px;
    display: flex;
    flex-direction: column;
    background: white;
}

/* ===== CARTE PROFIL COMPLÈTE (VERSION 1) ===== */
.profile-card {
    background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255,255,255,0.2);
    border-radius: 20px;
    padding: 24px;
    text-align: center;
    margin-top: auto;
    transition: all 0.3s ease;
}

.profile-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 35px rgba(0,0,0,0.2);
    border-color: rgba(196,148,80,0.5);
}

.profile-avatar {
    position: relative;
    width: 100px;
    height: 100px;
    margin: 0 auto 16px;
}

.profile-avatar-circle {
    width: 100px;
    height: 100px;
    background: linear-gradient(135deg, #C49450, #D4A373);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto;
    box-shadow: 0 10px 25px rgba(196,148,80,0.3);
    border: 3px solid rgba(255,255,255,0.3);
}

.profile-avatar-circle i {
    font-size: 3rem;
    color: white;
}

.profile-avatar-initials {
    width: 100px;
    height: 100px;
    background: linear-gradient(135deg, #C49450, #D4A373);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto;
    box-shadow: 0 10px 25px rgba(196,148,80,0.3);
    border: 3px solid rgba(255,255,255,0.3);
}

.profile-avatar-initials span {
    font-size: 2.5rem;
    font-weight: 700;
    color: white;
    letter-spacing: 2px;
}

.profile-badge {
    position: absolute;
    bottom: 5px;
    right: 5px;
    background: #28A745;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid white;
}

.profile-badge i {
    font-size: 0.7rem;
    color: white;
}

.profile-name {
    font-size: 1.3rem;
    font-weight: 700;
    color: white;
    margin: 16px 0 8px;
    letter-spacing: -0.3px;
}

.profile-role {
    display: inline-block;
    background: rgba(196,148,80,0.2);
    color: #C49450;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.7rem;
    font-weight: 600;
    margin-bottom: 16px;
}

.profile-info {
    text-align: left;
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid rgba(255,255,255,0.1);
}

.profile-info-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 0;
    color: #A8B2C1;
    font-size: 0.85rem;
}

.profile-info-item i {
    width: 24px;
    color: #C49450;
    font-size: 1rem;
    text-align: center;
}

.profile-info-item strong {
    color: white;
    font-weight: 600;
    margin-right: 5px;
}

.profile-info-item span {
    color: #A8B2C1;
    word-break: break-all;
}

/* Résumé transaction */
.resume {
    background: #F8F9FA;
    border-radius: 16px;
    padding: 16px;
    margin-bottom: 20px;
    border: 1px solid #E9ECEF;
}

.resume-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid #DEE2E6;
    font-size: 0.85rem;
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

/* ===== MODAL SUCCÈS ===== */
.success-head {
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
    text-align: center;
    padding: 32px 24px;
    border-radius: 28px 28px 0 0;
}

.success-head i {
    font-size: 3.5rem;
    color: #28A745;
    margin-bottom: 10px;
}

.success-head h3 {
    color: white;
    font-size: 1.2rem;
    font-weight: 700;
    margin: 0;
}

.grid-2 {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 12px;
    margin-top: 16px;
}

.grid-2 .item {
    background: #F8F9FA;
    border: 1px solid #E9ECEF;
    border-radius: 12px;
    padding: 12px 14px;
}

.grid-2 .item .k {
    display: block;
    color: #6C757D;
    font-size: 0.7rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.grid-2 .item .v {
    font-weight: 600;
    color: #1a1a2e;
    font-size: 0.9rem;
    word-break: break-word;
}

.grid-2 .item.full {
    grid-column: 1 / -1;
}

/* ===== ANNULATION ===== */
.cancel-icon-circle {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    background: #FFF3E0;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 16px;
    font-size: 2rem;
    color: #FD7E14;
}

.ref-highlight {
    display: inline-block;
    background: #FDF6ED;
    color: #C49450;
    padding: 8px 18px;
    border-radius: 24px;
    font-weight: 700;
    font-size: 1rem;
    letter-spacing: 0.5px;
    border: 1px dashed rgba(196, 148, 80, 0.4);
}

.contact-card {
    background: #F8F9FA;
    border: 1px solid #E9ECEF;
    border-radius: 14px;
    padding: 16px;
    margin-top: 16px;
    text-align: left;
}

.contact-card .cc-row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 8px 0;
    font-size: 0.85rem;
    color: #555;
}

.contact-card .cc-row i {
    color: #C49450;
    width: 20px;
    text-align: center;
}

/* ===== RESPONSIVE DESIGN ===== */
@media (max-width: 768px) {
    .overlay {
        padding: 12px;
        align-items: flex-start;
        padding-top: 20px;
    }

    .dlg {
        max-height: calc(100vh - 40px);
        border-radius: 20px;
    }

    .dlg-head {
        padding: 16px 20px;
    }

    .dlg-body {
        padding: 20px;
    }

    /* Étape 2 en colonne sur mobile */
    .etape2-row {
        flex-direction: column;
    }

    .etape2-left {
        border-radius: 20px 20px 0 0;
        padding: 20px;
    }

    .etape2-right {
        padding: 20px;
    }

    .etape2-left .steps {
        margin-bottom: 16px;
    }

    /* Carte profil responsive */
    .profile-card {
        padding: 20px;
        margin-top: 16px;
    }
    
    .profile-avatar {
        width: 80px;
        height: 80px;
    }
    
    .profile-avatar-circle,
    .profile-avatar-initials {
        width: 80px;
        height: 80px;
    }
    
    .profile-avatar-circle i {
        font-size: 2.5rem;
    }
    
    .profile-avatar-initials span {
        font-size: 2rem;
    }
    
    .profile-badge {
        width: 24px;
        height: 24px;
        bottom: 3px;
        right: 3px;
    }
    
    .profile-name {
        font-size: 1.1rem;
    }
    
    .profile-info-item {
        font-size: 0.75rem;
        padding: 8px 0;
    }

    /* Steps responsives */
    .step {
        width: 28px;
        height: 28px;
        font-size: 0.75rem;
    }

    .step-line {
        width: 30px;
    }

    /* Grille succès */
    .grid-2 {
        grid-template-columns: 1fr;
        gap: 10px;
    }

    .grid-2 .item.full {
        grid-column: auto;
    }

    /* Ajustements formulaires */
    .f-input input {
        font-size: 16px;
    }

    .btn-full {
        padding: 12px;
        font-size: 0.9rem;
    }
}

@media (max-width: 480px) {
    .overlay {
        padding: 8px;
    }

    .dlg-head h3 {
        font-size: 0.95rem;
    }

    .dlg-head h3 i {
        font-size: 1rem;
    }

    .dlg-close {
        width: 32px;
        height: 32px;
    }

    .step {
        width: 26px;
        height: 26px;
        font-size: 0.7rem;
    }

    .step-line {
        width: 20px;
    }

    .resume-row {
        font-size: 0.8rem;
        padding: 8px 0;
    }

    .resume-row.total {
        font-size: 0.9rem;
    }

    .success-head {
        padding: 24px 20px;
    }

    .success-head i {
        font-size: 2.5rem;
    }

    /* Carte profil très petit écran */
    .profile-card {
        padding: 16px;
    }
    
    .profile-avatar {
        width: 70px;
        height: 70px;
    }
    
    .profile-avatar-circle,
    .profile-avatar-initials {
        width: 70px;
        height: 70px;
    }
}

/* Support grand écran */
@media (min-width: 1400px) {
    .dlg {
        max-width: 750px;
    }

    .dlg.dlg-wide {
        max-width: 1100px;
    }

    .dlg-body {
        padding: 28px 32px;
    }

    .etape2-left,
    .etape2-right {
        padding: 32px;
    }
}

/* Animation d'entrée améliorée */
@keyframes modalSlideIn {
    from {
        opacity: 0;
        transform: scale(0.95) translateY(20px);
    }
    to {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

.overlay.on .dlg {
    animation: modalSlideIn 0.3s cubic-bezier(0.34, 1.2, 0.64, 1);
}

/* Scrollbar personnalisée */
.dlg::-webkit-scrollbar {
    width: 8px;
}

.dlg::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 10px;
}

.dlg::-webkit-scrollbar-thumb {
    background: #C49450;
    border-radius: 10px;
}

.dlg::-webkit-scrollbar-thumb:hover {
    background: #D4A373;
}
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

        /* Template visuel plus moderne pour modals envoi */
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
        .etape2-left {
            background: linear-gradient(180deg, #151f3d 0%, #1f2a4f 100%);
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
            .etape2-row { flex-direction: column; }
            .grid-2 { grid-template-columns: 1fr; }
            .row-head, .row-tx { grid-template-columns: 80px 1fr 90px 100px 1fr 70px; font-size: 0.76rem; }
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
            <a href="<%= request.getContextPath() %>/envoi" class="nav-item active"><i class="fas fa-paper-plane"></i><span>Envoyer</span></a>
            <a href="<%= request.getContextPath() %>/retrait" class="nav-item"><i class="fas fa-hand-holding-dollar"></i><span>Retirer</span></a>
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
        <h1><i class="fas fa-paper-plane"></i> Envoyer de l'argent</h1>
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
            <button class="btn-or" id="btnNew"><i class="fas fa-plus-circle"></i> Nouvel envoi</button>
        </div>
    </div>

    <div class="card-table">
        <div class="card-table-head">
            <h3><i class="fas fa-list-ul"></i> Mes envois</h3>
            <span style="font-size:0.76rem;color:#A8B2C1;background:rgba(255,255,255,0.08);padding:5px 12px;border-radius:20px;"><%= totalTxs %> envoi<%= totalTxs > 1 ? "s" : "" %></span>
        </div>
        <div class="tx-table-wrapper">
            <table class="tx-table">
                <thead>
                    <tr>
                        <th>ID Transaction</th>
                        <th>Numero du recepteur</th>
                        <th>Raison</th>
                        <th>Montant</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
            <% if (txs != null && !txs.isEmpty()) {
                for (String[] t : txs) {
                    String idEnv = t[0];
                    String ref = t[1];
                    String numR = t[3];
                    String nomR = t[3] != null ? t[3] : "";
                    int mt = 0;
                    try { mt = Integer.parseInt(t[4]); } catch(Exception ig){}
                    String dt = t[5];
                    String raison = t[7] != null && !t[7].trim().isEmpty() ? t[7] : "-";
                    String telF = numR;
                    if (numR != null && numR.length() == 10) {
                        telF = numR.substring(0,3)+" "+numR.substring(3,5)+" "+numR.substring(5,8)+" "+numR.substring(8);
                    }
                    String benef = telF;
            %>
                <tr>
                    <td class="cell-ref"><%= ref %></td>
                    <td><%= benef %></td>
                    <td><%= raison %></td>
                    <td class="cell-montant"><%= MoneyFormat.format(mt) %> Ar</td>
                    <td class="cell-date"><%= dt %></td>
                    <td>
                        <button class="btn-icon cancel" onclick="openCancel('<%= ref %>')" title="Annuler cet envoi">
                            <i class="fas fa-ban"></i>
                        </button>
                    </td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="6">Aucun envoi pour le moment</td>
                </tr>
            <% } %>
                </tbody>
            </table>
        </div>
        <% if (totalPages > 1) { %>
        <div class="pag">
            <a href="<%= envoiPageBase %><%= pageQs %>page=<%= currentPage-1 %>" class="<%= currentPage<=1 ? "off" : "" %>"><i class="fas fa-chevron-left"></i></a>
            <% for (int i=1; i<=totalPages; i++) { %>
                <a href="<%= envoiPageBase %><%= pageQs %>page=<%= i %>" class="<%= i==currentPage ? "active" : "" %>"><%= i %></a>
            <% } %>
            <a href="<%= envoiPageBase %><%= pageQs %>page=<%= currentPage+1 %>" class="<%= currentPage>=totalPages ? "off" : "" %>"><i class="fas fa-chevron-right"></i></a>
        </div>
        <% } %>
    </div>
</main>

<!-- ===== MODAL ÉTAPE 1 ===== -->
<div class="overlay <%= showStep1Modal ? "on" : "" %>" id="mdlStep1">
    <div class="dlg" style="max-width:680px;">
        <div class="dlg-head">
            <h3><i class="fas fa-paper-plane"></i> Nouvel envoi</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body">
            <div class="steps">
                <div class="step on">1</div><div class="step-line"></div>
                <div class="step off">2</div><div class="step-line"></div>
                <div class="step off"><i class="fas fa-check"></i></div>
            </div>
            <% if (errorMsg != null) { %>
                <div class="form-alert error"><i class="fas fa-circle-exclamation"></i><span><%= errorMsg %></span></div>
            <% } else if (successMsg != null) { %>
                <div class="form-alert success"><i class="fas fa-circle-check"></i><span><%= successMsg %></span></div>
            <% } else if (infoMsg != null) { %>
                <div class="form-alert info"><i class="fas fa-circle-info"></i><span><%= infoMsg %></span></div>
            <% } %>
            <form action="<%= request.getContextPath() %>/envoi" method="post">
                <input type="hidden" name="action" value="rechercher">
                <div class="f-group">
                    <label><i class="fas fa-mobile-alt"></i> Numéro du bénéficiaire</label>
                    <div class="f-input"><input type="tel" name="recepteur" placeholder="034 12 345 67" pattern="[0-9]{10}" maxlength="10" value="<%= request.getAttribute("recepteur") != null ? request.getAttribute("recepteur") : "" %>" required></div>
                </div>
                <div class="f-group">
                    <label><i class="fas fa-coins"></i> Montant à envoyer</label>
                    <div class="f-input"><input type="number" name="montant" placeholder="10 000" min="1" step="1" value="<%= request.getAttribute("montant") != null ? request.getAttribute("montant") : "" %>" required><span class="unit">Ar</span></div>
                </div>
                <div class="chk-card">
                    <input type="checkbox" id="chk1" name="payerFraisRetrait" <%= Boolean.TRUE.equals(request.getAttribute("payerFraisRetraitSelected")) ? "checked" : "" %>>
                    <label for="chk1"><strong>Payer les frais de retrait</strong><small style="display:block;color:#6C757D;margin-top:2px;">Ajoutés à votre débit et crédités au bénéficiaire</small></label>
                </div>
                <button type="submit" class="btn-full"><i class="fas fa-search"></i> Rechercher le bénéficiaire</button>
            </form>
        </div>
    </div>
</div>

<!-- ===== MODAL ÉTAPE 2 AVEC CARTE PROFIL VERSION 1 ===== -->
<% if (showStep2Modal) {
    String rNom = (String) request.getAttribute("recepteurNom");
    String rEmail = (String) request.getAttribute("recepteurEmail");
    String rNum = (String) request.getAttribute("recepteurNum");
    String mStr = (String) request.getAttribute("montant");
    Integer fEnvoi = (Integer) request.getAttribute("fraisEnvoiPreview");
    Integer fRetrait = (Integer) request.getAttribute("fraisRetraitPreview");
    Integer totalDeb = (Integer) request.getAttribute("totalDebiterPreview");
    Integer totalCred = (Integer) request.getAttribute("totalCrediterPreview");
    String[] noms = rNom.split("\\s+");
    String initR = noms.length >= 2 ? noms[0].substring(0,1)+noms[1].substring(0,1) : rNom.substring(0, Math.min(2, rNom.length()));
%>
<div class="overlay on" id="mdlStep2">
    <div class="dlg dlg-wide">
        <div class="dlg-head">
            <h3><i class="fas fa-paper-plane"></i> Confirmer l'envoi</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body" style="padding: 0;">
            <div class="etape2-row">
                <div class="etape2-left">
                    <div class="steps">
                        <div class="step ok"><i class="fas fa-check"></i></div><div class="step-line ok"></div>
                        <div class="step on">2</div><div class="step-line"></div>
                        <div class="step off"><i class="fas fa-check"></i></div>
                    </div>
                    <a href="#" onclick="goBackToStep1(); return false;" class="link-back"><i class="fas fa-arrow-left"></i> Modifier</a>
                    
                    <!-- CARTE PROFIL VERSION 1 -->
                    <div class="profile-card">
                        <div class="profile-avatar">
                            <div class="profile-avatar-initials">
                                <span><%= initR.toUpperCase() %></span>
                            </div>
                            <div class="profile-badge">
                                <i class="fas fa-check"></i>
                            </div>
                        </div>
                        <div class="profile-name"><%= rNom %></div>
                        <div class="profile-role">Bénéficiaire vérifié</div>
                        <div class="profile-info">
                            <div class="profile-info-item">
                                <i class="fas fa-mobile-alt"></i>
                                <div><strong>Téléphone :</strong> <span><%= rNum %></span></div>
                            </div>
                            <div class="profile-info-item">
                                <i class="fas fa-envelope"></i>
                                <div><strong>Email :</strong> <span><%= rEmail != null ? rEmail : "Non disponible" %></span></div>
                            </div>
                            <div class="profile-info-item">
                                <i class="fas fa-shield-alt"></i>
                                <div><strong>Statut :</strong> <span>Compte vérifié</span></div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="etape2-right">
                    <% if (errorMsg != null) { %>
                        <div class="form-alert error"><i class="fas fa-circle-exclamation"></i><span><%= errorMsg %></span></div>
                    <% } %>
                    <div class="resume">
                        <div class="resume-row"><span class="resume-label">Montant</span><span class="resume-value"><%= MoneyFormat.formatNullable(mStr) %> Ar</span></div>
                        <div class="resume-row"><span class="resume-label">Frais envoi</span><span class="resume-value"><%= fEnvoi!=null?MoneyFormat.format(fEnvoi)+" Ar":"-" %></span></div>
                        <div class="resume-row"><span class="resume-label">Frais retrait</span><span class="resume-value"><%= Boolean.TRUE.equals(request.getAttribute("payerFraisRetraitSelected"))&&fRetrait!=null?MoneyFormat.format(fRetrait)+" Ar":"Non" %></span></div>
                        <div class="resume-row"><span class="resume-label">Crédité</span><span class="resume-value"><%= totalCred!=null?MoneyFormat.format(totalCred)+" Ar":"-" %></span></div>
                        <div class="resume-row total"><span class="resume-label">Total débité</span><span class="resume-value"><%= totalDeb!=null?MoneyFormat.format(totalDeb)+" Ar":"-" %></span></div>
                    </div>
                    <form action="<%= request.getContextPath() %>/envoi" method="POST" id="frmConfirm">
                        <input type="hidden" name="action" value="confirmer">
                        <input type="hidden" name="recepteur" value="<%= rNum %>">
                        <input type="hidden" name="montant" value="<%= mStr %>">
                        <% if(Boolean.TRUE.equals(request.getAttribute("payerFraisRetraitSelected"))){ %><input type="hidden" name="payerFraisRetrait" value="on"><% } %>
                        <div class="f-group">
                            <label><i class="fas fa-pen"></i> Raison (optionnel)</label>
                            <div class="f-input"><input type="text" name="raison" maxlength="255" placeholder="Ex: Aide familiale" value="<%= request.getAttribute("raison")!=null?request.getAttribute("raison"):"" %>"></div>
                        </div>
                        <div class="f-group">
                            <label><i class="fas fa-lock"></i> Code secret (PIN)</label>
                            <div class="f-input">
                                <input type="password" id="pin" name="code_secret" placeholder="••••" pattern="[0-9]{4}" maxlength="4" inputmode="numeric" required>
                                <button type="button" style="position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;border:none;color:#6C757D;cursor:pointer;" onclick="togglePin()">
                                    <i class="far fa-eye" id="pinIcon"></i>
                                </button>
                            </div>
                        </div>
                        <button type="submit" class="btn-full"><i class="fas fa-check-circle"></i> Confirmer l'envoi</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<% } %>

<!-- ===== MODAL SUCCÈS ===== -->
<div class="overlay <%= showSuccessModal ? "on" : "" %>" id="mdlSuccess">
    <div class="dlg" style="max-width:680px;">
        <div class="success-head">
            <i class="fas fa-check-circle"></i>
            <h3>Envoi réussi !</h3>
        </div>
        <div class="dlg-body">
            <p style="text-align:center;color:#6C757D;margin-bottom:12px;">La transaction a été effectuée avec succès.</p>
            <div class="grid-2">
                <div class="item"><span class="k">Récepteur</span><span class="v"><%= request.getAttribute("successRecepteur") %></span></div>
                <div class="item"><span class="k">Raison</span><span class="v"><%= request.getAttribute("successRaison")!=null?request.getAttribute("successRaison"):"-" %></span></div>
                <div class="item"><span class="k">Montant</span><span class="v"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("successMontant"))) %> Ar</span></div>
                <div class="item"><span class="k">Frais envoi</span><span class="v"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("successFraisEnvoi"))) %> Ar</span></div>
                <div class="item"><span class="k">Frais retrait</span><span class="v"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("successFraisRetrait"))) %> Ar</span></div>
                <div class="item"><span class="k">Reçu</span><span class="v"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("successMontantRecu"))) %> Ar</span></div>
                <div class="item full"><span class="k">Total débité</span><span class="v" style="color:#DC3545;"><%= MoneyFormat.formatNullable(String.valueOf(request.getAttribute("successTotalDebite"))) %> Ar</span></div>
            </div>
            <button class="btn-full" onclick="closeAll()" style="margin-top:14px;"><i class="fas fa-check"></i> OK</button>
        </div>
    </div>
</div>


<!-- ===== MODAL ANNULATION (remplace suppression) ===== -->
<div class="overlay" id="mdlCancel">
    <div class="dlg" style="max-width:680px;">
        <div class="dlg-head">
            <h3><i class="fas fa-ban" style="color:#FD7E14;"></i> Annuler un envoi</h3>
            <button class="dlg-close" onclick="closeAll()"><i class="fas fa-times"></i></button>
        </div>
        <div class="dlg-body" style="text-align:center;">
            <div class="cancel-icon-circle"><i class="fas fa-headset"></i></div>
            <h4 style="font-weight:700;color:#1a1a2e;margin-bottom:6px;">Service Client KantyMoney</h4>
            <p style="color:#6C757D;font-size:0.85rem;margin-bottom:14px;">
                Pour annuler votre envoi, veuillez contacter notre service client en communiquant la référence ci-dessous :
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
document.querySelector("[name=recepteur]")?.addEventListener("keypress",e=>{if(e.key<"0"||e.key>"9")e.preventDefault();});
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
document.querySelectorAll(".overlay").forEach(o=>o.addEventListener("click",function(e){if(e.target===this)closeAll();}));
document.addEventListener("keydown",e=>{if(e.key==="Escape")closeAll();});

document.getElementById("btnNew")?.addEventListener("click",()=>openModal("mdlStep1"));

function openCancel(ref){
    document.getElementById("cancelRef").textContent="#"+ref;
    openModal("mdlCancel");
}

function goBackToStep1(){
    const step2 = document.getElementById("mdlStep2");
    const step1 = document.getElementById("mdlStep1");
    if (step2) step2.classList.remove("on");
    if (step1) step1.classList.add("on");
    document.body.style.overflow = "hidden";
}

// Filtre automatique par date
function applyDateFilter() {
    const dateVal = document.getElementById('filterDate').value;
    const baseUrl = '<%= request.getContextPath() %>/envoi';
    if (dateVal) {
        window.location.href = baseUrl + '?date=' + encodeURIComponent(dateVal);
    } else {
        window.location.href = baseUrl;
    }
}

// Réinitialiser le filtre
function resetFilter() {
    window.location.href = '<%= request.getContextPath() %>/envoi';
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