import os
from PIL import Image

def process_image(input_path, output_path):
    img = Image.open(input_path)
    
    # Target size (16:9 for Play Store)
    target_width, target_height = 1920, 1080
    
    # Create a new background image (dark blue to match Vanto theme)
    bg = Image.new('RGB', (target_width, target_height), (15, 23, 42))
    
    # Calculate scale to fit the image inside the target dimensions
    scale = min(target_width / img.width, target_height / img.height)
    new_width = int(img.width * scale)
    new_height = int(img.height * scale)
    
    # Resize the original image
    resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Paste the resized image into the center of the background
    x_offset = (target_width - new_width) // 2
    y_offset = (target_height - new_height) // 2
    bg.paste(resized_img, (x_offset, y_offset))
    
    # Save the result
    bg.save(output_path, "JPEG", quality=95)
    print(f"Saved: {output_path}")

input_dir = "/home/lara/.gemini/antigravity/brain/b00c8967-15a1-4ac2-bb65-b430eb6336ff/"
output_dir = "/home/lara/veloxtv/google-play-assets/fixed-screenshots/"

os.makedirs(output_dir, exist_ok=True)

files = {
    "media__1784220438696.jpg": "screenshot-1-list-users.jpg",
    "media__1784220438703.jpg": "screenshot-2-add-playlist.jpg",
    "media__1784220438744.jpg": "screenshot-3-main-menu.jpg",
    "media__1784220438754.jpg": "screenshot-4-add-user.jpg"
}

for in_name, out_name in files.items():
    process_image(os.path.join(input_dir, in_name), os.path.join(output_dir, out_name))

