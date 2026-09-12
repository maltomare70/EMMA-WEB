<#
.SYNOPSIS
    Avvia il client web EMMA (immagine almalabs/emma-web) in un container Docker,
    configurandolo tramite un file di variabili d'ambiente.

.DESCRIPTION
    Lo script legge un file "emma-web.env" (righe KEY=VALUE) e traduce ogni riga
    in un parametro -e di "docker run". Le chiavi seguono la convenzione di
    configurazione ASP.NET Core con doppio underscore: "Emma__ServerUrl"
    corrisponde alla sezione "Emma": { "ServerUrl": ... } di appsettings.json.

    Le chiavi lasciate vuote nel file vengono saltate: in questo modo resta
    attivo il default presente nell'appsettings.json dell'immagine.

    Il file .env NON va versionato (contiene password): si versiona invece
    emma-web.env.example, da copiare con -InitEnv.

.PARAMETER EnvFile
    Percorso del file di variabili. Default: emma-web.env accanto a questo script.

.PARAMETER Image
    Nome dell'immagine. Default: almalabs/emma-web

.PARAMETER Tag
    Tag dell'immagine. Default: latest

.PARAMETER Name
    Nome del container. Default: emma-web

.PARAMETER Port
    Porta sull'host. Default: 9110

.PARAMETER ContainerPort
    Porta in ascolto dentro il container. Default: 8080

.PARAMETER Network
    Rete Docker a cui agganciare il container; viene creata se non esiste.
    Serve per raggiungere emma-server per nome (http://emma-server:8080):
    sulla bridge di default Docker non risolve i nomi dei container.
    Default: emma-net. Stringa vuota per non usare nessuna rete.

.PARAMETER KeysVolume
    Volume Docker su cui persistere il key ring di Data Protection, montato
    su /home/app/.aspnet/DataProtection-Keys (l'immagine gira come utente
    'app', non root). Senza, ogni ricreazione del container genera chiavi
    nuove e i cookie antiforgery gia' emessi diventano indecifrabili
    ("The key {...} was not found in the key ring").
    Lo script crea il volume e ne sistema i permessi per l'utente 'app'.
    Default: emma-web-keys. Stringa vuota per non montare nulla.

.PARAMETER InitEnv
    Crea emma-web.env copiando emma-web.env.example (non sovrascrive se esiste).

.PARAMETER Pull
    Esegue "docker pull" dell'immagine prima di avviare.

.PARAMETER Recreate
    Se un container con lo stesso nome esiste gia', lo ferma e lo rimuove.

.PARAMETER Foreground
    Avvia in primo piano (--rm -it) invece che in background.

.PARAMETER Logs
    Mostra i log del container in streaming ed esce.

.PARAMETER Stop
    Ferma e rimuove il container ed esce.

.PARAMETER DryRun
    Stampa il comando docker che verrebbe eseguito, con i segreti mascherati.

.EXAMPLE
    .\run-emma-web.ps1 -InitEnv
    Crea il file emma-web.env da personalizzare.

.EXAMPLE
    .\run-emma-web.ps1 -Pull -Recreate
    Scarica l'ultima immagine e riavvia il container da zero.

.EXAMPLE
    .\run-emma-web.ps1 -DryRun
    Verifica quali variabili verranno passate al container.
#>
[CmdletBinding()]
param(
    [string]$EnvFile,
    [string]$Image = 'almalabs/emma-web',
    [string]$Tag = 'latest',
    [string]$Name = 'emma-web',
    [int]$Port = 9110,
    [int]$ContainerPort = 8080,
    [string]$Network = 'emma-net',
    [string]$KeysVolume = 'emma-web-keys',
    [switch]$InitEnv,
    [switch]$Pull,
    [switch]$Recreate,
    [switch]$Foreground,
    [switch]$Logs,
    [switch]$Stop,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Utility di output
# ---------------------------------------------------------------------------
function Write-Info { param([string]$Message) Write-Host "[emma-web] $Message" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Message) Write-Host "[emma-web] $Message" -ForegroundColor Green }
function Write-Warn { param([string]$Message) Write-Host "[emma-web] $Message" -ForegroundColor Yellow }
function Write-Err  { param([string]$Message) Write-Host "[emma-web] $Message" -ForegroundColor Red }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
    $EnvFile = Join-Path $ScriptDir 'emma-web.env'
}
$EnvExample = Join-Path $ScriptDir 'emma-web.env.example'
$ImageRef = "{0}:{1}" -f $Image, $Tag

