; Fadenkreuz – Installer für Inno Setup 6
; Bauen: bauen.bat im Hauptordner (ruft ISCC mit /DVersion=… auf).
; Fadenkreuz und Editor sind getrennte Komponenten und laufen unabhängig voneinander.

#ifndef Version
  #define Version "1.0.0"
#endif

[Setup]
; Eindeutige ID – nie ändern, sonst erkennt Windows Updates nicht als dieselbe App.
AppId={{6F3B9C2E-8A41-4D7E-9B15-2C64E0A7F8D1}
AppName=Fadenkreuz
AppVersion={#Version}
AppVerName=Fadenkreuz {#Version}
AppPublisher=Dennis_mit_2n
AppPublisherURL=https://dennismit2n.github.io/
AppSupportURL=https://github.com/Dennismit2n/fadenkreuz
AppUpdatesURL=https://github.com/Dennismit2n/fadenkreuz/releases
DefaultDirName={autopf}\Fadenkreuz
DisableProgramGroupPage=yes
; Ohne Adminrechte nur für den eigenen Benutzer; "für alle" fragt nach Admin
; und schaltet die Aufgabe "über allem" frei (UIAccess braucht den Ordner Programme).
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\build
OutputBaseFilename=Fadenkreuz-Setup-{#Version}
SetupIconFile=..\src\fadenkreuz.ico
UninstallDisplayIcon={app}\fadenkreuz.exe,0
UninstallDisplayName=Fadenkreuz
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
LicenseFile=..\LICENSE
VersionInfoVersion={#Version}
VersionInfoDescription=Fadenkreuz Setup

[Languages]
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
german.TypVoll=Fadenkreuz und Editor
english.TypVoll=Crosshair and editor
german.TypKreuz=Nur das Fadenkreuz
english.TypKreuz=Crosshair only
german.TypEditor=Nur den Editor
english.TypEditor=Editor only
german.TypEigene=Selbst auswählen
english.TypEigene=Custom selection
german.KomponenteKreuz=Fadenkreuz – das Overlay in der Bildschirmmitte (rund 1 MB RAM)
english.KomponenteKreuz=Crosshair – the overlay in the centre of the screen (about 1 MB of RAM)
german.KomponenteEditor=Editor – eigene Fadenkreuze zeichnen (braucht nur Speicher, solange er offen ist)
english.KomponenteEditor=Editor – draw your own crosshairs (only uses memory while it is open)
german.GruppeExtra=Zusätzlich:
english.GruppeExtra=Additionally:
german.AufgabeDesktop=Verknüpfungen auf dem Desktop
english.AufgabeDesktop=Desktop shortcuts
german.AufgabeAutostart=Fadenkreuz mit Windows starten
english.AufgabeAutostart=Start the crosshair with Windows
german.AufgabeOben=Über allem anzeigen – auch über Startmenü, Taskleiste und Overlays (legt ein Zertifikat an, das nur auf diesem PC gilt)
english.AufgabeOben=Show on top of everything – also above Start menu, taskbar and overlays (creates a certificate that is only valid on this PC)
german.StartKreuz=Fadenkreuz jetzt einschalten
english.StartKreuz=Switch the crosshair on now
german.StartEditor=Editor öffnen
english.StartEditor=Open the editor
german.StatusSignieren=Fadenkreuz wird für „über allem“ eingerichtet …
english.StatusSignieren=Setting up the crosshair to stay on top of everything …
german.KommentarKreuz=Fadenkreuz ein/aus – Strg+Alt+F9 blendet aus, Strg+Alt+F12 beendet
english.KommentarKreuz=Crosshair on/off – Ctrl+Alt+F9 hides it, Ctrl+Alt+F12 quits
german.KommentarEditor=Eigenes Fadenkreuz zeichnen
english.KommentarEditor=Draw your own crosshair

[Types]
Name: "voll"; Description: "{cm:TypVoll}"
Name: "kreuz"; Description: "{cm:TypKreuz}"
Name: "editor"; Description: "{cm:TypEditor}"
Name: "eigene"; Description: "{cm:TypEigene}"; Flags: iscustom

[Components]
Name: "kreuz"; Description: "{cm:KomponenteKreuz}"; Types: voll kreuz eigene
Name: "editor"; Description: "{cm:KomponenteEditor}"; Types: voll editor eigene

[Tasks]
Name: "desktop"; Description: "{cm:AufgabeDesktop}"; GroupDescription: "{cm:GruppeExtra}"
Name: "autostart"; Description: "{cm:AufgabeAutostart}"; GroupDescription: "{cm:GruppeExtra}"; Components: kreuz; Flags: unchecked
Name: "oben"; Description: "{cm:AufgabeOben}"; GroupDescription: "{cm:GruppeExtra}"; Components: kreuz; Flags: unchecked; Check: IsAdminInstallMode

[Files]
Source: "..\build\fadenkreuz.exe"; DestDir: "{app}"; Components: kreuz; Flags: ignoreversion
Source: "..\build\fadenkreuz-oben.exe"; DestDir: "{app}"; Components: kreuz; Tasks: oben; Flags: ignoreversion
Source: "ueber-allem.ps1"; DestDir: "{app}"; Components: kreuz; Tasks: oben; Flags: ignoreversion
Source: "..\editor\editor.html"; DestDir: "{app}\Editor"; Components: editor; Flags: ignoreversion
Source: "..\editor\editor-symbol.png"; DestDir: "{app}\Editor"; Components: editor; Flags: ignoreversion
Source: "..\editor\editor.ico"; DestDir: "{app}\Editor"; Components: editor; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; DestName: "LICENSE.txt"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\Fadenkreuz"; Filename: "{app}\fadenkreuz.exe"; Comment: "{cm:KommentarKreuz}"; Components: kreuz
Name: "{autodesktop}\Fadenkreuz"; Filename: "{app}\fadenkreuz.exe"; Comment: "{cm:KommentarKreuz}"; Components: kreuz; Tasks: desktop
Name: "{autostartup}\Fadenkreuz"; Filename: "{app}\fadenkreuz.exe"; Components: kreuz; Tasks: autostart
; Der Editor öffnet sich als eigenes, schlankes Edge-Fenster. Edge kann direkt in die Datei speichern.
Name: "{autoprograms}\Fadenkreuz-Editor"; Filename: "{code:EdgePfad}"; Parameters: "--app=""{code:EditorUrl}"""; IconFilename: "{app}\Editor\editor.ico"; Comment: "{cm:KommentarEditor}"; Components: editor; Check: EdgeDa
Name: "{autodesktop}\Fadenkreuz-Editor"; Filename: "{code:EdgePfad}"; Parameters: "--app=""{code:EditorUrl}"""; IconFilename: "{app}\Editor\editor.ico"; Comment: "{cm:KommentarEditor}"; Components: editor; Tasks: desktop; Check: EdgeDa
; Ohne Edge: im Standardbrowser öffnen (Chrome kann ebenfalls direkt speichern, andere laden herunter).
Name: "{autoprograms}\Fadenkreuz-Editor"; Filename: "{app}\Editor\editor.html"; IconFilename: "{app}\Editor\editor.ico"; Comment: "{cm:KommentarEditor}"; Components: editor; Check: not EdgeDa
Name: "{autodesktop}\Fadenkreuz-Editor"; Filename: "{app}\Editor\editor.html"; IconFilename: "{app}\Editor\editor.ico"; Comment: "{cm:KommentarEditor}"; Components: editor; Tasks: desktop; Check: not EdgeDa

[Run]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\ueber-allem.ps1"" -Ordner ""{app}"""; StatusMsg: "{cm:StatusSignieren}"; Components: kreuz; Tasks: oben; Flags: runhidden waituntilterminated
; shellexec: Die UIAccess-Fassung darf nur über die Shell gestartet werden (CreateProcess liefert Fehler 740).
Filename: "{app}\fadenkreuz.exe"; Description: "{cm:StartKreuz}"; Components: kreuz; Flags: nowait postinstall skipifsilent shellexec
Filename: "{code:EdgePfad}"; Parameters: "--app=""{code:EditorUrl}"""; Description: "{cm:StartEditor}"; Components: editor; Check: EdgeDa; Flags: nowait postinstall skipifsilent unchecked

[UninstallRun]
Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\ueber-allem.ps1"" -Ordner ""{app}"" -Entfernen"; Components: kreuz; Tasks: oben; Flags: runhidden waituntilterminated; RunOnceId: "ZertifikatEntfernen"

[UninstallDelete]
Type: files; Name: "{app}\fadenkreuz-oben.exe"
Type: files; Name: "{app}\ueber-allem.log"

[Code]
const
  WM_CLOSE = $0010;

function EdgePfad(Param: String): String;
begin
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe', '', Result) then
    if not RegQueryStringValue(HKCU, 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe', '', Result) then
      Result := '';
  if (Result = '') or not FileExists(Result) then
  begin
    Result := ExpandConstant('{commonpf32}\Microsoft\Edge\Application\msedge.exe');
    if not FileExists(Result) then
      Result := '';
  end;
end;

function EdgeDa: Boolean;
begin
  Result := EdgePfad('') <> '';
end;

function EditorUrl(Param: String): String;
var
  Pfad: String;
begin
  Pfad := ExpandConstant('{app}\Editor\editor.html');
  StringChangeEx(Pfad, '\', '/', True);
  StringChangeEx(Pfad, ' ', '%20', True);
  Result := 'file:///' + Pfad;
end;

// Ein laufendes Kreuz zuerst bitten, sich zu schließen, sonst ist fadenkreuz.exe gesperrt.
procedure KreuzBeenden;
var
  Fenster: HWND;
  I, Code: Integer;
begin
  Fenster := FindWindowByClassName('FadenkreuzOverlay');
  if Fenster = 0 then
    Exit;
  PostMessage(Fenster, WM_CLOSE, 0, 0);
  for I := 1 to 30 do
  begin
    Sleep(100);
    if FindWindowByClassName('FadenkreuzOverlay') = 0 then
      Exit;
  end;
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/IM fadenkreuz.exe /F', '', SW_HIDE, ewWaitUntilTerminated, Code);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  KreuzBeenden;
  Result := '';
end;

function InitializeUninstall(): Boolean;
begin
  KreuzBeenden;
  Result := True;
end;
