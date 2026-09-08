// Helper JS per il client web Emma
window.emma = {
    // Scarica del testo (usato dall'export CSV di Visualizza Documenti,
    // equivalente del SaveFilePicker di Avalonia)
    downloadText: function (fileName, text) {
        // BOM UTF-8 per la corretta apertura in Excel
        const blob = new Blob(["\uFEFF" + text], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.download = fileName;
        link.href = url;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    },

    // Porta un contenitore scrollabile in fondo (chat di Ricerca)
    scrollToBottom: function (id) {
        const el = document.getElementById(id);
        if (el) el.scrollTop = el.scrollHeight;
    }
};
