using System.Collections.Concurrent;

namespace EmmaClientWeb.Services;

/// <summary>
/// Cache temporanea in memoria per gli allegati PDF.
/// Serve a esporre i byte del documento su un URL normale (/pdf/{id}) così che
/// il browser possa usare il proprio visualizzatore nativo dentro un iframe,
/// senza trasferire megabyte in base64 sul circuito SignalR.
/// </summary>
public class PdfCache
{
    private sealed record Item(byte[] Data, string Name, DateTime Added);

    private readonly ConcurrentDictionary<string, Item> _items = new();
    private static readonly TimeSpan Ttl = TimeSpan.FromHours(2);

    public string Put(byte[] data, string name)
    {
        Prune();
        var id = Guid.NewGuid().ToString("N");
        _items[id] = new Item(data, name, DateTime.UtcNow);
        return id;
    }

    public bool TryGet(string id, out byte[] data, out string name)
    {
        if (_items.TryGetValue(id, out var item))
        {
            data = item.Data;
            name = item.Name;
            return true;
        }

        data = Array.Empty<byte>();
        name = string.Empty;
        return false;
    }

    public void Remove(string id) => _items.TryRemove(id, out _);

    private void Prune()
    {
        var limite = DateTime.UtcNow - Ttl;
        foreach (var kv in _items)
        {
            if (kv.Value.Added < limite) _items.TryRemove(kv.Key, out _);
        }
    }
}
