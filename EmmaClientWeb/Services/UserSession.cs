namespace EmmaClientWeb.Services;

/// <summary>
/// Sostituisce App.CurrentApp.EMMMA_USER / EMMMA_PASSWORD del client Avalonia.
/// È Scoped: vive quanto il circuito SignalR dell'utente collegato.
/// </summary>
public class UserSession
{
    public string User { get; private set; } = string.Empty;
    public string Password { get; private set; } = string.Empty;

    public string Codice { get; private set; } = string.Empty;

    /// <summary>URL server valorizzato al login (LoginResponse.url), altrimenti quello di configurazione.</summary>
    public string? ServerUrlOverride { get; set; }

    public bool IsAuthenticated => !string.IsNullOrWhiteSpace(User);

    public event Action? Changed;

    public void SignIn(string user, string password, string codice)
    {
        User = user;
        Password = password;
        Codice = codice;
        Changed?.Invoke();
    }

    public void SignOut()
    {
        User = string.Empty;
        Password = string.Empty;
        ServerUrlOverride = null;
        Changed?.Invoke();
    }

    /// <summary>Aggiorna la password dopo un cambio password andato a buon fine.</summary>
    public void UpdatePassword(string newPassword) => Password = newPassword;
}
