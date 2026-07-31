using System.Text.RegularExpressions;

namespace EmmaClientWeb.Services;

/// <summary>Portato da EmmaClientAv.Helpers.PasswordValidator.</summary>
public static class PasswordValidator
{
    private const string Pattern = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$";

    public static bool IsPasswordValid(string password)
    {
        if (string.IsNullOrWhiteSpace(password)) return false;
        return Regex.IsMatch(password, Pattern);
    }
}
