namespace EmmaClientWeb.Services;

/// <summary>
/// Credenziali della sezione Admin. Valorizzate da appsettings.json (sezione "Admin"),
/// con fallback su admin/admin. Sostituire con una vera autenticazione quando disponibile.
/// </summary>
public class AdminOptions
{
    public string User { get; set; } = "admin";
    public string Password { get; set; } = "admin";
}

/// <summary>
/// Sessione della sezione Admin (/admin), separata da <see cref="UserSession"/>.
/// È Scoped: vive quanto il circuito SignalR dell'utente collegato.
/// </summary>
public class AdminSession
{
    private readonly AdminOptions _options;

    public AdminSession(AdminOptions options) => _options = options;

    public string User { get; private set; } = string.Empty;

    /// <summary>
    /// Password inserita al login: serve per la Basic auth verso le API del server,
    /// che richiedono l'utente "admin" (EmmaAdmin.ADMIN) sugli endpoint /api/tenants.
    /// </summary>
    public string Password { get; private set; } = string.Empty;

    public bool IsAuthenticated => !string.IsNullOrWhiteSpace(User);

    public event Action? Changed;

    /// <summary>Validazione delle credenziali admin.</summary>
    public bool Validate(string user, string password)
        => string.Equals(user, _options.User, StringComparison.OrdinalIgnoreCase)
           && string.Equals(password, _options.Password, StringComparison.Ordinal);

    public void SignIn(string user, string password)
    {
        User = user;
        Password = password;
        Changed?.Invoke();
    }

    public void SignOut()
    {
        User = string.Empty;
        Password = string.Empty;
        Changed?.Invoke();
    }
}
