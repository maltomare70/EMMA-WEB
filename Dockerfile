# ==============================================================================
# Dockerfile per EmmaClientWeb (Blazor Server).
#
# Questo file va nella RADICE del repository del client web (questa cartella,
# "EMMA-WEB", è la root del repo Git). Emma.Services ed EmmaServer.Entities
# vivono in un repository GitHub separato e pubblico (EMMA-SERVER): li
# recuperiamo con un git clone in uno stage dedicato, invece di copiarli dal
# contesto di build locale.
#
# Il repo EMMA-SERVER contiene già Emma.Services/ ed EmmaServer.Entities/ nella
# sua struttura: lo clonano intatto sotto EMMA-SERVER/, sibling di EMMA-WEB,
# così i ProjectReference "..\..\EMMA-SERVER\Emma.Services\..." nel csproj
# risolvono esattamente come in sviluppo locale (dove EMMA-SERVER va clonato
# as-is accanto a questo repo).
#
# Build/push locale:
#   docker build -t emma-client-web .
#   docker run --rm -p 8080:8080 -e Emma__ServerUrl=https://emma-server-uda8.onrender.com emma-client-web
#
# Per puntare a un fork o a un branch/tag/commit diverso da "main":
#   docker build --build-arg EMMA_SERVER_REF=v1.2.3 -t emma-client-web .
# ==============================================================================

# ---- Stage 1: recupera Emma.Services ed EmmaServer.Entities da EMMA-SERVER ----
FROM alpine/git:latest AS deps
ARG EMMA_SERVER_REPO=https://github.com/maltomare70/EMMA-SERVER.git
ARG EMMA_SERVER_REF=main
WORKDIR /deps
# --depth 1 basta: ci serve solo lo snapshot, non la storia del repo.
# NB: con un branch (non un tag/commit fisso) Docker può riusare la cache di
# questo layer anche se il repo esterno è cambiato nel frattempo. Per forzare
# un refresh: `docker build --no-cache` oppure fissare EMMA_SERVER_REF a un
# tag/commit preciso e aggiornarlo a ogni release del server.
RUN git clone --depth 1 --branch ${EMMA_SERVER_REF} ${EMMA_SERVER_REPO} .

# ---- Stage 2: immagine runtime minimale (solo ASP.NET, nessun SDK) ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# ---- Stage 3: build ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# 1. Copia solo i .csproj (dipendenze esterne + progetto web) per sfruttare la
#    cache di Docker sul restore delle dipendenze NuGet.
COPY --from=deps /deps/Emma.Services/Emma.Services.csproj EMMA-SERVER/Emma.Services/
COPY --from=deps /deps/EmmaServer.Entities/EmmaServer.Entities.csproj EMMA-SERVER/EmmaServer.Entities/
COPY ["EmmaClientWeb/EmmaClientWeb.csproj", "EMMA-WEB/EmmaClientWeb/"]
RUN dotnet restore "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj"

# 2. Copia il codice sorgente completo: prima le dipendenze esterne, poi questo repo
COPY --from=deps /deps/Emma.Services/. EMMA-SERVER/Emma.Services/
COPY --from=deps /deps/EmmaServer.Entities/. EMMA-SERVER/EmmaServer.Entities/
COPY . EMMA-WEB/

# 3. Esegue la build rimanendo nella cartella radice (/src) per evitare problemi con i percorsi relativi
RUN dotnet build "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj" -c $BUILD_CONFIGURATION -o /app/build

# ---- Stage 4: publish ----
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# ---- Stage 5: immagine finale ----
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Render instrada il traffico sulla porta esposta e termina il TLS a monte
ENV ASPNETCORE_HTTP_PORTS=8080

ENTRYPOINT ["dotnet", "EmmaClientWeb.dll"]
