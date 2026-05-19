from PIL import Image
import os

def crop_icon(input_path, output_path):
    print(f"Opening {input_path}...")
    img = Image.open(input_path)
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    # Get the bounding box of the non-transparent part of the image
    bbox = img.getbbox()
    if bbox:
        print(f"Found bounding box: {bbox}")
        # Crop to the bounding box
        cropped_img = img.crop(bbox)
        
        # Make it square by adding padding if necessary (optional, but good for icons)
        width, height = cropped_img.size
        new_size = max(width, height)
        square_img = Image.new('RGBA', (new_size, new_size), (0, 0, 0, 0))
        offset = ((new_size - width) // 2, (new_size - height) // 2)
        square_img.paste(cropped_img, offset)
        
        print(f"Saving cropped and squared icon to {output_path}...")
        square_img.save(output_path)
        print("Done!")
    else:
        print("No non-transparent content found!")

if __name__ == "__main__":
    current_dir = os.getcwd()
    input_file = os.path.join(current_dir, "assets", "icon", "icon.png")
    output_file = os.path.join(current_dir, "assets", "icon", "icon_cropped.png")
    crop_icon(input_file, output_file)
