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

    public ILoginServiceClient Login(string user, string password)
        => new LoginServiceClient(ServerUrl, user, password);

    public IFornitoriServiceClient Fornitori()
        => new FornitoriServiceClient(ServerUrl, _session.User, _session.Password);

    public IArticoliServiceClient Articoli()
        => new ArticoliServiceClient(ServerUrl, _session.User, _session.Password);

    public IDocServiceClient Docs()
        => new DocServiceClient(ServerUrl, _session.User, _session.Password);

    public IConciliazioneServiceClient Conciliazione()
        => new ConciliazioneServiceClient(ServerUrl, _session.User, _session.Password);

    public LogServiceClient Logs()
        => new LogServiceClient(ServerUrl, _session.User, _session.Password);

    public IUserServiceClient Users()
        => new UserServiceClient(ServerUrl, _session.User, _session.Password);
}
