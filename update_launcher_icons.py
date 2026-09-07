import os
from PIL import Image

def update_all_launcher_icons():
    tight_logo = Image.open("assets/icons/app_icon.png").convert("RGBA")
    bbox = tight_logo.getbbox()
    if bbox:
        tight_logo = tight_logo.crop(bbox)
    lw, lh = tight_logo.size
    print(f"Using green logo: {lw}x{lh}")

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

    # 2. Android Icons
    res_dir = "android/app/src/main/res"

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

    # Web Icons
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

    favicon_path = "web/favicon.png"
    fav = master_1024.resize((192, 192), Image.Resampling.LANCZOS)
    fav.save(favicon_path, "PNG")

    print("All Android and Web launcher icons successfully updated with Cricbuzz Green!")

if __name__ == "__main__":
    update_all_launcher_icons()
