# Étape 1 : Build de l'application avec Maven et Java 17
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copie le fichier de configuration Maven et télécharge les dépendances
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copie tout le dossier src (qui contient déjà src/main/java et src/main/webapp)
COPY src ./src

# Compile et génère le fichier .war
RUN mvn clean package -DskipTests

# Étape 2 : Déploiement dans le serveur Tomcat 10
FROM tomcat:10.1-jdk17-temurin

# Supprime les applications par défaut de Tomcat pour faire de la place
RUN rm -rf /usr/local/tomcat/webapps/*

# Copie le fichier .war généré à l'étape précédente sous le nom ROOT.war
# (Pour y accéder directement via http://localhost:8080/)
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]