# ---------------------------------------------------------------------------
# Invocazione di docker.exe
#
# docker scrive su stderr anche quando va tutto bene: il progress del pull, e
# warning come "WARNING: No blkio throttle.read_bps_device support" di
# "docker info". Con $ErrorActionPreference = 'Stop' PowerShell 5.1 trasforma
# quello stderr in un NativeCommandError terminante e lo script muore su un
# semplice warning. Qui abbassiamo temporaneamente la preferenza: l'esito lo
# valutiamo noi con $LASTEXITCODE, che e' l'unico segnale affidabile.
#
# Gli argomenti si passano come array esplicito (-Arguments) e non con
# ValueFromRemainingArguments, altrimenti token come "-d" o "-e" verrebbero
# interpretati da PowerShell come parametri della funzione.
# ---------------------------------------------------------------------------
function Invoke-Docker {
    param([string[]]$Arguments)

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & docker @Arguments
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

# ---------------------------------------------------------------------------
# Docker disponibile?
# ---------------------------------------------------------------------------
function Assert-Docker {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        throw "Docker non trovato nel PATH. Installa/avvia Docker Desktop e riprova."
    }

    $null = Invoke-Docker -Arguments @('info', '--format', '{{.ServerVersion}}') 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Il daemon Docker non risponde. Avvia Docker Desktop e riprova."
    }
}

# ---------------------------------------------------------------------------
# Lettura del file .env: righe KEY=VALUE, commenti con # o ;, valori vuoti saltati
# ---------------------------------------------------------------------------
function Read-EnvFile {
    param([string]$Path)

    $result = [ordered]@{}
    if (-not (Test-Path -LiteralPath $Path)) { return $result }

    $lineNo = 0
    foreach ($rawLine in (Get-Content -LiteralPath $Path -Encoding UTF8)) {
        $lineNo++
        $line = $rawLine.Trim()
        if ($line.Length -eq 0) { continue }
        if ($line.StartsWith('#') -or $line.StartsWith(';')) { continue }

        $idx = $line.IndexOf('=')
        if ($idx -lt 1) {
            Write-Warn "Riga $lineNo ignorata (manca '='): $rawLine"
            continue
        }

        $key = $line.Substring(0, $idx).Trim()
        $value = $line.Substring($idx + 1).Trim()

        # Toglie eventuali apici/virgolette di contenimento
        if ($value.Length -ge 2) {
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        if ([string]::IsNullOrWhiteSpace($value)) {
            # Valore vuoto = usa il default dell'appsettings.json dell'immagine
            continue
        }

        $result[$key] = $value
    }

    return $result
}

# ---------------------------------------------------------------------------
# Mascheramento dei segreti per -DryRun
# ---------------------------------------------------------------------------
function Get-MaskedValue {
    param([string]$Key, [string]$Value)

    if ($Key -match '(?i)(password|secret|token|apikey|api_key|__key$)') {
        if ($Value.Length -le 2) { return '***' }
        return ('{0}***{1}' -f $Value.Substring(0, 1), $Value.Substring($Value.Length - 1, 1))
    }
    return $Value
}

function Get-ContainerState {
    param([string]$ContainerName)

    $filter = "name=^/{0}$" -f $ContainerName
    $found = Invoke-Docker -Arguments @('ps', '-a', '--filter', $filter, '--format', '{{.State}}') 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    if ($null -eq $found) { return $null }

    $first = @($found) | Select-Object -First 1
    if ($null -eq $first -or [string]::IsNullOrWhiteSpace($first.ToString())) { return $null }
    return $first.ToString().Trim()
}

# ---------------------------------------------------------------------------
# Rete Docker: sulla bridge di default i container non si risolvono per nome,
# serve una rete definita dall'utente perche' emma-web trovi emma-server.
# ---------------------------------------------------------------------------
function Confirm-Network {
    param([string]$NetworkName)

    if ([string]::IsNullOrWhiteSpace($NetworkName)) { return }

    $filter = "name=^{0}$" -f $NetworkName
    $found = Invoke-Docker -Arguments @('network', 'ls', '--filter', $filter, '--format', '{{.Name}}') 2>$null

    $first = @($found) | Select-Object -First 1
    if ($null -ne $first -and -not [string]::IsNullOrWhiteSpace($first.ToString())) {
        Write-Info "Rete '$NetworkName' gia' presente."
        return
    }

    Write-Info "Creazione della rete '$NetworkName'..."
    $null = Invoke-Docker -Arguments @('network', 'create', $NetworkName) 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Creazione della rete '$NetworkName' fallita." }
}

# ---------------------------------------------------------------------------
# Volume del key ring.
#
# Docker crea un volume nominato di proprieta' di root:root, ma l'immagine gira
# come utente 'app' (USER $APP_UID nel Dockerfile): al primo avvio il container
# non riesce a scrivere le chiavi e fallisce con
#   UnauthorizedAccessException: Access to the path '.../xxx.tmp' is denied.
# Qui si sistemano i permessi con un container usa-e-getta che gira come root.
# L'UID lo si legge da $APP_UID dentro l'immagine invece di scriverlo a mano.
# ---------------------------------------------------------------------------
function Confirm-KeysVolume {
    param([string]$VolumeName, [string]$ImageReference)

    if ([string]::IsNullOrWhiteSpace($VolumeName)) { return }

    $null = Invoke-Docker -Arguments @('volume', 'create', $VolumeName) 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Creazione del volume '$VolumeName' fallita." }

    $fixCommand = 'uid=${APP_UID:-1654}; chown -R "$uid":"$uid" /keys && chmod 700 /keys'

    Write-Info "Permessi del volume '$VolumeName'..."
    $null = Invoke-Docker -Arguments @(
        'run', '--rm',
        '--user', 'root',
        '-v', ("{0}:/keys" -f $VolumeName),
        '--entrypoint', 'sh',
        $ImageReference,
        '-c', $fixCommand
    ) 2>$null

    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Non sono riuscito a correggere i permessi di '$VolumeName'."
        Write-Warn "Se il container fallisce con 'Access to the path ... is denied',"
        Write-Warn "esegui a mano: docker volume rm $VolumeName"
    }
}

