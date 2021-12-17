from PIL import Image

def resize(input_pth, output_pth, ratio = 0.1):
    img = Image.open(input_pth)
    width, height = img.size
    new_width = int(width * ratio)
    new_height = int(height * ratio)
    new_img = img.resize((new_width, new_height))
    new_img.save(output_pth)

if __name__=='__main__':
    input_pth = '../art.scnassets/earth_16200_8100.jpg'
    output_pth = '../art.scnassets/earth_1620_810.png'
    resize(input_pth, output_pth)