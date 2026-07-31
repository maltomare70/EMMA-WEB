namespace EmmaClientWeb.Services;

/// <summary>
/// Equivalente di EmmaClientAv.Helpers.AppConfig.
/// Nella versione web l'URL del server arriva da appsettings.json
/// e può essere sovrascritto dalla risposta di login (LoginResponse.url).
/// </summary>
public class AppConfig
{
    public string ServerUrl { get; set; } = "https://emma-server-uda8.onrender.com";
}