function Remove-ExistingContainer {
    param([string]$ContainerName)

    Write-Info "Rimozione del container esistente '$ContainerName'..."
    $null = Invoke-Docker -Arguments @('rm', '-f', $ContainerName) 2>$null
}

# ===========================================================================
# 1. -InitEnv : crea il file di configurazione dall'esempio
# ===========================================================================
if ($InitEnv) {
    if (-not (Test-Path -LiteralPath $EnvExample)) {
        throw "File di esempio non trovato: $EnvExample"
    }
    if (Test-Path -LiteralPath $EnvFile) {
        Write-Warn "Il file esiste gia', non lo sovrascrivo: $EnvFile"
    }
    else {
        Copy-Item -LiteralPath $EnvExample -Destination $EnvFile
        Write-Ok "Creato $EnvFile - aprilo e imposta le variabili, poi rilancia lo script."
    }
    return
}

Assert-Docker

# ===========================================================================
# 2. -Stop / -Logs : azioni rapide sul container
# ===========================================================================
if ($Stop) {
    $state = Get-ContainerState -ContainerName $Name
    if ($null -eq $state) {
        Write-Warn "Nessun container '$Name' da fermare."
    }
    else {
        Remove-ExistingContainer -ContainerName $Name
        Write-Ok "Container '$Name' fermato e rimosso."
    }
    return
}

if ($Logs) {
    $state = Get-ContainerState -ContainerName $Name
    if ($null -eq $state) { throw "Nessun container '$Name' attivo." }
    Invoke-Docker -Arguments @('logs', '-f', $Name)
    return
}

# ===========================================================================
# 3. Configurazione
# ===========================================================================
if (-not (Test-Path -LiteralPath $EnvFile)) {
    Write-Warn "File di configurazione non trovato: $EnvFile"
    Write-Warn "Lancia '.\run-emma-web.ps1 -InitEnv' per crearlo dall'esempio."
    Write-Warn "Proseguo con i soli default dell'immagine."
    $envVars = [ordered]@{}
}
else {
    $envVars = Read-EnvFile -Path $EnvFile
    Write-Info ("Lette {0} variabili da {1}" -f $envVars.Count, $EnvFile)
}

# La porta di ascolto interna deve combaciare con quella pubblicata.
if (-not $envVars.Contains('ASPNETCORE_HTTP_PORTS')) {
    $envVars['ASPNETCORE_HTTP_PORTS'] = "$ContainerPort"
}

# ===========================================================================
# 4. -Pull : aggiorna l'immagine
# ===========================================================================
if ($Pull) {
    Write-Info "docker pull $ImageRef"
    Invoke-Docker -Arguments @('pull', $ImageRef)
    if ($LASTEXITCODE -ne 0) { throw "Pull dell'immagine $ImageRef fallito." }
}

