// fadenkreuz.c - winziges Fadenkreuz-Overlay, exakt in der Mitte des Hauptbildschirms.
//
// Liest fadenkreuz.bmp aus dem Datenordner. Der ist, in dieser Reihenfolge:
//   1. das erste Argument (Ordner oder .bmp),
//   2. der Ordner aus datenordner.txt neben der exe (Umgebungsvariablen erlaubt),
//   3. der Ordner der exe, wenn dort schon eine fadenkreuz.bmp liegt (tragbar),
//   4. Dokumente\Fadenkreuz (wird beim ersten Start angelegt).
// 32 bit mit Alpha, oder 24 bit mit Magenta (#FF00FF) als durchsichtig.
// Ändert sich die Datei, wird sie innerhalb einer Sekunde neu geladen.
//
// Gebaut ohne C-Laufzeitbibliothek (/NODEFAULTLIB, Einsprung start): das spart
// Speicher und Startzeit, verlangt aber eigenes memset/memcpy (siehe unten).
//
// programme.txt im Datenordner: eine exe pro Zeile. Steht dort etwas, ist das
// Kreuz nur sichtbar, solange eines dieser Programme im Vordergrund ist.
//
// Strg+Alt+F9  ein/aus
// Strg+Alt+F10 Vordergrundprogramm in programme.txt aufnehmen/entfernen
// Strg+Alt+F12 beenden (oder die exe ein zweites Mal starten)

#define WIN32_LEAN_AND_MEAN
#define UNICODE
#define _UNICODE
#include <windows.h>
#include <intrin.h>

// Ohne Laufzeitbibliothek fehlen memset/memcpy, der Compiler ruft sie aber für
// Struktur-Initialisierungen und CopyMemory auf. rep stosb/movsb genügen hier.
#pragma function(memset)
#pragma function(memcpy)
void *__cdecl memset(void *ziel, int wert, size_t n) { __stosb((unsigned char *)ziel, (unsigned char)wert, n); return ziel; }
void *__cdecl memcpy(void *ziel, const void *quelle, size_t n) { __movsb((unsigned char *)ziel, (const unsigned char *)quelle, n); return ziel; }

#ifndef KLASSE
#define KLASSE    L"FadenkreuzOverlay"    // Testbauten setzen einen eigenen Namen, um ein laufendes Kreuz nicht zu beenden
#endif
#define HK_AN_AUS 1
#define HK_LISTE  2
#define HK_ENDE   3
#define TIMER_ID  1
#define LISTE_MAX 4096

static HWND     g_hwnd;
static WCHAR    g_ordner[MAX_PATH];     // mit \ am Ende
static WCHAR    g_pfad[MAX_PATH];
static WCHAR    g_liste_pfad[MAX_PATH];
static FILETIME g_stand, g_liste_stand;
static int      g_w, g_h;
static DWORD   *g_px;                   // vormultipliziertes BGRA, von oben nach unten
static BOOL     g_sichtbar = TRUE;      // von Hand (Strg+Alt+F9)
static BOOL     g_passt = TRUE;         // passendes Programm im Vordergrund
static WCHAR    g_liste[LISTE_MAX];     // Namen klein, je mit 0 getrennt, 00 am Ende
static int      g_anzahl;
static int      g_zeigt = -1;           // zuletzt gesetzte Sichtbarkeit (-1 = noch keine)
static HWND     g_letztes_fg;           // Vordergrundfenster der letzten Prüfung
static BOOL     g_neu_pruefen = TRUE;   // Liste geändert: Vordergrund erneut bewerten

static DWORD vormult(BYTE r, BYTE g, BYTE b, BYTE a)
{
    r = (BYTE)(r * a / 255); g = (BYTE)(g * a / 255); b = (BYTE)(b * a / 255);
    return ((DWORD)a << 24) | ((DWORD)r << 16) | ((DWORD)g << 8) | b;
}

