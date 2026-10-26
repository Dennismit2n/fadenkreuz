# Richtet das Fadenkreuz "über allem" ein. Das Setup ruft dieses Skript mit Adminrechten auf,
# wenn die Aufgabe "Über allem anzeigen" gewählt ist; beim Deinstallieren mit -Entfernen.
#
# Warum ein Zertifikat? Windows legt Fenster nur dann über Startmenü und Taskleiste, wenn das
# Programm "UIAccess" hat. Das bekommt nur ein signiertes Programm im Ordner "Programme".
# Dieses Skript legt dafür ein Zertifikat an, das nur auf diesem PC gilt, signiert
# fadenkreuz-oben.exe damit und löscht den privaten Schlüssel sofort wieder. Übrig bleibt nur
# der öffentliche Teil – damit kann niemand etwas anderes signieren.
# Klappt etwas nicht, bleibt die normale fadenkreuz.exe (immer oben, aber unter dem Startmenü).
# Jeder Lauf schreibt ueber-allem.log daneben.

param(
    [Parameter(Mandatory)][string]$Ordner,
    [switch]$Entfernen
)

$ErrorActionPreference = 'Stop'
$name = 'CN=Fadenkreuz (nur dieser PC)'
$protokoll = [IO.Path]::Combine($Ordner, 'ueber-allem.log')

# Protokoll mit reinem .NET: es muss auch dann schreiben, wenn ein Modul nicht lädt.
function Notiz([string]$text) {
    try { [IO.File]::AppendAllText($protokoll, ('{0:HH:mm:ss}  {1}' -f [DateTime]::Now, $text) + "`r`n", [Text.Encoding]::UTF8) } catch { }
}
try { [IO.File]::WriteAllText($protokoll, '', [Text.Encoding]::UTF8) } catch { }
Notiz ("Fadenkreuz – über allem anzeigen ({0}), PowerShell {1}, {2} Bit, {3}" -f `
    $(if ($Entfernen) { 'entfernen' } else { 'einrichten' }), $PSVersionTable.PSVersion,
    $(if ([Environment]::Is64BitProcess) { 64 } else { 32 }), $ExecutionContext.SessionState.LanguageMode)

# Ist PowerShell 7 installiert, kann dessen Modulpfad vor dem von Windows PowerShell stehen.
# Dann lädt 5.1 die falsche Fassung des Sicherheitsmoduls nicht, und das Laufwerk Cert: fehlt
# ("Laufwerk nicht gefunden"). Darum: eigener Modulpfad, Module mit vollem Pfad aus $PSHOME.
$env:PSModulePath = "$PSHOME\Modules;$env:ProgramFiles\WindowsPowerShell\Modules"
foreach ($modul in 'Microsoft.PowerShell.Security', 'PKI') {
    try { Import-Module (Join-Path $PSHOME "Modules\$modul\$modul.psd1") -ErrorAction Stop }
    catch { Notiz "Modul $modul lädt nicht: $($_.Exception.Message)" }
}
if (-not (Get-PSDrive Cert -ErrorAction SilentlyContinue)) { Notiz 'Laufwerk Cert: fehlt trotz Modul'; exit 1 }

# Alte Fadenkreuz-Zertifikate entfernen – direkt über den Windows-Speicher und nie fatal:
# ein übrig gebliebener öffentlicher Teil ohne Schlüssel schadet niemandem.
function Zertifikate-Entfernen {
    foreach ($ablage in 'My', 'Root') {
        try {
            $speicher = New-Object System.Security.Cryptography.X509Certificates.X509Store($ablage, 'LocalMachine')
            $speicher.Open('ReadWrite')
            foreach ($c in @($speicher.Certificates | Where-Object Subject -eq $name)) {
                if ($c.HasPrivateKey) {
                    try { Remove-Item -LiteralPath "Cert:\LocalMachine\$ablage\$($c.Thumbprint)" -DeleteKey } catch { Notiz "Schlüssel von $($c.Thumbprint) nicht gelöscht: $($_.Exception.Message)" }
                }
                $speicher.Remove($c)
                Notiz "altes Zertifikat $($c.Thumbprint) aus $ablage entfernt"
            }
            $speicher.Close()
        } catch {
            Notiz "Aufräumen in $ablage ging nicht: $($_.Exception.Message)"
        }
    }
}

if ($Entfernen) {
    Zertifikate-Entfernen
    exit 0
}

$oben = Join-Path $Ordner 'fadenkreuz-oben.exe'
$ziel = Join-Path $Ordner 'fadenkreuz.exe'
try {
    Zertifikate-Entfernen
    $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject $name -CertStoreLocation Cert:\LocalMachine\My `
            -KeyExportPolicy NonExportable -NotAfter (Get-Date).AddYears(30)
    Notiz "neues Zertifikat $($cert.Thumbprint)"
    try {
        $speicher = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root', 'LocalMachine')
        $speicher.Open('ReadWrite')
        $speicher.Add([System.Security.Cryptography.X509Certificates.X509Certificate2]::new($cert.RawData))
        $speicher.Close()
        Notiz 'öffentlicher Teil als vertrauenswürdig eingetragen'
        $sig = Set-AuthenticodeSignature -FilePath $oben -Certificate $cert -HashAlgorithm SHA256
        if ($sig.Status -ne 'Valid') { throw "Signatur ungültig: $($sig.Status) $($sig.StatusMessage)" }
        Notiz 'fadenkreuz-oben.exe signiert'
    } finally {
        Remove-Item -LiteralPath "Cert:\LocalMachine\My\$($cert.Thumbprint)" -DeleteKey
        Notiz 'privater Schlüssel gelöscht'
    }
    Move-Item -LiteralPath $oben -Destination $ziel -Force
    Notiz 'fertig: fadenkreuz.exe ist jetzt die UIAccess-Fassung'
    exit 0
} catch {
    Notiz "FEHLER: $($_.Exception.Message)"
    Notiz ($_.ScriptStackTrace)
    Remove-Item -LiteralPath $oben -ErrorAction SilentlyContinue
    Zertifikate-Entfernen
    Notiz 'normale Fassung bleibt'
    exit 1
}