# ===========================================================================
# 4b. Rete Docker
# ===========================================================================
if (-not $DryRun) {
    Confirm-Network -NetworkName $Network
    Confirm-KeysVolume -VolumeName $KeysVolume -ImageReference $ImageRef
}

# ===========================================================================
# 5. Container gia' esistente
# ===========================================================================
$existing = Get-ContainerState -ContainerName $Name
if ($null -ne $existing -and -not $DryRun) {
    if ($Recreate) {
        Remove-ExistingContainer -ContainerName $Name
    }
    else {
        Write-Err "Esiste gia' un container '$Name' (stato: $existing)."
        Write-Err "Usa -Recreate per ricrearlo, oppure -Stop per rimuoverlo."
        return
    }
}

# ===========================================================================
# 6. Costruzione del comando docker run
# ===========================================================================
$dockerArgs = [System.Collections.Generic.List[string]]::new()
$dockerArgs.Add('run')

if ($Foreground) {
    $dockerArgs.Add('--rm')
    $dockerArgs.Add('-it')
}
else {
    $dockerArgs.Add('-d')
    $dockerArgs.Add('--restart')
    $dockerArgs.Add('unless-stopped')
}

$dockerArgs.Add('--name')
$dockerArgs.Add($Name)
$dockerArgs.Add('-p')
$dockerArgs.Add(("{0}:{1}" -f $Port, $ContainerPort))

# Rete condivisa con emma-server, per raggiungerlo per nome
if (-not [string]::IsNullOrWhiteSpace($Network)) {
    $dockerArgs.Add('--network')
    $dockerArgs.Add($Network)
}

# Key ring di Data Protection persistente: senza, i cookie antiforgery
# emessi dal container precedente non sono piu' decifrabili dopo un -Recreate.
if (-not [string]::IsNullOrWhiteSpace($KeysVolume)) {
    $dockerArgs.Add('-v')
    $dockerArgs.Add(("{0}:/home/app/.aspnet/DataProtection-Keys" -f $KeysVolume))
}

# Permette al container di raggiungere servizi in ascolto sull'host Windows
# (per esempio emma-server avviato da run-emma-server.ps1 sulla porta 9111):
# in quel caso usare Emma__ServerUrl=http://host.docker.internal:9111
$dockerArgs.Add('--add-host')
$dockerArgs.Add('host.docker.internal:host-gateway')

foreach ($key in $envVars.Keys) {
    $dockerArgs.Add('-e')
    $dockerArgs.Add(("{0}={1}" -f $key, $envVars[$key]))
}

$dockerArgs.Add($ImageRef)

# ===========================================================================
# 7. -DryRun : stampa il comando con i segreti mascherati
# ===========================================================================
if ($DryRun) {
    $preview = [System.Collections.Generic.List[string]]::new()
    $preview.Add('docker')
    $isEnvValue = $false
    foreach ($a in $dockerArgs) {
        if ($isEnvValue) {
            $sep = $a.IndexOf('=')
            $k = $a.Substring(0, $sep)
            $v = $a.Substring($sep + 1)
            $preview.Add(('"{0}={1}"' -f $k, (Get-MaskedValue -Key $k -Value $v)))
            $isEnvValue = $false
            continue
        }
        $preview.Add($a)
        if ($a -eq '-e') { $isEnvValue = $true }
    }
    Write-Info 'Comando che verrebbe eseguito:'
    Write-Host ($preview -join ' ')
    return
}

# ===========================================================================
# 8. Avvio
# ===========================================================================
Write-Info "Avvio di $ImageRef come '$Name' su http://localhost:$Port ..."
Invoke-Docker -Arguments $dockerArgs.ToArray()
if ($LASTEXITCODE -ne 0) { throw "Avvio del container fallito (exit code $LASTEXITCODE)." }

if (-not $Foreground) {
    Start-Sleep -Seconds 2
    $state = Get-ContainerState -ContainerName $Name
    if ($state -ne 'running') {
        Write-Err "Il container non risulta in esecuzione (stato: $state). Ultimi log:"
        Invoke-Docker -Arguments @('logs', '--tail', '40', $Name)
        return
    }
    Write-Ok "Container '$Name' avviato: http://localhost:$Port"
    if (-not [string]::IsNullOrWhiteSpace($Network)) {
        Write-Info "Rete:   $Network (emma-server si raggiunge su http://emma-server:$ContainerPort)"
    }
    Write-Info "Log:    .\run-emma-web.ps1 -Logs"
    Write-Info "Stop:   .\run-emma-web.ps1 -Stop"
}
