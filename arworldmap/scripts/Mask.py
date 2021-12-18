from PIL import Image, ImageOps
import numpy as np

def maskImage(img_pth: str, mask_pth: str, output_pth):
    img_file = Image.open(img_pth) # open colour image
    mask_file = Image.open(mask_pth)
    
    img = img_file.convert('RGBA')

    mask_data = mask_file.load()
    img_data = img.load()

    width, height = img.size
    for y in range(height):
        for x in range(width):
            if mask_data[x, y] == (0, 0, 0):
                img_data[x, y] = img_data[x, y][:3] + (0,)
    
    img.save(output_pth)

def genMask(mask_pth, output_pth):
    img_file = Image.open(mask_pth)
    # grayImage = img_file.convert('RGBA')
    alpha = img_file.convert('L')

    grayImage = Image.new('RGBA', img_file.size, color = 'black')
    grayImage.putalpha(alpha)
    grayImage.save(output_pth)

if __name__=='__main__':
    # mask_pth ='../art.scnassets/sun.jpg'
    mask_pth = '../art.scnassets/country_shape_masks/China.png'
    output_pth = '../art.scnassets/China_gray.png'
    genMask(mask_pth, output_pth)

    # img_file = Image.open(mask_pth)
    # grayImage = img_file.convert('RGBA')
    # alpha = img_file.convert('L')
    # grayImage.putalpha(alpha)
    # np.array(grayImage)