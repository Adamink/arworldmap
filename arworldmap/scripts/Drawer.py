
import cv2 as cv
import numpy as np
from PIL import Image, ImageDraw
from scipy.spatial import ConvexHull

class Drawer:
    
    def __init__(self, file_pth, color = (255, 255, 255), img_size = (1620, 810)):
        self.file_pth = file_pth
        self.color = color
        self.img_size = img_size

    def drawPolygon(self, pts:list):
        try:
            im = Image.new('RGB', self.img_size, (0, 0, 0))
            draw = ImageDraw.Draw(im)
            pts_img = [(i[0] * self.img_size[0], i[1] * self.img_size[1]) for i in pts]
            draw.polygon(pts_img, fill=self.color, outline = self.color)
            im.save(self.file_pth)
        except:
            print('error')

    def drawMultiPolygon(self, pts_list:list):
        try:
            im = Image.new('RGB', self.img_size, (0, 0, 0))
            draw = ImageDraw.Draw(im)
            for pts in pts_list:
                pts_img = [(i[0] * self.img_size[0], i[1] * self.img_size[1]) for i in pts]
                draw.polygon(pts_img, fill=self.color, outline = self.color)
            im.save(self.file_pth)
        except:
            print('error')
