# EmmaClientWeb — versione Blazor del client Avalonia

Porting web di `EMMA-CLIENT/EmmaClientAv` (Avalonia 12 / .NET 10) su **Blazor Server**.
Riusa senza modifiche i progetti esistenti `Emma.Services` e `EmmaServer.Entities`.

## Avvio

```bash
cd EMMA-WEB/EmmaClientWeb
dotnet restore
dotnet run
```

Poi aprire <http://localhost:5080>.

L'URL del server Emma si configura in `appsettings.json` (`Emma:ServerUrl`);
in Development vale `http://localhost:9111`, come faceva il `#if DEBUG` di `ConfigManager.Load()`.
Se il login restituisce un `LoginResponse.url` valorizzato, quell'URL sovrascrive il valore
per la sessione corrente (come faceva `ConfigManager.Save` sul client desktop).

## Mappatura Avalonia → Blazor

| Client Avalonia | Client Web | Rotta |
|---|---|---|
| `Forms/Login/Login.axaml` | `Components/Pages/Login.razor` | `/` |
| `MainWindow.axaml` | `Components/Pages/Dashboard.razor` | `/dashboard` |
| `Forms/LoadDoc/LoadDdtForm.axaml` | `Components/Pages/LoadDoc.razor` | `/documenti/carica` |
| `Forms/VisDocs/VisDocForms.axaml` | `Components/Pages/VisDocs.razor` | `/documenti` |
| `Forms/Fornitori/FornitoriForm.axaml` | `Components/Pages/Fornitori.razor` | `/fornitori` |
| `Forms/Articoli/ArticoliForm.axaml` | `Components/Pages/Articoli.razor` | `/articoli` |
| `Forms/Logs/LogForms.axaml` | `Components/Pages/Logs.razor` | `/log` |
| `Forms/Password/PwdForm.axaml` | `Components/Pages/Password.razor` | `/password` |
| `Forms/Dialog/ConfermaDialog.axaml` + `DialogHelper` | `Components/Shared/EmmaDialogs.razor` | — |
| `App.CurrentApp.EMMMA_USER/PASSWORD` | `Services/UserSession.cs` (scoped sul circuito) | — |
| `Helpers/AppConfig.cs` | `Services/AppConfig.cs` + `appsettings.json` | — |
| `Helpers/PasswordValidator.cs` | `Services/PasswordValidator.cs` | — |
| istanze `new XxxService(App.Config.ServerUrl, ...)` | `Services/EmmaServiceFactory.cs` | — |

## Fedeltà grafica

`wwwroot/css/emma.css` replica la palette e le misure dello XAML originale:

- dashboard `#F5F7FA`, titolo `#1E293B`, sottotitolo `#64748B`
- card 200×200, margin 12, `CornerRadius=12`, bordo `#E2E8F0`, testo `#334155`, icona 120×120
- toolbar = `Border` `#F9F9F9` / `#E0E0E0` / raggio 6 / padding 12
- pulsanti `#2196F3`, `DodgerBlue`, `#4CAF50`, `#2ecc71`, `#F44336`, `#e74c3c`, `#757575`
- DataGrid con `GridLinesVisibility=All` → bordi `#D0D0D0` su ogni cella
- `RowDetailsTemplate` → riga espandibile con sfondo `#F5F5F5`, raggio 4, padding 15
- font Inter, cultura `it-IT`

Le icone sono le stesse (`Assets/*.png` copiate in `wwwroot/img`).

## Differenze rispetto al desktop (imposte dal web)

| Desktop | Web |
|---|---|
| Finestre separate | Pagine con routing + pulsante "Indietro" nella barra titolo |
| `Process.Start` sul PDF temporaneo | Viewer nativo del browser in modale; i byte sono serviti da `GET /pdf/{id}` (`Services/PdfCache.cs`) invece di passare in base64 sul circuito SignalR |
| `SaveFilePickerAsync` per l'export CSV | Download del browser (`emma.js → downloadText`, con BOM UTF-8 per Excel) |
| `OpenFilePickerAsync` | `<InputFile>` con filtro `.pdf,.xml`, limite 50 MB |
| `Window.Closing` con conferma salvataggio | Contatore "N modifiche non salvate" in toolbar + conferma su "Ricarica" |
| `IsDirty` da `INotifyPropertyChanged` | Identico: le entity sono le stesse, le righe modificate si evidenziano in giallo, quelle nuove in verde |
| `LostFocus` sulla riga di dettaglio → `InviaModificaAllApi` | `onchange` sulla cella → stessa chiamata `PUT /api/v1/doc/riga` |
| Cursore di attesa | Classe CSS `busy` (`cursor: progress`) + pulsanti disabilitati |

Il prerender è disattivato (`InteractiveServerRenderMode(prerender: false)`) perché
`UserSession` vive nel circuito: un refresh del browser richiede quindi un nuovo login,
esattamente come riavviare l'applicazione desktop.

## Struttura

```
EMMA-WEB/
├── EmmaClientWeb.sln
└── EmmaClientWeb/
    ├── EmmaClientWeb.csproj        → ProjectReference a Emma.Services e EmmaServer.Entities
    ├── Program.cs                  → DI, cultura it-IT, endpoint /pdf/{id}
    ├── appsettings*.json
    ├── Components/
    │   ├── App.razor, Routes.razor, _Imports.razor
    │   ├── Layout/MainLayout.razor
    │   ├── Shared/EmmaDialogs.razor, PdfViewer.razor
    │   └── Pages/*.razor
    ├── Services/
    │   ├── AppConfig.cs, UserSession.cs, EmmaServiceFactory.cs
    │   ├── PasswordValidator.cs, PdfCache.cs
    └── wwwroot/
        ├── css/emma.css
        ├── js/emma.js
        └── img/*.png
```
