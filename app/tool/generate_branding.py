"""Genera los iconos de RadioTeleTaxi (logo oficial).

Diseño basado en el logo corporativo:
  - Círculo principal sólido en rojo RTT (#E53935)
  - Halo concéntrico más claro alrededor (#E53935 al 30%)
  - "RTT" blanco en negrita, fuente moderna, centrado

Salidas:
  assets/branding/app_icon.png             1024x1024 (icono completo)
  assets/branding/app_icon_foreground.png  1024x1024 (foreground adaptive)
  assets/branding/splash_logo.png          512x512   (splash)
"""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

RED_CORE = (229, 57, 53, 255)        # #E53935
RED_HALO = (229, 57, 53, 80)         # Halo concéntrico (~30% opacity)
RED_HALO_OUTER = (229, 57, 53, 30)   # Halo exterior aún más suave
WHITE = (255, 255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)

OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "branding"
OUT_DIR.mkdir(parents=True, exist_ok=True)


def _load_font(size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        r"C:\Windows\Fonts\arialbd.ttf",
        r"C:\Windows\Fonts\arial.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            return ImageFont.truetype(path, size=size)
    return ImageFont.load_default()


def _draw_text_centered(draw: ImageDraw.ImageDraw, size: int, text: str, color, offset_y=0.0):
    font_size = int(size * 0.34)
    font = _load_font(font_size)
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (size - w) // 2 - bbox[0]
    y = (size - h) // 2 - bbox[1] + int(size * offset_y)
    draw.text((x, y), text, font=font, fill=color)


def _draw_concentric_logo(draw: ImageDraw.ImageDraw, size: int):
    """Dibuja el logo RTT con anillos concéntricos (estilo logo corporativo)."""
    # Capas concéntricas, de fuera a dentro:
    # - Halo exterior  (~92%) → muy transparente
    # - Halo intermedio (~84%) → semitransparente
    # - Círculo sólido  (~74%) → opaco
    layers = [
        (0.92, RED_HALO_OUTER),
        (0.84, RED_HALO),
        (0.74, RED_CORE),
    ]
    for ratio, color in layers:
        margin = int(size * (1 - ratio) / 2)
        draw.ellipse((margin, margin, size - margin, size - margin), fill=color)


def render_main_icon(size: int = 1024) -> Path:
    """Icono cuadrado completo: fondo blanco + logo concéntrico + RTT centrado."""
    img = Image.new("RGBA", (size, size), WHITE)
    draw = ImageDraw.Draw(img)
    _draw_concentric_logo(draw, size)
    _draw_text_centered(draw, size, "RTT", WHITE)
    out = OUT_DIR / "app_icon.png"
    img.save(out, "PNG")
    return out


def render_adaptive_foreground(size: int = 1024) -> Path:
    """Adaptive foreground: logo dentro del 66% central (safe zone Android)."""
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    inner_size = int(size * 0.66)
    inner = Image.new("RGBA", (inner_size, inner_size), TRANSPARENT)
    inner_draw = ImageDraw.Draw(inner)
    _draw_concentric_logo(inner_draw, inner_size)
    _draw_text_centered(inner_draw, inner_size, "RTT", WHITE)
    offset = (size - inner_size) // 2
    img.paste(inner, (offset, offset), inner)
    out = OUT_DIR / "app_icon_foreground.png"
    img.save(out, "PNG")
    return out


def render_splash_logo(size: int = 512) -> Path:
    """Logo splash: logo concéntrico sobre fondo transparente."""
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    _draw_concentric_logo(draw, size)
    _draw_text_centered(draw, size, "RTT", WHITE)
    out = OUT_DIR / "splash_logo.png"
    img.save(out, "PNG")
    return out


def main() -> None:
    for fn in (render_main_icon, render_adaptive_foreground, render_splash_logo):
        path = fn()
        print(f"  wrote {path.relative_to(OUT_DIR.parent.parent)}  ({path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
