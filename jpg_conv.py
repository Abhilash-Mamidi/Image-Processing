# Reading the metadata
with open("image_meta.txt") as f:
    meta = dict(line.strip().split('=') for line in f)

width = int(meta['WIDTH'])
height = int(meta['HEIGHT'])

# Reading the pixel data
with open("output.hex") as f:
    hex_lines = f.read().splitlines()
pixels = [(int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)) for h in hex_lines]

# Recreating the image
from PIL import Image
img = Image.new("RGB", (width, height))
img.putdata(pixels[:width * height])
img.save("restored_image.bmp")
