Add-Type -AssemblyName System.Drawing

function New-RttIcon {
    param(
        [int]$Size,
        [string]$Path,
        [string]$BgHex,
        [string]$FgHex = "#FFFFFF",
        [bool]$Transparent = $false,
        [bool]$ForegroundLayer = $false
    )

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    if ($Transparent) {
        $g.Clear([System.Drawing.Color]::Transparent)
    } else {
        $bg = [System.Drawing.ColorTranslator]::FromHtml($BgHex)
        $g.Clear($bg)
    }

    # Inner content area: for adaptive foreground we keep content in the safe zone (~66% center).
    if ($ForegroundLayer) {
        $padding = [int]($Size * 0.22)
    } else {
        $padding = [int]($Size * 0.10)
    }
    $rectSize = $Size - ($padding * 2)

    $fg = [System.Drawing.ColorTranslator]::FromHtml($FgHex)
    $brush = New-Object System.Drawing.SolidBrush($fg)

    # Draw a circle behind the text for a cleaner mark.
    if (-not $ForegroundLayer) {
        $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $circleRect = New-Object System.Drawing.RectangleF($padding, $padding, $rectSize, $rectSize)
        $g.FillEllipse($whiteBrush, $circleRect)
        $whiteBrush.Dispose()
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($BgHex))
    } else {
        $textBrush = $brush
    }

    $fontSize = [int]($Size * 0.30)
    $font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $textRect = New-Object System.Drawing.RectangleF(0, 0, $Size, $Size)
    $g.DrawString("RTT", $font, $textBrush, $textRect, $sf)

    $textBrush.Dispose()
    $brush.Dispose()
    $font.Dispose()
    $g.Dispose()

    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Generated: $Path ($Size x $Size)"
}

# Master icon (1024x1024) — used by flutter_launcher_icons for all sizes.
New-RttIcon -Size 1024 -Path "assets\branding\app_icon.png" -BgHex "#E53935"

# Adaptive icon foreground (transparent background, "RTT" centered).
New-RttIcon -Size 1024 -Path "assets\branding\app_icon_foreground.png" -BgHex "#E53935" -Transparent $true -ForegroundLayer $true

# Splash logo (white "RTT" with no background → splash color paints the rest).
New-RttIcon -Size 512 -Path "assets\branding\splash_logo.png" -BgHex "#E53935" -Transparent $true -ForegroundLayer $true

Write-Host "Done."
