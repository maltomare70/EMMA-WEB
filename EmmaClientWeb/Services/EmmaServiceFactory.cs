using Emma.Services.Services;
using EmmaClientAv.Services;

namespace EmmaClientWeb.Services;

/// <summary>
/// Costruisce i servizi della libreria Emma.Services usando
/// l'URL corrente e le credenziali della sessione, esattamente come
/// facevano i costruttori delle Window in Avalonia:
///   new FornitoriService(App.Config.ServerUrl, App.CurrentApp.EMMMA_USER, App.CurrentApp.EMMMA_PASSWORD)
/// </summary>
public class EmmaServiceFactory
{
    private readonly AppConfig _config;
    private readonly UserSession _session;

    public EmmaServiceFactory(AppConfig config, UserSession session)
    {
        _config = config;
        _session = session;
    }

    public string ServerUrl => _session.ServerUrlOverride ?? _config.ServerUrl;

    public ILoginService Login(string user, string password)
        => new LoginService(ServerUrl, user, password);

    public IFornitoriService Fornitori()
        => new FornitoriService(ServerUrl, _session.User, _session.Password);

    public IArticoliService Articoli()
        => new ArticoliService(ServerUrl, _session.User, _session.Password);

    public IDocService Docs()
        => new DocService(ServerUrl, _session.User, _session.Password);

    public IConciliazioneClientService Conciliazione()
        => new ConciliazionClientService(ServerUrl, _session.User, _session.Password);

    public LogService Logs()
        => new LogService(ServerUrl, _session.User, _session.Password);

    public IUserService Users()
        => new UserService(ServerUrl, _session.User, _session.Password);
}
