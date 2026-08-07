using System.Globalization;
using EmmaClientWeb.Components;
using EmmaClientWeb.Services;

var builder = WebApplication.CreateBuilder(args);

// --- Blazor Server (interattività server-side) ---
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// Equivalente di AppConfig.ServerUrl del client Avalonia
builder.Services.AddSingleton(new AppConfig
{
    ServerUrl = builder.Configuration["Emma:ServerUrl"] ?? "https://emma-server-uda8.onrender.com"
});

// Cache temporanea per gli allegati PDF serviti su /pdf/{id}
builder.Services.AddSingleton<PdfCache>();

// Equivalente di App.CurrentApp.EMMMA_USER / EMMMA_PASSWORD:
// una sessione per circuito Blazor (per utente connesso)
builder.Services.AddScoped<UserSession>();

// Factory che istanzia i servizi di Emma.Services con url/credenziali correnti
builder.Services.AddScoped<EmmaServiceFactory>();

// --- Sezione Admin (/admin) ---
// Credenziali da appsettings.json (sezione "Admin"), fallback admin/admin
builder.Services.AddSingleton(new AdminOptions
{
    User = builder.Configuration["Admin:User"] ?? "admin",
    Password = builder.Configuration["Admin:Password"] ?? "admin"
});

// Sessione admin, separata da UserSession: una per circuito Blazor
builder.Services.AddScoped<AdminSession>();

// Factory dei servizi Emma.Services con le credenziali admin
builder.Services.AddScoped<AdminServiceFactory>();

var app = builder.Build();

// Forza la cultura in Italiano come faceva App.axaml.cs
var culture = new CultureInfo("it-IT");
CultureInfo.DefaultThreadCurrentCulture = culture;
CultureInfo.DefaultThreadCurrentUICulture = culture;

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseAntiforgery();
app.MapStaticAssets();

// Landing page pubblica servita su "/" (file statico wwwroot/landing.html).
// Il pulsante "Accedi al Client Web" punta a /login (pagina Blazor).
app.MapGet("/", (IWebHostEnvironment env, HttpContext http) =>
{
    http.Response.Headers.CacheControl = "no-cache, no-store, must-revalidate";
    http.Response.Headers.Pragma = "no-cache";
    http.Response.Headers.Expires = "0";

    var path = Path.Combine(env.WebRootPath, "landing.html");
    return File.Exists(path)
        ? Results.File(path, "text/html; charset=utf-8")
        : Results.Redirect("/login");
});

// Endpoint che serve l'allegato PDF al visualizzatore nativo del browser
app.MapGet("/pdf/{id}", (string id, string? download, PdfCache cache) =>
{
    if (!cache.TryGet(id, out var data, out var name)) return Results.NotFound();

    return download == "1"
        ? Results.File(data, "application/pdf", name)
        : Results.File(data, "application/pdf", enableRangeProcessing: true);
});

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
