using Emma.Services.Services;

namespace EmmaClientWeb.Services;

/// <summary>
/// Equivalente di <see cref="EmmaServiceFactory"/> per la sezione Admin:
/// costruisce i servizi di Emma.Services con le credenziali della sessione admin.
/// Gli endpoint /api/tenants accettano solo l'utente "admin" (EmmaAdmin.ADMIN),
/// quindi le credenziali configurate qui devono coincidere con quelle del server.
/// </summary>
public class AdminServiceFactory
{
    private readonly AppConfig _config;
    private readonly AdminSession _session;

    public AdminServiceFactory(AppConfig config, AdminSession session)
    {
        _config = config;
        _session = session;
    }

    public string ServerUrl => _config.ServerUrl;

    public ITenantServiceClient Tenants()
        => new TenantServiceClient(ServerUrl, _session.User, _session.Password);

    public IUserService Users()
        => new UserService(ServerUrl, _session.User, _session.Password);

    public LogService Logs()
        => new LogService(ServerUrl, _session.User, _session.Password);
}
