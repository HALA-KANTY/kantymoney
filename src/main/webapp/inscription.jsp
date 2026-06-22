<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestion Utilisateurs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <div class="container mt-5">
    <div class="card mx-auto shadow-sm mb-5" style="max-width: 500px;">
     <a href="index.jsp" class="btn-nav btn-register">retour</a>
        <div class="card-body">
            <h3 id="form-title" class="card-title text-center mb-4">Inscription</h3>
            
            <form action="inscrire" method="POST" id="mainForm">
                <input type="hidden" name="action" id="form-action" value="create">
                
                <div class="mb-3">
                    <label class="form-label">Nom complet</label>
                    <input type="text" name="nom" id="input-nom" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" id="input-email" class="form-control" required>
                </div>
                <div class="mb-3" id="password-group">
                    <label class="form-label">Mot de passe</label>
                    <input type="password" name="password" id="input-password" class="form-control">
                </div>
                
                <button type="submit" id="submit-btn" class="btn btn-primary w-100">S'inscrire</button>
                <button type="button" onclick="resetForm()" id="cancel-btn" class="btn btn-secondary w-100 mt-2" style="display:none;">Annuler</button>
            </form>
        </div>
    </div>

    <table class="table table-striped shadow-sm">
        <thead class="table-dark">
            <tr><th>Nom</th><th>Email</th><th>Actions</th></tr>
        </thead>
        <tbody>
            <% 
                List<String[]> users = (List<String[]>) request.getAttribute("utilisateurs");
                if (users != null) {
                    for (String[] u : users) {
            %>
            <tr>
                <td><%= u[0] %></td>
                <td><%= u[1] %></td>
                <td>
                    <button class="btn btn-warning btn-sm" onclick="preRemplir('<%= u[0] %>', '<%= u[1] %>')">Modifier</button>
                    
                    <form action="inscrire" method="POST" style="display:inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="email" value="<%= u[1] %>">
                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Supprimer ?')">Supprimer</button>
                    </form>
                </td>
            </tr>
            <% } } %>
        </tbody>
    </table>
</div>

<script>
function preRemplir(nom, email) {
    // 1. On change le titre et le bouton
    document.getElementById('form-title').innerText = "Modifier l'utilisateur";
    document.getElementById('submit-btn').innerText = "Enregistrer les modifications";
    document.getElementById('submit-btn').className = "btn btn-success w-100";
    document.getElementById('cancel-btn').style.display = "block";
    
    // 2. On change l'action pour la Servlet
    document.getElementById('form-action').value = "update";
    
    // 3. On remplit les champs
    document.getElementById('input-nom').value = nom;
    document.getElementById('input-email').value = email;
    document.getElementById('input-email').readOnly = true; // On ne change pas l'email
    
    // 4. On cache le mot de passe (pas besoin pour une simple modif de nom ici)
    document.getElementById('password-group').style.display = "none";
}

function resetForm() {
    location.reload(); // Le plus simple pour remettre le formulaire à zéro
}
</script>

</body>
</html>