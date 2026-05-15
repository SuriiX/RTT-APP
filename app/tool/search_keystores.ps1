# Busca todos los archivos que parezcan keystores en una ruta dada,
# y lista sus alias + SHA-256 para poder identificar el correcto.
#
# Uso típico:
#   .\search_keystores.ps1 -SearchPath "C:\"
#   .\search_keystores.ps1 -SearchPath "D:\Backups"
#
# Lista archivos .jks, .keystore, .p12, .pfx y para cada uno pide su SHA-256.
# Compara con la huella objetivo y marca los coincidentes con ✅.

param(
    [Parameter(Mandatory=$true)] [string]$SearchPath
)

$TARGET_SHA256 = "BF:84:C5:92:CD:69:A6:72:0F:AC:12:C9:68:B9:C7:55:59:80:5F:B9:D2:7F:DF:30:68:C7:FF:8D:64:3A:F6:75"

$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
if (-not (Test-Path $keytool)) {
    $keytool = "C:\Program Files\Java\jre1.8.0_461\bin\keytool.exe"
}

Write-Host "Buscando keystores en: $SearchPath" -ForegroundColor Cyan
Write-Host "(esto puede tardar varios minutos)" -ForegroundColor DarkGray
Write-Host ""

$candidates = Get-ChildItem -Path $SearchPath -Recurse -Include *.jks,*.keystore,*.p12,*.pfx -ErrorAction SilentlyContinue

if (-not $candidates -or $candidates.Count -eq 0) {
    Write-Host "No se encontró ningún .jks / .keystore / .p12 / .pfx en $SearchPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Candidatos encontrados ($($candidates.Count)):" -ForegroundColor Cyan
foreach ($c in $candidates) {
    Write-Host "  - $($c.FullName)  ($($c.Length) bytes, $($c.LastWriteTime))"
}
Write-Host ""

# Listado de contraseñas comunes a probar (la del default debug + típicas).
$commonPasswords = @("android", "changeit", "password", "")

foreach ($c in $candidates) {
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "→ $($c.FullName)" -ForegroundColor Yellow

    $opened = $false
    foreach ($pwd in $commonPasswords) {
        $out = & $keytool -list -v -keystore $c.FullName -storepass $pwd 2>$null
        if ($LASTEXITCODE -eq 0) {
            $opened = $true
            Write-Host "  (abierto con contraseña: '$pwd')" -ForegroundColor DarkGray
            $shaLines = $out | Select-String -Pattern "SHA256:"
            foreach ($l in $shaLines) {
                $sha = ($l -replace ".*SHA256:\s*", "").Trim()
                if ($sha -eq $TARGET_SHA256) {
                    Write-Host "  ✅ ✅ ✅  COINCIDE — $sha" -ForegroundColor Green
                } else {
                    Write-Host "  · $sha" -ForegroundColor DarkGray
                }
            }
            break
        }
    }
    if (-not $opened) {
        Write-Host "  🔒 No se pudo abrir con contraseñas comunes." -ForegroundColor Yellow
        Write-Host "     Usa verify_keystore.ps1 -KeystorePath '$($c.FullName)' para probar con contraseña manual." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Buscando coincidencia con: $TARGET_SHA256" -ForegroundColor Cyan
