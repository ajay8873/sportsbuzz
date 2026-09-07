import os
import numpy as np
from PIL import Image
from collections import deque

def create_rich_green_icons():
    source_path = r'C:\Users\sidag\.gemini\antigravity-ide\brain\7c0e3558-e229-43fb-88bc-7be7cd12ecf0\.user_uploaded\media_1788714521042.png'
    raw_img = Image.open(source_path).convert('RGB')
    logo_crop = raw_img.crop((390, 155, 655, 405))
    arr = np.array(logo_crop).astype(float)
    h, w, _ = arr.shape

    # Distance from pure white background
    diff = np.max(np.abs(arr - 255.0), axis=2)

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

    fg = ~visited
    rgba = np.zeros((h, w, 4), dtype=np.uint8)

    # Compute luminosity from original orange logo
    orig_lum = (0.299 * arr[:,:,0] + 0.587 * arr[:,:,1] + 0.114 * arr[:,:,2]) / 255.0
    min_lum = orig_lum[fg].min()
    max_lum = orig_lum[fg].max()
    norm_lum = np.clip((orig_lum - min_lum) / (max_lum - min_lum + 1e-6), 0.0, 1.0)

    # Color gradient mapping to rich Cricbuzz Green (#009270):
    c_shadow = np.array([0.0, 75.0, 58.0])   # Dark stadium green
    c_mid = np.array([0.0, 146.0, 112.0])    # Signature Cricbuzz Green
    c_hi = np.array([12.0, 188.0, 145.0])    # Bright turf highlight
    c_spec = np.array([80.0, 225.0, 190.0])  # Soft specular shine

    recolored = np.zeros((h, w, 3), dtype=np.float32)
    for y in range(h):
        for x in range(w):
            if fg[y, x]:
                t = norm_lum[y, x]
                if t < 0.5:
                    f = t / 0.5
                    c = (1 - f) * c_shadow + f * c_mid
                elif t < 0.85:
                    f = (t - 0.5) / 0.35
                    c = (1 - f) * c_mid + f * c_hi
                else:
                    f = (t - 0.85) / 0.15
                    c = (1 - f) * c_hi + f * c_spec
                recolored[y, x] = c

    rgba[fg, :3] = np.clip(recolored[fg], 0, 255).astype(np.uint8)
    rgba[fg, 3] = 255

    # Smooth antialiasing on edges
    edge_mask = visited & (diff >= 4)
    alpha = np.clip(diff[edge_mask] / 30.0, 0.0, 1.0)
    rgba[edge_mask, :3] = c_mid.astype(np.uint8)
    rgba[edge_mask, 3] = (alpha * 255).astype(np.uint8)

    tight_logo = Image.fromarray(rgba, 'RGBA')
    tight_logo = tight_logo.crop(tight_logo.getbbox())
    lw, lh = tight_logo.size
    print(f"Extracted tight green logo: {lw}x{lh}")

    # 1. Save in-app asset: assets/icons/app_icon.png (high-res transparent 512x512)
    os.makedirs("assets/icons", exist_ok=True)
    inapp_icon = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    scale_512 = 470 / max(lw, lh)
    w_512, h_512 = int(lw * scale_512), int(lh * scale_512)
    scaled_inapp = tight_logo.resize((w_512, h_512), Image.Resampling.LANCZOS)
    inapp_icon.paste(scaled_inapp, ((512 - w_512) // 2, (512 - h_512) // 2), scaled_inapp)
    inapp_icon.save("assets/icons/app_icon.png", "PNG")
    print("Saved assets/icons/app_icon.png (rich Cricbuzz green)")

    # 2. Master launcher icon: 1024x1024 white background
    master_1024 = Image.new("RGBA", (1024, 1024), (255, 255, 255, 255))
    scale_1024 = 710 / max(lw, lh)
    w_1024, h_1024 = int(lw * scale_1024), int(lh * scale_1024)
    scaled_1024 = tight_logo.resize((w_1024, h_1024), Image.Resampling.LANCZOS)
    master_1024.paste(scaled_1024, ((1024 - w_1024) // 2, (1024 - h_1024) // 2), scaled_1024)
    master_1024.save("zest_icon_1024.png", "PNG")

    # 3. Android mipmap & adaptive drawables
    res_dir = "android/app/src/main/res"
    legacy_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, dim in legacy_sizes.items():
        fpath = os.path.join(res_dir, folder)
        os.makedirs(fpath, exist_ok=True)
        master_1024.resize((dim, dim), Image.Resampling.LANCZOS).save(os.path.join(fpath, "ic_launcher.png"), "PNG")

    adaptive_sizes = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432,
    }
    for folder, dim in adaptive_sizes.items():
        fpath = os.path.join(res_dir, folder)
        os.makedirs(fpath, exist_ok=True)
        fg_canvas = Image.new("RGBA", (dim, dim), (0, 0, 0, 0))
        fg_target = int(dim * 0.65)
        fg_scale = fg_target / max(lw, lh)
        fw, fh = int(lw * fg_scale), int(lh * fg_scale)
        scaled_fg = tight_logo.resize((fw, fh), Image.Resampling.LANCZOS)
        fg_canvas.paste(scaled_fg, ((dim - fw) // 2, (dim - fh) // 2), scaled_fg)
        fg_canvas.save(os.path.join(fpath, "ic_launcher_foreground.png"), "PNG")

    # 4. Web icons & Favicon
    web_dir = "web"
    web_icons = os.path.join(web_dir, "icons")
    os.makedirs(web_icons, exist_ok=True)

    master_1024.resize((32, 32), Image.Resampling.LANCZOS).save(os.path.join(web_dir, "favicon.png"), "PNG")
    master_1024.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-192.png"), "PNG")
    master_1024.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-512.png"), "PNG")
    master_1024.resize((192, 192), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-maskable-192.png"), "PNG")
    master_1024.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_icons, "Icon-maskable-512.png"), "PNG")
    print("All Android, Web, and in-app icons updated successfully to rich Cricbuzz Green!")

if __name__ == "__main__":
    create_rich_green_icons()
