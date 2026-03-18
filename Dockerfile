FROM eclipse-temurin:21-jre-alpine
LABEL authors="gary.boriskin"
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} spring-boot-app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar","/spring-boot-app.jar"]