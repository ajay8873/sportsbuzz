import os
from PIL import Image
import numpy as np
from collections import deque

def generate_all_icons():
    source_path = r"C:\Users\sidag\.gemini\antigravity-ide\brain\7c0e3558-e229-43fb-88bc-7be7cd12ecf0\.user_uploaded\media_1788714521042.png"
    print(f"Loading source image from: {source_path}")
    raw_img = Image.open(source_path).convert("RGB")
    
    # Crop central logo region
    logo_crop = raw_img.crop((390, 155, 655, 405))
    crop_arr = np.array(logo_crop).astype(float)
    h, w, _ = crop_arr.shape

    # Distance from pure white
    diff = np.max(np.abs(crop_arr - 255.0), axis=2)

    # Flood-fill from outer edges where diff < 30
    visited = np.zeros((h, w), dtype=bool)
    q = deque()
    for y in range(h):
        for x in [0, w-1]:
            if diff[y, x] < 30:
                visited[y, x] = True
                q.append((y, x))
    for x in range(w):
        for y in [0, h-1]:
            if not visited[y, x] and diff[y, x] < 30:
                visited[y, x] = True
                q.append((y, x))

    while q:
        y, x = q.popleft()
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if diff[ny, nx] < 30:
                    visited[ny, nx] = True
                    q.append((ny, nx))

    # Create RGBA
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[~visited, :3] = crop_arr[~visited].astype(np.uint8)
    rgba[~visited, 3] = 255

    edge_mask = visited & (diff >= 3)
    edge_alpha = np.clip(1.0 - (crop_arr[edge_mask, 2] / 255.0), 0.0, 1.0)
    for c in range(3):
        channel = crop_arr[edge_mask, c]
        unmul = (channel - (1.0 - edge_alpha) * 255.0) / np.maximum(edge_alpha, 0.01)
        rgba[edge_mask, c] = np.clip(unmul, 0, 255).astype(np.uint8)
    rgba[edge_mask, 3] = np.clip(edge_alpha * 255.0, 0, 255).astype(np.uint8)

    transparent_logo = Image.fromarray(rgba, "RGBA")
    tight_bbox = transparent_logo.getbbox()
    tight_logo = transparent_logo.crop(tight_bbox)
    lw, lh = tight_logo.size
    print(f"Tight logo extracted: {lw}x{lh}")

    # 1. Master 1024x1024 Icon with white background
    master_1024 = Image.new("RGBA", (1024, 1024), (255, 255, 255, 255))
    target_dim = 710
    scale = target_dim / max(lw, lh)
    new_w = int(lw * scale)
    new_h = int(lh * scale)
    scaled_logo = tight_logo.resize((new_w, new_h), Image.Resampling.LANCZOS)
    pos_x = (1024 - new_w) // 2
    pos_y = (1024 - new_h) // 2
    master_1024.paste(scaled_logo, (pos_x, pos_y), scaled_logo)
    master_1024.save("zest_icon_1024.png", "PNG")
    print("Saved zest_icon_1024.png")

    # 2. Android Icons
    res_dir = "android/app/src/main/res"

    # Android Legacy Mipmap Icons
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
        resized = master_1024.resize((dim, dim), Image.Resampling.LANCZOS)
        out_path = os.path.join(folder_path, "ic_launcher.png")
        resized.save(out_path, "PNG")
        print(f"Android Legacy: {out_path} ({dim}x{dim})")

    # Android Adaptive Foreground Icons (108dp canvas, safe zone ~65%)
    adaptive_sizes = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }
    for folder, dim in adaptive_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        fg_canvas = Image.new("RGBA", (dim, dim), (255, 255, 255, 0))
        fg_target = int(dim * 0.65)
        fg_scale = fg_target / max(lw, lh)
        fg_w = int(lw * fg_scale)
        fg_h = int(lh * fg_scale)
        fg_scaled = tight_logo.resize((fg_w, fg_h), Image.Resampling.LANCZOS)
        fg_x = (dim - fg_w) // 2
        fg_y = (dim - fg_h) // 2
        fg_canvas.paste(fg_scaled, (fg_x, fg_y), fg_scaled)
        out_path = os.path.join(folder_path, "ic_launcher_foreground.png")
        fg_canvas.save(out_path, "PNG")
        print(f"Android Adaptive Foreground: {out_path} ({dim}x{dim})")

    # Android Adaptive Background XML
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

    # Android Adaptive XML in mipmap-anydpi-v26
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

    # 3. iOS Icons
    ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    if os.path.exists(ios_dir):
        ios_specs = [
            ("Icon-App-20x20@1x.png", 20),
            ("Icon-App-20x20@2x.png", 40),
            ("Icon-App-20x20@3x.png", 60),
            ("Icon-App-29x29@1x.png", 29),
            ("Icon-App-29x29@2x.png", 58),
            ("Icon-App-29x29@3x.png", 87),
            ("Icon-App-40x40@1x.png", 40),
            ("Icon-App-40x40@2x.png", 80),
            ("Icon-App-40x40@3x.png", 120),
            ("Icon-App-60x60@2x.png", 120),
            ("Icon-App-60x60@3x.png", 180),
            ("Icon-App-76x76@1x.png", 76),
            ("Icon-App-76x76@2x.png", 152),
            ("Icon-App-83.5x83.5@2x.png", 167),
            ("Icon-App-1024x1024@1x.png", 1024),
        ]
        for filename, dim in ios_specs:
            out_path = os.path.join(ios_dir, filename)
            # iOS requires RGB with no alpha channel for AppIcon
            rgb_icon = master_1024.convert("RGB").resize((dim, dim), Image.Resampling.LANCZOS)
            rgb_icon.save(out_path, "PNG")
            print(f"iOS Icon: {out_path} ({dim}x{dim})")

    # 4. Web Icons
    web_icons_dir = "web/icons"
    os.makedirs(web_icons_dir, exist_ok=True)
    web_sizes = {
        "Icon-192.png": 192,
        "Icon-512.png": 512,
        "Icon-maskable-192.png": 192,
        "Icon-maskable-512.png": 512,
    }
    for filename, dim in web_sizes.items():
        out_path = os.path.join(web_icons_dir, filename)
        resized = master_1024.resize((dim, dim), Image.Resampling.LANCZOS)
        resized.save(out_path, "PNG")
        print(f"Web Icon: {out_path} ({dim}x{dim})")

    # Favicon
    favicon_path = "web/favicon.png"
    fav = master_1024.resize((192, 192), Image.Resampling.LANCZOS)
    fav.save(favicon_path, "PNG")
    print(f"Web Favicon: {favicon_path}")

    # 5. Windows ICO
    win_res_dir = "windows/runner/resources"
    if os.path.exists(win_res_dir):
        ico_path = os.path.join(win_res_dir, "app_icon.ico")
        master_1024.save(ico_path, format="ICO", sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
        print(f"Windows ICO: {ico_path}")

    print("\nAll icons generated successfully!")

if __name__ == "__main__":
    generate_all_icons()
