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
; Immer dunkel, auch bei hellem Windows (Dennis' Wahl vom 01.11.2026). Bilder und Symbole
; tauscht Inno Setup dann selbst gegen die dunklen Fassungen.
WizardStyle=modern dark
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
LicenseFile=..\LICENSE
VersionInfoVersion={#Version}
VersionInfoDescription=Fadenkreuz Setup

[Languages]
; Englisch zuerst: Standard für jede Windows-Sprache, die hier fehlt.
; Hindi gibt es von Inno Setup nicht (nur eine inoffizielle Datei für 5.5.3). Hindi.isl daneben ist
; eine eigene, maschinelle Übersetzung der Default.isl von 6.7.3.
; Chinesisch ist die offizielle Inno-Übersetzung aus github.com/jrsoftware/issrc (Files/Languages),
; sie liegt hier daneben, weil Inno Setup 6.7 sie noch nicht mitbringt.
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "hindi"; MessagesFile: "Hindi.isl"
Name: "chinesesimplified"; MessagesFile: "ChineseSimplified.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[CustomMessages]
german.TypVoll=Fadenkreuz und Editor
english.TypVoll=Crosshair and editor
german.TypKreuz=Nur das Fadenkreuz
english.TypKreuz=Crosshair only
german.TypEditor=Nur den Editor
english.TypEditor=Editor only
german.TypEigene=Selbst auswählen
english.TypEigene=Custom selection
german.KomponenteKreuz=Fadenkreuz: das Overlay in der Bildschirmmitte (rund 1 MB RAM)
english.KomponenteKreuz=Crosshair: the overlay in the centre of the screen (about 1 MB of RAM)
german.KomponenteEditor=Editor: eigene Fadenkreuze zeichnen (braucht nur Speicher, solange er offen ist)
english.KomponenteEditor=Editor: draw your own crosshairs (only uses memory while it is open)
german.GruppeExtra=Zusätzlich:
english.GruppeExtra=Additionally:
german.AufgabeDesktop=Verknüpfungen auf dem Desktop
english.AufgabeDesktop=Desktop shortcuts
german.AufgabeAutostart=Fadenkreuz mit Windows starten
english.AufgabeAutostart=Start the crosshair with Windows
german.AufgabeOben=Über allem anzeigen, auch über Startmenü, Taskleiste und Overlays (legt ein Zertifikat an, das nur auf diesem PC gilt)
english.AufgabeOben=Show on top of everything, also above Start menu, taskbar and overlays (creates a certificate that is only valid on this PC)
german.StartKreuz=Fadenkreuz jetzt einschalten
english.StartKreuz=Switch the crosshair on now
german.StartEditor=Editor öffnen
english.StartEditor=Open the editor
german.StatusSignieren=Fadenkreuz wird für „über allem“ eingerichtet …
english.StatusSignieren=Setting up the crosshair to stay on top of everything …
german.KommentarKreuz=Fadenkreuz ein/aus: Strg+Alt+F9 blendet aus, Strg+Alt+F12 beendet
english.KommentarKreuz=Crosshair on/off: Ctrl+Alt+F9 hides it, Ctrl+Alt+F12 quits
german.KommentarEditor=Eigenes Fadenkreuz zeichnen
english.KommentarEditor=Draw your own crosshair
spanish.TypVoll=Punto de mira y editor
spanish.TypKreuz=Solo el punto de mira
spanish.TypEditor=Solo el editor
spanish.TypEigene=Elegir yo mismo
spanish.KomponenteKreuz=Punto de mira: el overlay en el centro de la pantalla (alrededor de 1 MB de RAM)
spanish.KomponenteEditor=Editor: dibuja tus propios puntos de mira (solo usa memoria mientras está abierto)
spanish.GruppeExtra=Además:
spanish.AufgabeDesktop=Accesos directos en el escritorio
spanish.AufgabeAutostart=Iniciar el punto de mira con Windows
spanish.AufgabeOben=Mostrar por encima de todo: también sobre el menú Inicio, la barra de tareas y los overlays (crea un certificado válido solo en este PC)
spanish.StartKreuz=Activar ahora el punto de mira
spanish.StartEditor=Abrir el editor
spanish.StatusSignieren=Preparando el punto de mira para quedar por encima de todo …
spanish.KommentarKreuz=Punto de mira sí/no: Ctrl+Alt+F9 lo oculta, Ctrl+Alt+F12 lo cierra
spanish.KommentarEditor=Dibujar tu propio punto de mira
french.TypVoll=Réticule et éditeur
french.TypKreuz=Seulement le réticule
french.TypEditor=Seulement l’éditeur
french.TypEigene=Choisir moi-même
french.KomponenteKreuz=Réticule : l’overlay au centre de l’écran (environ 1 Mo de RAM)
french.KomponenteEditor=Éditeur : dessiner vos propres réticules (n’utilise de la mémoire que lorsqu’il est ouvert)
french.GruppeExtra=En plus :
french.AufgabeDesktop=Raccourcis sur le bureau
french.AufgabeAutostart=Lancer le réticule avec Windows
french.AufgabeOben=Afficher au-dessus de tout : aussi au-dessus du menu Démarrer, de la barre des tâches et des overlays (crée un certificat valable uniquement sur ce PC)
french.StartKreuz=Activer le réticule maintenant
french.StartEditor=Ouvrir l’éditeur
french.StatusSignieren=Préparation du réticule pour rester au-dessus de tout …
french.KommentarKreuz=Réticule oui/non : Ctrl+Alt+F9 le masque, Ctrl+Alt+F12 le ferme
french.KommentarEditor=Dessiner votre propre réticule
italian.TypVoll=Mirino ed editor
italian.TypKreuz=Solo il mirino
italian.TypEditor=Solo l’editor
italian.TypEigene=Scelgo io
italian.KomponenteKreuz=Mirino: l’overlay al centro dello schermo (circa 1 MB di RAM)
italian.KomponenteEditor=Editor: disegna i tuoi mirini (usa memoria solo mentre è aperto)
italian.GruppeExtra=In più:
italian.AufgabeDesktop=Collegamenti sul desktop
italian.AufgabeAutostart=Avvia il mirino con Windows
italian.AufgabeOben=Mostra sopra a tutto: anche sopra il menu Start, la barra delle applicazioni e gli overlay (crea un certificato valido solo su questo PC)
italian.StartKreuz=Attiva subito il mirino
italian.StartEditor=Apri l’editor
italian.StatusSignieren=Preparo il mirino per stare sopra a tutto …
italian.KommentarKreuz=Mirino sì/no: Ctrl+Alt+F9 lo nasconde, Ctrl+Alt+F12 lo chiude
italian.KommentarEditor=Disegna il tuo mirino
dutch.TypVoll=Vizier en editor
dutch.TypKreuz=Alleen het vizier
dutch.TypEditor=Alleen de editor
dutch.TypEigene=Zelf kiezen
dutch.KomponenteKreuz=Vizier: de overlay in het midden van het scherm (ongeveer 1 MB RAM)
dutch.KomponenteEditor=Editor: zelf vizieren tekenen (gebruikt alleen geheugen zolang hij open is)
dutch.GruppeExtra=Daarnaast:
dutch.AufgabeDesktop=Snelkoppelingen op het bureaublad
dutch.AufgabeAutostart=Vizier met Windows starten
dutch.AufgabeOben=Boven alles tonen: ook boven het Startmenu, de taakbalk en overlays (maakt een certificaat dat alleen op deze pc geldt)
dutch.StartKreuz=Vizier nu aanzetten
dutch.StartEditor=Editor openen
dutch.StatusSignieren=Vizier wordt ingesteld om boven alles te blijven …
dutch.KommentarKreuz=Vizier aan/uit: Ctrl+Alt+F9 verbergt het, Ctrl+Alt+F12 sluit het af
dutch.KommentarEditor=Je eigen vizier tekenen
polish.TypVoll=Celownik i edytor
polish.TypKreuz=Tylko celownik
polish.TypEditor=Tylko edytor
polish.TypEigene=Wybór własny
polish.KomponenteKreuz=Celownik: nakładka na środku ekranu (około 1 MB RAM)
polish.KomponenteEditor=Edytor: rysuj własne celowniki (zajmuje pamięć tylko, gdy jest otwarty)
polish.GruppeExtra=Dodatkowo:
polish.AufgabeDesktop=Skróty na pulpicie
polish.AufgabeAutostart=Uruchamiaj celownik razem z Windows
polish.AufgabeOben=Pokazuj nad wszystkim: także nad menu Start, paskiem zadań i nakładkami (tworzy certyfikat ważny tylko na tym komputerze)
polish.StartKreuz=Włącz celownik teraz
polish.StartEditor=Otwórz edytor
polish.StatusSignieren=Celownik jest przygotowywany, żeby był nad wszystkim …
polish.KommentarKreuz=Celownik wł./wył.: Ctrl+Alt+F9 ukrywa, Ctrl+Alt+F12 zamyka
polish.KommentarEditor=Narysuj własny celownik
brazilianportuguese.TypVoll=Mira e editor
brazilianportuguese.TypKreuz=Só a mira
brazilianportuguese.TypEditor=Só o editor
brazilianportuguese.TypEigene=Escolher eu mesmo
brazilianportuguese.KomponenteKreuz=Mira: o overlay no centro da tela (cerca de 1 MB de RAM)
brazilianportuguese.KomponenteEditor=Editor: desenhe suas próprias miras (só usa memória enquanto está aberto)
brazilianportuguese.GruppeExtra=Além disso:
brazilianportuguese.AufgabeDesktop=Atalhos na área de trabalho
brazilianportuguese.AufgabeAutostart=Iniciar a mira com o Windows
brazilianportuguese.AufgabeOben=Mostrar acima de tudo: também acima do menu Iniciar, da barra de tarefas e de overlays (cria um certificado válido só neste PC)
brazilianportuguese.StartKreuz=Ligar a mira agora
brazilianportuguese.StartEditor=Abrir o editor
brazilianportuguese.StatusSignieren=Preparando a mira para ficar acima de tudo …
brazilianportuguese.KommentarKreuz=Mira liga/desliga: Ctrl+Alt+F9 esconde, Ctrl+Alt+F12 fecha
brazilianportuguese.KommentarEditor=Desenhar sua própria mira
turkish.TypVoll=Nişangah ve düzenleyici
turkish.TypKreuz=Yalnızca nişangah
turkish.TypEditor=Yalnızca düzenleyici
turkish.TypEigene=Kendim seçeceğim
turkish.KomponenteKreuz=Nişangah: ekranın ortasındaki katman (yaklaşık 1 MB RAM)
turkish.KomponenteEditor=Düzenleyici: kendi nişangahlarınızı çizin (yalnızca açıkken bellek kullanır)
turkish.GruppeExtra=Ek olarak:
turkish.AufgabeDesktop=Masaüstü kısayolları
turkish.AufgabeAutostart=Nişangahı Windows ile başlat
turkish.AufgabeOben=Her şeyin üstünde göster: Başlat menüsü, görev çubuğu ve katmanların da üstünde (yalnızca bu bilgisayarda geçerli bir sertifika oluşturur)
turkish.StartKreuz=Nişangahı şimdi aç
turkish.StartEditor=Düzenleyiciyi aç
turkish.StatusSignieren=Nişangah her şeyin üstünde kalacak şekilde ayarlanıyor …
turkish.KommentarKreuz=Nişangah aç/kapat: Ctrl+Alt+F9 gizler, Ctrl+Alt+F12 kapatır
turkish.KommentarEditor=Kendi nişangahınızı çizin
russian.TypVoll=Прицел и редактор
russian.TypKreuz=Только прицел
russian.TypEditor=Только редактор
russian.TypEigene=Выбрать самому
russian.KomponenteKreuz=Прицел: оверлей в центре экрана (около 1 МБ ОЗУ)
russian.KomponenteEditor=Редактор: рисуйте свои прицелы (занимает память, только пока открыт)
russian.GruppeExtra=Дополнительно:
russian.AufgabeDesktop=Ярлыки на рабочем столе
russian.AufgabeAutostart=Запускать прицел вместе с Windows
russian.AufgabeOben=Показывать поверх всего: также поверх меню «Пуск», панели задач и оверлеев (создаёт сертификат, действующий только на этом ПК)
russian.StartKreuz=Включить прицел сейчас
russian.StartEditor=Открыть редактор
russian.StatusSignieren=Прицел настраивается, чтобы быть поверх всего …
russian.KommentarKreuz=Прицел вкл./выкл.: Ctrl+Alt+F9 скрывает, Ctrl+Alt+F12 закрывает
russian.KommentarEditor=Нарисовать свой прицел
chinesesimplified.TypVoll=准星和编辑器
chinesesimplified.TypKreuz=仅准星
chinesesimplified.TypEditor=仅编辑器
chinesesimplified.TypEigene=自定义选择
chinesesimplified.KomponenteKreuz=准星：屏幕中央的覆盖层（约 1 MB 内存）
chinesesimplified.KomponenteEditor=编辑器：绘制你自己的准星（只在打开时占用内存）
chinesesimplified.GruppeExtra=附加：
chinesesimplified.AufgabeDesktop=桌面快捷方式
chinesesimplified.AufgabeAutostart=随 Windows 启动准星
chinesesimplified.AufgabeOben=显示在所有内容之上：也位于开始菜单、任务栏和覆盖层之上（会创建一个只在这台电脑上有效的证书）
chinesesimplified.StartKreuz=立即打开准星
chinesesimplified.StartEditor=打开编辑器
chinesesimplified.StatusSignieren=正在设置准星，使其显示在所有内容之上 …
chinesesimplified.KommentarKreuz=准星开/关：Ctrl+Alt+F9 隐藏，Ctrl+Alt+F12 退出
chinesesimplified.KommentarEditor=绘制你自己的准星
japanese.TypVoll=照準とエディター
japanese.TypKreuz=照準のみ
japanese.TypEditor=エディターのみ
japanese.TypEigene=自分で選ぶ
japanese.KomponenteKreuz=照準：画面中央のオーバーレイ（約 1 MB の RAM）
japanese.KomponenteEditor=エディター：自分の照準を描く（開いている間だけメモリを使います）
japanese.GruppeExtra=追加：
japanese.AufgabeDesktop=デスクトップのショートカット
japanese.AufgabeAutostart=Windows と一緒に照準を起動
japanese.AufgabeOben=すべての上に表示：スタート メニュー、タスクバー、オーバーレイの上にも表示（この PC だけで有効な証明書を作成します）
japanese.StartKreuz=今すぐ照準をオンにする
japanese.StartEditor=エディターを開く
japanese.StatusSignieren=照準を常に最前面に表示できるよう設定しています …
japanese.KommentarKreuz=照準のオン/オフ：Ctrl+Alt+F9 で隠し、Ctrl+Alt+F12 で終了
japanese.KommentarEditor=自分の照準を描く
korean.TypVoll=조준점과 편집기
korean.TypKreuz=조준점만
korean.TypEditor=편집기만
korean.TypEigene=직접 고르기
korean.KomponenteKreuz=조준점: 화면 가운데의 오버레이 (약 1 MB RAM)
korean.KomponenteEditor=편집기: 나만의 조준점 그리기 (열려 있는 동안만 메모리 사용)
korean.GruppeExtra=추가:
korean.AufgabeDesktop=바탕 화면 바로 가기
korean.AufgabeAutostart=Windows와 함께 조준점 시작
korean.AufgabeOben=모든 것 위에 표시: 시작 메뉴, 작업 표시줄, 오버레이 위에도 표시 (이 PC에서만 유효한 인증서를 만듭니다)
korean.StartKreuz=지금 조준점 켜기
korean.StartEditor=편집기 열기
korean.StatusSignieren=조준점이 모든 것 위에 있도록 설정하는 중 …
korean.KommentarKreuz=조준점 켜기/끄기: Ctrl+Alt+F9로 숨기고 Ctrl+Alt+F12로 종료
korean.KommentarEditor=나만의 조준점 그리기
hindi.TypVoll=क्रॉसहेयर और एडिटर
hindi.TypKreuz=केवल क्रॉसहेयर
hindi.TypEditor=केवल एडिटर
hindi.TypEigene=खुद चुनें
hindi.KomponenteKreuz=क्रॉसहेयर: स्क्रीन के बीच में ओवरले (लगभग 1 MB RAM)
hindi.KomponenteEditor=एडिटर: अपने खुद के क्रॉसहेयर बनाएँ (केवल खुला रहने पर मेमोरी लेता है)
hindi.GruppeExtra=अतिरिक्त:
hindi.AufgabeDesktop=डेस्कटॉप पर शॉर्टकट
hindi.AufgabeAutostart=Windows के साथ क्रॉसहेयर शुरू करें
hindi.AufgabeOben=सबसे ऊपर दिखाएँ: स्टार्ट मेनू, टास्कबार और ओवरले के ऊपर भी (एक प्रमाणपत्र बनाता है, जो केवल इसी PC पर मान्य है)
hindi.StartKreuz=क्रॉसहेयर अभी चालू करें
hindi.StartEditor=एडिटर खोलें
hindi.StatusSignieren=क्रॉसहेयर को सबसे ऊपर रहने के लिए सेट किया जा रहा है …
hindi.KommentarKreuz=क्रॉसहेयर चालू/बंद: Ctrl+Alt+F9 छिपाता है, Ctrl+Alt+F12 बंद करता है
hindi.KommentarEditor=अपना खुद का क्रॉसहेयर बनाएँ

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
