import os
import shutil
from PIL import Image

SIZES = {
    (57,    "Icon.png"),
    (114,   "Icon@2x.png"),
    (20,    "Icon-20.png"),
    (40,    "Icon-20@2x.png"),
    (60,    "Icon-20@3x.png"),
    (29,    "Icon-Small.png"),
    (58,    "Icon-Small@2x.png"),
    (87,    "Icon-Small@3x.png"),
    (40,    "Icon-Small-40.png"),
    (80,    "Icon-Small-40@2x.png"),
    (120,   "Icon-Small-40@3x.png"),
    (50,    "Icon-Small-50.png"),
    (100,   "Icon-Small-50@2x.png"),
    (120,   "Icon-60@2x.png"),
    (180,   "Icon-60@3x.png"),
    (72,    "Icon-72.png"),
    (144,   "Icon-72@2x.png"),
    (76,    "Icon-76.png"),
    (152,   "Icon-76@2x.png"),
    (167,   "Icon-83.5@2x.png"),
    (1024,  "Icon-Marketing.png")
}

ICON_FOLDER = "export/ios/spacecows/Images.xcassets/AppIcon.appiconset"

img = Image.open("icon-1024.png")
for size, name in SIZES:
    #icon = img.resize((size, size), Image.ANTIALIAS)
    icon = img.resize((size, size), Image.NEAREST)
    icon.save(os.path.join(ICON_FOLDER, name))
