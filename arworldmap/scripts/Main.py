from Geojson2EquiRec import Converter
from Mask import maskImage
from glob import glob
import os

def main():
    Converter().run()
    img_pth = '../art.scnassets/earth_1620_810.png'
    mask_fd = '../art.scnassets/country_shape_masks/'
    output_fd = '../art.scnassets/country_shapes/'
    if not os.path.exists(output_fd):
        os.makedirs(output_fd)
    for mask_pth in glob(os.path.join(mask_fd, '*')):
        file_name = os.path.basename(mask_pth)
        output_pth = os.path.join(output_fd, file_name)
        maskImage(img_pth, mask_pth, output_pth)

if __name__ == '__main__':
    main()