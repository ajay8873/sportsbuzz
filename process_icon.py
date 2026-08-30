import os
from PIL import Image

def process_app_icon(source_path):
    res_dir = "android/app/src/main/res"
    img = Image.open(source_path).convert("RGBA")

    # 1. Standard Legacy Mipmap Icons (full icon with padding)
    legacy_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    for folder, dim in legacy_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        icon_resized = img.resize((dim, dim), Image.Resampling.LANCZOS)
        out_path = os.path.join(folder_path, "ic_launcher.png")
        icon_resized.save(out_path, "PNG")
        print(f"Generated {out_path} ({dim}x{dim})")

    # 2. Adaptive Foreground Icons (Scale down to fit in 72dp safe zone of 108dp canvas)
    adaptive_sizes = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }

    # Create 108dp canvas with the centered logo scaled to ~75% so it doesn't get clipped by adaptive circular/squircle masks
    for folder, dim in adaptive_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # Transparent background for foreground layer
        fg_canvas = Image.new("RGBA", (dim, dim), (255, 255, 255, 0))
        
        # Inner logo size (72% of total canvas)
        inner_dim = int(dim * 0.76)
        inner_img = img.resize((inner_dim, inner_dim), Image.Resampling.LANCZOS)
        
        offset = (dim - inner_dim) // 2
        fg_canvas.paste(inner_img, (offset, offset), inner_img)
        
        out_path = os.path.join(folder_path, "ic_launcher_foreground.png")
        fg_canvas.save(out_path, "PNG")
        print(f"Generated {out_path} ({dim}x{dim})")

    # 3. Create Solid White Adaptive Background
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
    print("Updated adaptive icon XMLs")

if __name__ == "__main__":
    source = r"C:\Users\sidag\.gemini\antigravity-ide\brain\fade43d2-6e97-48d3-b54e-e2ef6840cdad\sportsbuzz_light_icon_1788123457919.jpg"
    process_app_icon(source)
