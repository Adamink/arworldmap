from JsonImporter import JsonImporter
from Drawer import Drawer

import os

class Converter:

    def __init__(self, img_size = (1620, 810)):
        self.geojson_file_pth = '../art.scnassets/country_shapes.geojson'
        self.output_fd = '../art.scnassets/country_shape_masks/'
        self.img_size = img_size

    def run(self):
        if not os.path.exists(self.output_fd):
            os.makedirs(self.output_fd)

        geojson = JsonImporter(self.geojson_file_pth).load()
        country_list = geojson['features']

        for country in country_list:
            name = country['properties']['cntry_name']
            coords = country['geometry']['coordinates']
            type = country['geometry']['type']

            output_pth = os.path.join(self.output_fd, name + '.png')
            drawer = Drawer(output_pth, color = (255, 255, 255), img_size = self.img_size)
            
            print(name)

            if(type=='MultiPolygon'):
                pts_list = [[self.lonlat2pos(lonlat) for lonlat in _[0]] for _ in coords]
                drawer.drawMultiPolygon(pts_list) 
            elif(type=='Polygon'):
                pts = [self.lonlat2pos(lonlat) for lonlat in coords[0]]
                drawer.drawPolygon(pts)
            else:
                print("Skip " + name)

    def lonlat2pos(self, lonlat:list):
        lon = lonlat[0]
        lat = lonlat[1]
        x = lon / 360. + 0.5 # left->right 0 -> 1
        y = -(lat / 180.) + 0.5 # up->down, 0 -> 1
        return (x, y)

if __name__=='__main__':
    Converter().run()