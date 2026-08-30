import os
from PIL import Image, ImageDraw

def create_flutter_glyph(size=1024, transparent=False):
    scale = 2
    canvas_size = size * scale
    bg_color = (255, 255, 255, 0) if transparent else (255, 255, 255, 255)
    img = Image.new("RGBA", (canvas_size, canvas_size), bg_color)
    draw = ImageDraw.Draw(img)

    # Standard scale and offset to center the Flutter logo
    # For adaptive icon foreground, size is 108dp and safe zone is ~66dp (scale down by ~0.65)
    glyph_scale = 0.65 if transparent else 0.82
    
    # Center translation
    s = scale * glyph_scale
    ox = (canvas_size - (600 * s)) / 2 - (30 * s)
    oy = (canvas_size - (850 * s)) / 2

    # 1. Top-Right Chevron (Light Blue - #54C5F8)
    p_top = [
        (ox + 330 * s, oy + 80 * s),
        (ox + 600 * s, oy + 80 * s),
        (ox + 210 * s, oy + 470 * s),
        (ox + 75 * s,  oy + 470 * s),
    ]
    draw.polygon(p_top, fill=(84, 197, 248, 255))

    # 2. Middle Chevron (Medium Cyan/Blue - #29B6F6)
    p_mid = [
        (ox + 330 * s, oy + 470 * s),
        (ox + 600 * s, oy + 470 * s),
        (ox + 390 * s, oy + 680 * s),
        (ox + 185 * s, oy + 680 * s),
    ]
    draw.polygon(p_mid, fill=(41, 182, 246, 255))

    # 3. Bottom Chevron (Deep Blue - #01579B)
    p_bot = [
        (ox + 390 * s, oy + 680 * s),
        (ox + 600 * s, oy + 890 * s),
        (ox + 330 * s, oy + 890 * s),
        (ox + 185 * s, oy + 680 * s),
    ]
    draw.polygon(p_bot, fill=(1, 87, 155, 255))

    # 4. Overlap Shadow Trapeze (Dark Navy Blue - #0D47A1)
    p_shadow = [
        (ox + 390 * s, oy + 680 * s),
        (ox + 465 * s, oy + 605 * s),
        (ox + 510 * s, oy + 650 * s),
        (ox + 425 * s, oy + 715 * s),
    ]
    draw.polygon(p_shadow, fill=(13, 71, 161, 255))

    final_img = img.resize((size, size), Image.Resampling.LANCZOS)
    return final_img

def main():
    res_dir = "android/app/src/main/res"

    # 1. Standard Legacy Mipmap Icons (White background)
    legacy_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    base_legacy = create_flutter_glyph(1024, transparent=False)
    base_legacy.save("flutter_light_icon_1024.png", "PNG")

    for folder, dim in legacy_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        icon_resized = base_legacy.resize((dim, dim), Image.Resampling.LANCZOS)
        out_path = os.path.join(folder_path, "ic_launcher.png")
        icon_resized.save(out_path, "PNG")
        print(f"Generated {out_path} ({dim}x{dim})")

    # 2. Adaptive Foreground Icons (Transparent background, centered in 108dp canvas)
    adaptive_sizes = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }

    base_adaptive = create_flutter_glyph(1024, transparent=True)

    for folder, dim in adaptive_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        fg_resized = base_adaptive.resize((dim, dim), Image.Resampling.LANCZOS)
        out_path = os.path.join(folder_path, "ic_launcher_foreground.png")
        fg_resized.save(out_path, "PNG")
        print(f"Generated {out_path} ({dim}x{dim})")

    # 3. Create drawable background
    draw_dir = os.path.join(res_dir, "drawable")
    os.makedirs(draw_dir, exist_ok=True)
    bg_xml = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M0,0h108v108h-108z"/>
</vector>
"""
    with open(os.path.join(draw_dir, "ic_launcher_background.xml"), "w") as f:
        f.write(bg_xml)

    # 4. Create mipmap-anydpi-v26/ic_launcher.xml
    v26_dir = os.path.join(res_dir, "mipmap-anydpi-v26")
    os.makedirs(v26_dir, exist_ok=True)
    adaptive_xml = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
"""
    with open(os.path.join(v26_dir, "ic_launcher.xml"), "w") as f:
        f.write(adaptive_xml)
    print("Generated adaptive icon XMLs in drawable & mipmap-anydpi-v26")

if __name__ == "__main__":
    main()
