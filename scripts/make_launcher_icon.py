"""Generate QualityPilot launcher icon (multi-size .ico)."""
from PIL import Image, ImageDraw, ImageFont

SIZE = 512
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# rounded square with vertical gradient (deep blue -> cyan)
radius = 108
grad = Image.new("RGB", (1, SIZE))
for y in range(SIZE):
    t = y / (SIZE - 1)
    r = int(37 + (16 - 37) * t)
    g = int(99 + (185 - 99) * t)
    b = int(235 + (200 - 235) * t)
    grad.putpixel((0, y), (r, g, b))
grad = grad.resize((SIZE, SIZE))

mask = Image.new("L", (SIZE, SIZE), 0)
ImageDraw.Draw(mask).rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=255)
img.paste(grad, (0, 0), mask)

# subtle highlight arc
d = ImageDraw.Draw(img)
d.rounded_rectangle([18, 18, SIZE - 19, SIZE - 19], radius=radius - 14, outline=(255, 255, 255, 46), width=6)

# "QP" text
font = None
for path in (r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\segoeuib.ttf", r"C:\Windows\Fonts\arial.ttf"):
    try:
        font = ImageFont.truetype(path, 236)
        break
    except OSError:
        continue

text = "AT"
if font:
    box = d.textbbox((0, 0), text, font=font)
    tw, th = box[2] - box[0], box[3] - box[1]
    d.text(((SIZE - tw) / 2 - box[0], (SIZE - th) / 2 - box[1] - 26), text, font=font, fill=(255, 255, 255, 255))

# green check badge (bottom-right) = "test passed"
cx, cy, rr = 396, 400, 88
d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr], fill=(16, 185, 129, 255))
d.line([(cx - 44, cy + 2), (cx - 8, cy + 38), (cx + 48, cy - 40)], fill=(255, 255, 255, 255), width=26, joint="curve")

img.save("aitestlab.ico", sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
img.resize((256, 256), Image.LANCZOS).save("aitestlab.png")
print("icon generated")