static BYTE *lies_datei(const WCHAR *pfad, DWORD max, DWORD *groesse)
{
    HANDLE f = CreateFileW(pfad, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                           NULL, OPEN_EXISTING, 0, NULL);
    if (f == INVALID_HANDLE_VALUE) return NULL;
    DWORD n = GetFileSize(f, NULL), gelesen = 0;
    BYTE *d = NULL;
    if (n <= max) {
        d = HeapAlloc(GetProcessHeap(), 0, n + 1);
        if (d && (!ReadFile(f, d, n, &gelesen, NULL) || gelesen != n)) { HeapFree(GetProcessHeap(), 0, d); d = NULL; }
    }
    CloseHandle(f);
    if (d) { d[n] = 0; *groesse = n; }
    return d;
}

static DWORD *lade_bmp(const WCHAR *pfad, int *w, int *h)
{
    HANDLE heap = GetProcessHeap();
    DWORD groesse = 0;
    BYTE *d = lies_datei(pfad, 16 * 1024 * 1024, &groesse);
    DWORD *px = NULL;
    if (!d) return NULL;

    if (groesse < 54 || d[0] != 'B' || d[1] != 'M') goto ende;
    DWORD off = *(DWORD *)(d + 10);
    BITMAPINFOHEADER *bi = (BITMAPINFOHEADER *)(d + 14);
    if (bi->biSize < 40) goto ende;
    int bw = bi->biWidth, bh = bi->biHeight, bpp = bi->biBitCount;
    BOOL von_oben = bh < 0;
    if (von_oben) bh = -bh;
    if (bw <= 0 || bh <= 0 || bw > 1024 || bh > 1024) goto ende;
    if (bpp != 24 && bpp != 32) goto ende;
    if (bi->biCompression != BI_RGB && bi->biCompression != BI_BITFIELDS) goto ende;
    DWORD zeile = ((DWORD)(bw * bpp + 31) / 32) * 4;
    if (off > groesse || zeile * (DWORD)bh > groesse - off) goto ende;

    // 32 bit ohne jedes Alpha (manche Programme schreiben das so) wie 24 bit behandeln.
    BOOL alpha = FALSE, farbe = FALSE;
    if (bpp == 32)
        for (int y = 0; y < bh; y++)
            for (int x = 0; x < bw; x++) {
                BYTE *p = d + off + y * zeile + x * 4;
                if (p[3]) alpha = TRUE;
                if (p[0] | p[1] | p[2]) farbe = TRUE;
            }
    BOOL leer = bpp == 32 && !alpha && !farbe;

    px = HeapAlloc(heap, 0, (SIZE_T)bw * bh * 4);
    if (!px) goto ende;
    for (int y = 0; y < bh; y++) {
        BYTE *z = d + off + (von_oben ? y : bh - 1 - y) * zeile;
        for (int x = 0; x < bw; x++) {
            BYTE *p = z + x * (bpp / 8);
            BYTE b = p[0], g = p[1], r = p[2], a;
            if (leer)       a = 0;
            else if (alpha) a = p[3];
            else            a = (r == 255 && g == 0 && b == 255) ? 0 : 255;
            px[y * bw + x] = vormult(r, g, b, a);
        }
    }
    *w = bw; *h = bh;

ende:
    HeapFree(heap, 0, d);
    return px;
}

// Eingebautes Fadenkreuz, falls keine Datei da ist: grünes Kreuz mit Lücke, dunkler Rand.
static DWORD *standard(int *w, int *h)
{
    enum { N = 19, M = 9 };
    static BYTE kern[N * N];
    DWORD *px = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, N * N * 4);
    if (!px) return NULL;
    for (int k = 3; k <= 8; k++) {
        kern[M * N + M + k] = kern[M * N + M - k] = 1;
        kern[(M + k) * N + M] = kern[(M - k) * N + M] = 1;
    }
    kern[M * N + M] = 1;
    for (int y = 0; y < N; y++)
        for (int x = 0; x < N; x++) {
            if (kern[y * N + x]) { px[y * N + x] = vormult(0x33, 0xff, 0x88, 255); continue; }
            for (int dy = -1; dy <= 1; dy++)
                for (int dx = -1; dx <= 1; dx++) {
                    int xx = x + dx, yy = y + dy;
                    if (xx >= 0 && yy >= 0 && xx < N && yy < N && kern[yy * N + xx])
                        px[y * N + x] = vormult(0, 0, 0, 200);
                }
        }
    *w = N; *h = N;
    return px;
}

