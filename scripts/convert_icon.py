import os
from PIL import Image

# Use hardcoded absolute paths for reliability
source_path = r"C:\Users\Angelo Toenbreker\.gemini\antigravity\brain\1a1a8b89-c1b6-4a26-8e16-74954020db32\media__1771499626929.png"
ico_dest = r"c:\Users\Angelo Toenbreker\StudioProjects\LEMON\windows\runner\resources\app_icon.ico"
png_dest = r"c:\Users\Angelo Toenbreker\StudioProjects\LEMON\assets\icon\icon.png"

def convert():
    if not os.path.exists(source_path):
        print(f"Error: Source file not found at {source_path}")
        return

    img = Image.open(source_path)
    
    # Convert to RGBA if necessary (JPG is RGB)
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    # Save as high-res PNG for flutter_launcher_icons
    print(f"Saving PNG to {png_dest}")
    img.save(png_dest, format='PNG')

    # Save as ICO with multiple sizes for Windows
    print(f"Saving ICO to {ico_dest}")
    icon_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    img.save(ico_dest, format='ICO', sizes=icon_sizes)
    
    print("Conversion complete!")

if __name__ == "__main__":
    convert()
