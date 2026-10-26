# Richtet das Fadenkreuz "über allem" ein. Das Setup ruft dieses Skript mit Adminrechten auf,
# wenn die Aufgabe "Über allem anzeigen" gewählt ist; beim Deinstallieren mit -Entfernen.
#
# Warum ein Zertifikat? Windows legt Fenster nur dann über Startmenü und Taskleiste, wenn das
# Programm "UIAccess" hat. Das bekommt nur ein signiertes Programm im Ordner "Programme".
# Dieses Skript legt dafür ein Zertifikat an, das nur auf diesem PC gilt, signiert
# fadenkreuz-oben.exe damit und löscht den privaten Schlüssel sofort wieder. Übrig bleibt nur
# der öffentliche Teil – damit kann niemand etwas anderes signieren.
# Klappt etwas nicht, bleibt die normale fadenkreuz.exe (immer oben, aber unter dem Startmenü).

param(
    [Parameter(Mandatory)][string]$Ordner,
    [switch]$Entfernen
)

$ErrorActionPreference = 'Stop'
$name = 'CN=Fadenkreuz (nur dieser PC)'

function Zertifikate-Entfernen {
    # Einzeln mit Pfad: über eine leere Pipeline kennt Windows PowerShell -DeleteKey nicht.
    foreach ($c in @(Get-ChildItem Cert:\LocalMachine\My | Where-Object Subject -eq $name)) {
        Remove-Item -LiteralPath $c.PSPath -DeleteKey
    }
    foreach ($c in @(Get-ChildItem Cert:\LocalMachine\Root | Where-Object Subject -eq $name)) {
        Remove-Item -LiteralPath $c.PSPath
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
    try {
        $cer = Join-Path $env:TEMP ("fadenkreuz-{0}.cer" -f [guid]::NewGuid())
        Export-Certificate -Cert $cert -FilePath $cer | Out-Null
        Import-Certificate -FilePath $cer -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
        Remove-Item -LiteralPath $cer
        $sig = Set-AuthenticodeSignature -FilePath $oben -Certificate $cert -HashAlgorithm SHA256
        if ($sig.Status -ne 'Valid') { throw "Signatur ungültig: $($sig.Status)" }
    } finally {
        Remove-Item -LiteralPath "Cert:\LocalMachine\My\$($cert.Thumbprint)" -DeleteKey
    }
    Move-Item -LiteralPath $oben -Destination $ziel -Force
    exit 0
} catch {
    Remove-Item -LiteralPath $oben -ErrorAction SilentlyContinue
    try { Zertifikate-Entfernen } catch { }
    exit 1
}
