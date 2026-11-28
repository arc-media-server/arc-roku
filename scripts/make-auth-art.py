"""Render the link and PIN tiles. Run with Pillow installed."""
from pathlib import Path

from PIL import Image, ImageDraw

output = Path(__file__).resolve().parents[1] / "src/images/auth"
output.mkdir(parents=True, exist_ok=True)

for name, width, height, radius, outline in (
    ("code", 166, 216, 24, 0),
    ("code-border", 166, 216, 24, 4),
    ("key", 120, 120, 30, 0),
    ("slot", 112, 112, 28, 0),
    ("slot-border", 112, 112, 28, 4),
):
    scale = 4
    size = (width * scale, height * scale)
    image = Image.new("RGBA", size)
    options = {"outline": "white", "width": outline * scale} if outline else {"fill": "white"}
    ImageDraw.Draw(image).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius * scale, **options
    )
    image.resize((width, height), Image.Resampling.LANCZOS).save(output / f"{name}.png")

# Backspace outline for TV fonts that don't contain the Unicode symbol.
delete = Image.new("RGBA", (44 * scale, 44 * scale))
draw = ImageDraw.Draw(delete)
for line in (
    [(3, 22), (13, 10), (40, 10), (40, 34), (13, 34), (3, 22)],
    [(19, 16), (31, 28)],
    [(31, 16), (19, 28)],
):
    draw.line([(x * scale, y * scale) for x, y in line], fill="white", width=3 * scale, joint="curve")
delete.resize((44, 44), Image.Resampling.LANCZOS).save(output / "delete.png")

# The low-frequency glow scales smoothly from half resolution.
background = Image.new("RGB", (960, 540))
background.putdata([
    tuple(round(base + lift * glow) for base, lift in ((14, 28), (14, 27), (18, 26)))
    for y in range(background.height)
    for x in range(background.width)
    for glow in [max(0, 1 - ((x - 480) / 515) ** 2 - (y / 448) ** 2) ** 2]
])
background.save(output / "background.jpg", quality=88, optimize=True)
