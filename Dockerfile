# ==============================================================================
# Dockerfile per EmmaClientWeb (Blazor Server).
#
# Questo file va nella RADICE del repository del client web (questa cartella,
# "EMMA-WEB", diventa la root del repo Git). A differenza del server, questo
# progetto referenzia Emma.Services ed EmmaServer.Entities che vivono in un
# repository GitHub separato (EMMA-SERVER): li recuperiamo con un git clone
# in uno stage dedicato, invece di copiarli dal contesto di build locale.
#
# Build/push locale:
#   docker build -t emma-client-web .
#   docker run --rm -p 8080:8080 -e Emma__ServerUrl=https://emma-server-uda8.onrender.com emma-client-web
#
# Per puntare a un fork o a un branch/tag diverso da "main":
#   docker build --build-arg EMMA_SERVER_REF=v1.2.3 -t emma-client-web .
# ==============================================================================

# ---- Stage 1: recupera Emma.Services ed EmmaServer.Entities da EMMA-SERVER ----
FROM alpine/git:latest AS deps
ARG EMMA_SERVER_REPO=https://github.com/maltomare70/EMMA-SERVER.git
ARG EMMA_SERVER_REF=main
WORKDIR /deps
# --depth 1 basta: ci servono solo Emma.Services ed EmmaServer.Entities, non la storia.
# NB: con un branch (non un tag/commit fisso) Docker può riusare la cache di questo
# layer anche se il repo esterno è cambiato nel frattempo. Per forzare un refresh:
# `docker build --no-cache` oppure fissare EMMA_SERVER_REF a un tag/commit preciso.
RUN git clone --depth 1 --branch ${EMMA_SERVER_REF} ${EMMA_SERVER_REPO} .

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# 1. Progetti esterni (Emma.Services, EmmaServer.Entities): li piazziamo come
#    sibling di EMMA-WEB sotto /src, esattamente come nel repo di sviluppo locale,
#    così i ProjectReference "..\..\Emma.Services\..." nel csproj restano invariati.
COPY --from=deps /deps/Emma.Services/Emma.Services.csproj Emma.Services/
COPY --from=deps /deps/EmmaServer.Entities/EmmaServer.Entities.csproj EmmaServer.Entities/

# 2. Copia il file di progetto del client web per sfruttare la cache di Docker sul restore
COPY ["EmmaClientWeb/EmmaClientWeb.csproj", "EMMA-WEB/EmmaClientWeb/"]
RUN dotnet restore "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj"

# 3. Codice sorgente completo: prima le dipendenze esterne, poi il repo di questo client
COPY --from=deps /deps/Emma.Services/. Emma.Services/
COPY --from=deps /deps/EmmaServer.Entities/. EmmaServer.Entities/
COPY . EMMA-WEB/

# 4. Esegue la build rimanendo nella cartella radice (/src) per evitare problemi con i percorsi relativi
RUN dotnet build "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Render instrada il traffico sulla porta esposta e termina il TLS a monte
ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "EmmaClientWeb.dll"]