static void zeichne(void)
{
    if (!g_px) return;
    MONITORINFO mi = { sizeof mi };
    POINT null = { 0, 0 };
    GetMonitorInfoW(MonitorFromPoint(null, MONITOR_DEFAULTTOPRIMARY), &mi);
    int mw = mi.rcMonitor.right - mi.rcMonitor.left, mh = mi.rcMonitor.bottom - mi.rcMonitor.top;
    // Mittelpixel des Bildes (w/2, h/2) landet auf dem Bildschirmpixel (mw/2, mh/2).
    POINT pos = { mi.rcMonitor.left + mw / 2 - g_w / 2, mi.rcMonitor.top + mh / 2 - g_h / 2 };
    SIZE sz = { g_w, g_h };

    BITMAPINFO bmi = { 0 };
    bmi.bmiHeader.biSize = sizeof bmi.bmiHeader;
    bmi.bmiHeader.biWidth = g_w;
    bmi.bmiHeader.biHeight = -g_h;
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 32;

    HDC scr = GetDC(NULL), mem = CreateCompatibleDC(scr);
    void *bits = NULL;
    HBITMAP dib = CreateDIBSection(scr, &bmi, DIB_RGB_COLORS, &bits, NULL, 0);
    if (dib) {
        CopyMemory(bits, g_px, (SIZE_T)g_w * g_h * 4);
        HGDIOBJ alt = SelectObject(mem, dib);
        BLENDFUNCTION bf = { AC_SRC_OVER, 0, 255, AC_SRC_ALPHA };
        UpdateLayeredWindow(g_hwnd, scr, &pos, &sz, mem, &null, 0, &bf, ULW_ALPHA);
        SelectObject(mem, alt);
        DeleteObject(dib);
    }
    DeleteDC(mem);
    ReleaseDC(NULL, scr);
}

static void lade(BOOL erster_start)
{
    WIN32_FILE_ATTRIBUTE_DATA fa;
    BOOL da = GetFileAttributesExW(g_pfad, GetFileExInfoStandard, &fa);
    if (da && !erster_start && CompareFileTime(&fa.ftLastWriteTime, &g_stand) == 0) return;
    if (!da && !erster_start) return;   // Datei gerade weg: altes Bild behalten

    int w = 0, h = 0;
    DWORD *neu = da ? lade_bmp(g_pfad, &w, &h) : NULL;
    if (!neu && erster_start) neu = standard(&w, &h);
    if (!neu) return;                   // halb geschrieben: nächste Sekunde erneut
    if (da) g_stand = fa.ftLastWriteTime;
    if (g_px) HeapFree(GetProcessHeap(), 0, g_px);
    g_px = neu; g_w = w; g_h = h;
    zeichne();
    SetProcessWorkingSetSize(GetCurrentProcess(), (SIZE_T)-1, (SIZE_T)-1);
}

// ---------- Programmliste ----------

static BOOL steht_drin(const WCHAR *name)
{
    for (const WCHAR *p = g_liste; *p; p += lstrlenW(p) + 1)
        if (lstrcmpW(p, name) == 0) return TRUE;
    return FALSE;
}

static void lade_liste(BOOL erzwingen)
{
    WIN32_FILE_ATTRIBUTE_DATA fa;
    BOOL da = GetFileAttributesExW(g_liste_pfad, GetFileExInfoStandard, &fa);
    FILETIME null = { 0, 0 };
    FILETIME stand = da ? fa.ftLastWriteTime : null;
    if (!erzwingen && CompareFileTime(&stand, &g_liste_stand) == 0) return;

    static WCHAR text[LISTE_MAX];
    DWORD n = 0;
    BYTE *d = da ? lies_datei(g_liste_pfad, 16 * 1024, &n) : NULL;
    if (da && !d) return;               // gerade gesperrt: nächste Sekunde erneut
    g_liste_stand = stand;
    int z = d ? MultiByteToWideChar(CP_UTF8, 0, (char *)d, (int)n, text, LISTE_MAX - 1) : 0;
    text[z] = 0;
    if (d) HeapFree(GetProcessHeap(), 0, d);

    int pos = 0;
    g_anzahl = 0;
    for (WCHAR *zeile = text; *zeile;) {
        WCHAR *ende = zeile;
        while (*ende && *ende != L'\n') ende++;
        WCHAR *weiter = *ende ? ende + 1 : ende;
        *ende = 0;
        while (*zeile == L' ' || *zeile == L'\t' || *zeile == 0xFEFF) zeile++;
        int len = lstrlenW(zeile);
        while (len && (zeile[len - 1] == L'\r' || zeile[len - 1] == L' ' || zeile[len - 1] == L'\t')) zeile[--len] = 0;
        if (len && *zeile != L'#' && pos + len + 2 < LISTE_MAX) {
            CharLowerW(zeile);
            lstrcpyW(g_liste + pos, zeile);
            pos += len + 1;
            g_anzahl++;
        }
        zeile = weiter;
    }
    g_liste[pos] = 0;
    g_neu_pruefen = TRUE;
}

