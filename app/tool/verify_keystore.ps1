# Verifica si un keystore (.jks / .keystore / .pem) coincide con la firma
# de la app "Radio TeleTaxi - Oficial" (com.radioteletaxi.app) en Play Console.
#
# Uso:
#   .\verify_keystore.ps1 -KeystorePath "C:\ruta\al\posible.jks"
#                         -Password    "contraseña"   (opcional, pregunta si no se pasa)
#                         -Alias       "nombre"        (opcional, prueba todos los alias si no se pasa)
#
# Salida:
#   ✅ Si el SHA-256 de algún alias coincide → ESTE ES EL KEYSTORE QUE BUSCAMOS.
#   ❌ Si no coincide → seguir buscando en otros sitios.

param(
    [Parameter(Mandatory=$true)] [string]$KeystorePath,
    [string]$Password = "",
    [string]$Alias = ""
)

$TARGET_SHA256 = "BF:84:C5:92:CD:69:A6:72:0F:AC:12:C9:68:B9:C7:55:59:80:5F:B9:D2:7F:DF:30:68:C7:FF:8D:64:3A:F6:75"

$keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
if (-not (Test-Path $keytool)) {
    $keytool = "C:\Program Files\Java\jre1.8.0_461\bin\keytool.exe"
}
if (-not (Test-Path $keytool)) {
    Write-Host "ERROR: no encuentro keytool.exe" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $KeystorePath)) {
    Write-Host "ERROR: no existe el archivo: $KeystorePath" -ForegroundColor Red
    exit 1
}

if ($Password -eq "") {
    $secure = Read-Host "Contraseña del keystore" -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Comprobando keystore: $KeystorePath" -ForegroundColor Cyan
Write-Host "Buscando SHA-256:     $TARGET_SHA256" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 1) Listar los alias del keystore
$listing = & $keytool -list -keystore $KeystorePath -storepass $Password 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR al abrir el keystore. ¿Contraseña incorrecta?" -ForegroundColor Red
    Write-Host $listing
    exit 1
}

$aliases = @()
if ($Alias -ne "") {
    $aliases = @($Alias)
} else {
    # Extraer alias del listado
    foreach ($line in $listing) {
        if ($line -match '^([\w\-\.]+),\s+\S+\s+\d+,\s+\d{4}') {
            $aliases += $Matches[1]
        }
    }
}

if ($aliases.Count -eq 0) {
    Write-Host "❌ No se encontraron alias en el keystore." -ForegroundColor Red
    exit 1
}

Write-Host "Alias encontrados: $($aliases -join ', ')" -ForegroundColor Yellow
Write-Host ""

$found = $false
foreach ($a in $aliases) {
    Write-Host "→ Comprobando alias '$a'..." -ForegroundColor Yellow
    $details = & $keytool -list -v -keystore $KeystorePath -alias $a -storepass $Password 2>$null
    $sha256Line = $details | Select-String -Pattern "SHA256:" | Select-Object -First 1
    if (-not $sha256Line) {
        Write-Host "   (no se pudo extraer SHA-256)" -ForegroundColor DarkGray
        continue
    }
    $sha = ($sha256Line -replace ".*SHA256:\s*", "").Trim()
    Write-Host "   SHA-256: $sha" -ForegroundColor White

    if ($sha -eq $TARGET_SHA256) {
        Write-Host ""
        Write-Host "✅✅✅ COINCIDENCIA — este es el keystore correcto." -ForegroundColor Green
        Write-Host "   Archivo: $KeystorePath" -ForegroundColor Green
        Write-Host "   Alias:   $a" -ForegroundColor Green
        Write-Host "✅✅✅" -ForegroundColor Green
        $found = $true
        break
    } else {
        Write-Host "   ❌ no coincide" -ForegroundColor Red
    }
}

if (-not $found) {
    Write-Host ""
    Write-Host "❌ Ningún alias de este keystore coincide con la firma esperada." -ForegroundColor Red
    Write-Host "   Sigue buscando en otros archivos." -ForegroundColor Red
}
