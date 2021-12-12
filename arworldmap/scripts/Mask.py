from PIL import Image

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

if __name__=='__main__':
    img_pth = '../art.scnassets/Earth_BumpMap_2.jpg'
    mask_pth = '../art.scnassets/country_shapes/China.jpg'
    output_pth =  './China.png'
    maskImage(img_pth, mask_pth, output_pth)