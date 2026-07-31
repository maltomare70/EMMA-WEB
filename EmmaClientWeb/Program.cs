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
