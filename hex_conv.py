from PIL import Image

# Loading image and converting it to RGB
img = Image.open("bmp_24.bmp").convert("RGB")
width, height = img.size
pixels = list(img.getdata())

# --- Creating Metadata file ---
with open("image_meta.txt", "w") as meta_file:
    meta_file.write(f"WIDTH={width}\n")
    meta_file.write(f"HEIGHT={height}\n")
    meta_file.write("FORMAT=RGB888\n")

# --- Converting pixel data to hex file ---
with open("image.hex", "w") as hex_file:
    for r, g, b in pixels:
        hex_file.write("{:02X}{:02X}{:02X}\n".format(r, g, b))