static BOOL vordergrund_name(HWND fg, WCHAR *name, DWORD n)
{
    DWORD pid = 0;
    name[0] = 0;
    if (!fg || !GetWindowThreadProcessId(fg, &pid) || !pid) return FALSE;
    HANDLE p = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!p) return FALSE;
    WCHAR voll[MAX_PATH];
    DWORD len = MAX_PATH;
    BOOL ok = QueryFullProcessImageNameW(p, 0, voll, &len);
    CloseHandle(p);
    if (!ok) return FALSE;
    WCHAR *kurz = voll;
    for (WCHAR *q = voll; *q; q++) if (*q == L'\\') kurz = q + 1;
    lstrcpynW(name, kurz, (int)n);
    CharLowerW(name);
    return TRUE;
}

static void zeige(void)
{
    int an = g_sichtbar && g_passt;
    if (an != g_zeigt) { ShowWindow(g_hwnd, an ? SW_SHOWNOACTIVATE : SW_HIDE); g_zeigt = an; }
    // Manche Programme drängeln sich nach vorn; wir bleiben oben.
    if (an) SetWindowPos(g_hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
}

static void pruefe_vordergrund(void)
{
    if (g_anzahl == 0) {
        g_passt = TRUE;
    } else {
        // Prozessname nur nachschlagen, wenn das Vordergrundfenster gewechselt hat.
        HWND fg = GetForegroundWindow();
        if (fg != g_letztes_fg || g_neu_pruefen) {
            WCHAR name[MAX_PATH];
            g_passt = vordergrund_name(fg, name, MAX_PATH) && steht_drin(name);
            g_letztes_fg = fg;
            g_neu_pruefen = FALSE;
        }
    }
    zeige();
}

static void CALLBACK vordergrund_wechsel(HWINEVENTHOOK hook, DWORD ereignis, HWND hwnd, LONG obj, LONG kind, DWORD thread, DWORD zeit)
{
    (void)hook; (void)ereignis; (void)hwnd; (void)obj; (void)kind; (void)thread; (void)zeit;
    pruefe_vordergrund();
}

// Strg+Alt+F10: Vordergrundprogramm aufnehmen oder wieder streichen.
static void liste_umschalten(void)
{
    WCHAR name[MAX_PATH];
    if (!vordergrund_name(GetForegroundWindow(), name, MAX_PATH)) { MessageBeep(MB_ICONHAND); return; }
    BOOL raus = steht_drin(name);

    enum { PLATZ = LISTE_MAX * 2 };   // jeder Name bekommt \r\n statt einer 0: höchstens doppelt so lang
    static WCHAR text[PLATZ];
    lstrcpyW(text, L"# Fadenkreuz nur zeigen, wenn eines dieser Programme vorne ist (eine exe pro Zeile).\r\n"
                   L"# Leer = immer zeigen. Strg+Alt+F10 im Programm nimmt es auf oder streicht es.\r\n");
    int laenge = lstrlenW(text);
    for (const WCHAR *p = g_liste; *p; p += lstrlenW(p) + 1) {
        int l = lstrlenW(p);
        if ((raus && lstrcmpW(p, name) == 0) || laenge + l + 3 >= PLATZ) continue;
        lstrcatW(text, p); lstrcatW(text, L"\r\n"); laenge += l + 2;
    }
    if (!raus && laenge + lstrlenW(name) + 3 < PLATZ) { lstrcatW(text, name); lstrcatW(text, L"\r\n"); }

    static char utf8[PLATZ * 3];
    int n = WideCharToMultiByte(CP_UTF8, 0, text, -1, utf8, sizeof utf8, NULL, NULL);
    if (n <= 0) { MessageBeep(MB_ICONHAND); return; }
    HANDLE f = CreateFileW(g_liste_pfad, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
    if (f == INVALID_HANDLE_VALUE) { MessageBeep(MB_ICONHAND); return; }
    DWORD geschrieben;
    WriteFile(f, utf8, (DWORD)(n - 1), &geschrieben, NULL);
    CloseHandle(f);

    lade_liste(TRUE);
    pruefe_vordergrund();
    MessageBeep(raus ? MB_ICONASTERISK : MB_OK);
}

// ---------- Fenster ----------

static LRESULT CALLBACK fenster(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp)
{
    switch (msg) {
    case WM_TIMER:
        lade(FALSE);
        lade_liste(FALSE);
        pruefe_vordergrund();   // setzt uns nebenbei wieder nach ganz oben
        return 0;
    case WM_HOTKEY:
        if (wp == HK_AN_AUS) { g_sichtbar = !g_sichtbar; zeige(); }
        else if (wp == HK_LISTE) liste_umschalten();
        else if (wp == HK_ENDE) DestroyWindow(hwnd);
        return 0;
    case WM_DISPLAYCHANGE:
    case WM_DPICHANGED:
    case WM_SETTINGCHANGE:
        zeichne();
        return 0;
    case WM_CLOSE:
        DestroyWindow(hwnd);
        return 0;
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcW(hwnd, msg, wp, lp);
}

static void ordner_von(WCHAR *pfad)     // schneidet hinter dem letzten \ ab
{
    WCHAR *schnitt = pfad;
    for (WCHAR *p = pfad; *p; p++) if (*p == L'\\' || *p == L'/') schnitt = p + 1;
    *schnitt = 0;
}

static void mit_strich(WCHAR *pfad)    // hängt \ an, falls er fehlt
{
    int n = lstrlenW(pfad);
    if (n && pfad[n - 1] != L'\\' && n < MAX_PATH - 1) { pfad[n] = L'\\'; pfad[n + 1] = 0; }
}

// datenordner.txt neben der exe: eine Zeile mit dem Ordner, %VARIABLEN% erlaubt.
static BOOL ordner_aus_verweis(const WCHAR *exe_ordner)
{
    WCHAR verweis[MAX_PATH];
    lstrcpynW(verweis, exe_ordner, MAX_PATH - 20);
    lstrcatW(verweis, L"datenordner.txt");
    DWORD groesse = 0;
    BYTE *d = lies_datei(verweis, 4096, &groesse);
    if (!d) return FALSE;
    BYTE *start = d;
    if (groesse >= 3 && d[0] == 0xEF && d[1] == 0xBB && d[2] == 0xBF) start += 3;
    WCHAR roh[MAX_PATH];
    int z = MultiByteToWideChar(CP_UTF8, 0, (char *)start, -1, roh, MAX_PATH);
    HeapFree(GetProcessHeap(), 0, d);
    if (z <= 0) return FALSE;
    int len = 0;
    while (roh[len] && roh[len] != L'\r' && roh[len] != L'\n') len++;   // nur die erste Zeile
    while (len && roh[len - 1] == L' ') len--;
    roh[len] = 0;
    if (!len || !ExpandEnvironmentStringsW(roh, g_ordner, MAX_PATH - 1)) return FALSE;
    mit_strich(g_ordner);
    return TRUE;
}

// Dokumente\Fadenkreuz – auch wenn OneDrive die Dokumente verschoben hat.
static void ordner_in_dokumenten(void)
{
    WCHAR dok[MAX_PATH];
    DWORD groesse = sizeof dok;
    // RRF_RT_REG_SZ nimmt auch REG_EXPAND_SZ an und liefert es schon aufgelöst.
    if (RegGetValueW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\User Shell Folders",
                     L"Personal", RRF_RT_REG_SZ, NULL, dok, &groesse) != ERROR_SUCCESS &&
        !ExpandEnvironmentStringsW(L"%USERPROFILE%\\Documents", dok, MAX_PATH))
        dok[0] = 0;
    lstrcpynW(g_ordner, dok, MAX_PATH - 16);
    mit_strich(g_ordner);
    lstrcatW(g_ordner, L"Fadenkreuz\\");
    CreateDirectoryW(g_ordner, NULL);       // gibt es ihn schon, passiert nichts
}

static void pfade(const WCHAR *arg)
{
    WCHAR a[MAX_PATH];
    while (*arg == L' ') arg++;
    if (*arg == L'"') arg++;
    lstrcpynW(a, arg, MAX_PATH);
    int n = lstrlenW(a);
    while (n && (a[n - 1] == L'"' || a[n - 1] == L' ')) a[--n] = 0;

    g_pfad[0] = 0;
    if (n) {
        DWORD attr = GetFileAttributesW(a);
        if (attr != INVALID_FILE_ATTRIBUTES && (attr & FILE_ATTRIBUTE_DIRECTORY)) {
            lstrcpynW(g_ordner, a, MAX_PATH - 1);
            mit_strich(g_ordner);
        } else {
            lstrcpynW(g_pfad, a, MAX_PATH);
            lstrcpynW(g_ordner, a, MAX_PATH);
            ordner_von(g_ordner);
        }
    } else {
        WCHAR exe[MAX_PATH];
        GetModuleFileNameW(NULL, exe, MAX_PATH);
        ordner_von(exe);
        if (!ordner_aus_verweis(exe)) {
            WCHAR neben[MAX_PATH];
            lstrcpynW(neben, exe, MAX_PATH - 16);
            lstrcatW(neben, L"fadenkreuz.bmp");
            if (GetFileAttributesW(neben) != INVALID_FILE_ATTRIBUTES) lstrcpynW(g_ordner, exe, MAX_PATH);   // tragbar
            else ordner_in_dokumenten();
        }
    }
    if (!g_pfad[0]) {
        lstrcpynW(g_pfad, g_ordner, MAX_PATH - 20);
        lstrcatW(g_pfad, L"fadenkreuz.bmp");
    }
    lstrcpynW(g_liste_pfad, g_ordner, MAX_PATH - 20);
    lstrcatW(g_liste_pfad, L"programme.txt");
}

static int haupt(HINSTANCE inst, const WCHAR *arg)
{
    // Zweiter Start beendet den ersten: so reicht eine Verknüpfung zum An- und Ausschalten.
    HWND alt = FindWindowW(KLASSE, NULL);
    if (alt) { PostMessageW(alt, WM_CLOSE, 0, 0); return 0; }

    // Echte Bildschirmpixel, sonst skaliert Windows das Kreuz unscharf hoch.
    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

    pfade(arg);

    WNDCLASSW wc = { 0 };
    wc.lpfnWndProc = fenster;
    wc.hInstance = inst;
    wc.lpszClassName = KLASSE;
    RegisterClassW(&wc);

    g_hwnd = CreateWindowExW(WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE,
                             KLASSE, L"Fadenkreuz", WS_POPUP, 0, 0, 0, 0, NULL, NULL, inst, NULL);
    if (!g_hwnd) return 1;

    lade(TRUE);
    lade_liste(TRUE);
    pruefe_vordergrund();
    SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, NULL, vordergrund_wechsel,
                    0, 0, WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS);
    RegisterHotKey(g_hwnd, HK_AN_AUS, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_F9);
    RegisterHotKey(g_hwnd, HK_LISTE, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_F10);
    RegisterHotKey(g_hwnd, HK_ENDE, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_F12);
    SetTimer(g_hwnd, TIMER_ID, 1000, NULL);
    SetProcessWorkingSetSize(GetCurrentProcess(), (SIZE_T)-1, (SIZE_T)-1);   // Startballast abgeben

    MSG m;
    while (GetMessageW(&m, NULL, 0, 0) > 0) DispatchMessageW(&m);
    return 0;
}

// Einsprung ohne C-Laufzeitbibliothek: Argumente hinter dem Programmnamen suchen.
void WINAPI start(void)
{
    const WCHAR *z = GetCommandLineW();
    if (*z == L'"') { z++; while (*z && *z != L'"') z++; if (*z) z++; }
    else while (*z && *z != L' ' && *z != L'\t') z++;
    while (*z == L' ' || *z == L'\t') z++;
    ExitProcess((UINT)haupt(GetModuleHandleW(NULL), z));
}
