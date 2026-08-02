# ==============================================================================
# Dockerfile per EmmaClientWeb (Blazor Server).
#
# Questo file va nella RADICE del repository del client web (questa cartella,
# "EMMA-WEB", è la root del repo Git). Emma.Services ed EmmaServer.Entities
# vivono in un repository GitHub separato e pubblico (EMMA-SERVER): li
# recuperiamo con un git fetch in uno stage dedicato, invece di copiarli dal
# contesto di build locale.
#
# Il repo EMMA-SERVER contiene già Emma.Services/ ed EmmaServer.Entities/ nella
# sua struttura: lo cloniamo intatto sotto EMMA-SERVER/, sibling di EMMA-WEB,
# così i ProjectReference "..\..\EMMA-SERVER\Emma.Services\..." nel csproj
# risolvono esattamente come in sviluppo locale (dove EMMA-SERVER va clonato
# as-is accanto a questo repo).
#
# Build/run locale:
#   docker build -t emma-client-web .
#   docker run --rm -p 8080:8080 -e Emma__ServerUrl=https://emma-server-uda8.onrender.com emma-client-web
#
# Per puntare a un branch, tag o commit diverso da "main":
#   docker build --build-arg EMMA_SERVER_REF=v1.2.3 -t emma-client-web .
#   docker build --build-arg EMMA_SERVER_REF=a1b2c3d4 -t emma-client-web .
#
# Per un fork:
#   docker build --build-arg EMMA_SERVER_SLUG=miofork/EMMA-SERVER .
# ==============================================================================

# ---- Stage 1: recupera Emma.Services ed EmmaServer.Entities da EMMA-SERVER ----
FROM alpine/git:latest AS deps

# owner/repo su GitHub: serve sia per l'URL di clone sia per l'API usata come
# cache-buster qui sotto, quindi lo teniamo in un solo posto.
ARG EMMA_SERVER_SLUG=maltomare70/EMMA-SERVER
ARG EMMA_SERVER_REPO=https://github.com/${EMMA_SERVER_SLUG}.git
# Accetta branch, tag o commit SHA completo/abbreviato.
ARG EMMA_SERVER_REF=main

WORKDIR /deps

# --- CACHE BUSTING ---------------------------------------------------------
# Il RUN qui sotto verrebbe cachato in base alla sola stringa del comando: con
# EMMA_SERVER_REF=main Docker riuserebbe uno snapshot vecchio anche dopo un
# push su EMMA-SERVER, compilando in silenzio contro librerie stantie.
# Questo ADD scarica i metadati dell'ultimo commit del ref: se il commit
# cambia, cambia il contenuto del file, e tutti i layer successivi vengono
# ricostruiti. Con un ref pinnato (tag/SHA) il contenuto è stabile e la cache
# resta valida, come deve essere.
# NB: API GitHub anonima = 60 richieste/ora per IP. Se dovesse fallire (build
# su IP condivisi tipo Render), commenta questa riga e usa CACHEBUST o
# `docker build --no-cache`.
ADD https://api.github.com/repos/${EMMA_SERVER_SLUG}/commits/${EMMA_SERVER_REF} /tmp/emma-server-head.json

# Escamotage manuale alternativo/aggiuntivo:
#   docker build --build-arg CACHEBUST=$(date +%s) .
ARG CACHEBUST=0
RUN echo "cachebust=${CACHEBUST}" > /tmp/cachebust
# ---------------------------------------------------------------------------

# git init + fetch --depth 1 invece di `clone --branch`: così EMMA_SERVER_REF
# può essere indifferentemente un branch, un tag o un commit SHA (GitHub
# permette il fetch di SHA arbitrari). Ci serve solo lo snapshot, non la storia.
RUN git init -q . \
 && git remote add origin "${EMMA_SERVER_REPO}" \
 && git fetch --depth 1 origin "${EMMA_SERVER_REF}" \
 && git checkout -q FETCH_HEAD \
 && rm -rf .git

# ---- Stage 2: immagine runtime minimale (solo ASP.NET, nessun SDK) ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# ---- Stage 3: restore + sorgenti ----
# Nessun `dotnet build` qui: lo stage publish qui sotto ricompila comunque tutto
# da zero, quindi una build separata raddoppierebbe soltanto i tempi buttando via
# il proprio output. Questo stage prepara il contesto (restore + codice), publish
# fa la compilazione vera.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# 1. Copia solo i .csproj (dipendenze esterne + progetto web) per sfruttare la
#    cache di Docker sul restore dei pacchetti NuGet.
COPY --from=deps /deps/Emma.Services/Emma.Services.csproj EMMA-SERVER/Emma.Services/
COPY --from=deps /deps/EmmaServer.Entities/EmmaServer.Entities.csproj EMMA-SERVER/EmmaServer.Entities/
COPY ["EmmaClientWeb/EmmaClientWeb.csproj", "EMMA-WEB/EmmaClientWeb/"]
RUN dotnet restore "EMMA-WEB/EmmaClientWeb/EmmaClientWeb.csproj"

# 2. Copia il codice sorgente completo: prima le dipendenze esterne, poi questo
#    repo. (Serve un .dockerignore con bin/, obj/, .git/, altrimenti artefatti
#    locali finiscono nel contesto e invalidano la cache a ogni build.)
COPY --from=deps /deps/Emma.Services/. EMMA-SERVER/Emma.Services/
COPY --from=deps /deps/EmmaServer.Entities/. EMMA-SERVER/EmmaServer.Entities/
COPY . EMMA-WEB/

# ---- Stage 4: publish (compila e produce gli artefatti da distribuire) ----
# Si resta nella cartella radice (/src) per non rompere i percorsi relativi dei
# ProjectReference verso EMMA-SERVER.
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