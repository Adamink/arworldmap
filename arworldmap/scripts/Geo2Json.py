from JsonImporter import JsonImporter

import os
import json

class Geo2Json:

    def __init__(self):
        self.geojson_file_pth = '../art.scnassets/country_shapes.geojson'
        self.output_file_pth = '../art.scnassets/country_shapes.json'
    
    def run(self):
        geojson = JsonImporter(self.geojson_file_pth).load()
        country_list = geojson['features']

        data = {}
        for country in country_list:
            name = country['properties']['cntry_name']
            coords = country['geometry']['coordinates']
            type = country['geometry']['type']
            
            if(type=='MultiPolygon'):
                borderlines = [[lonlat for lonlat in _[0]] for _ in coords]
            elif(type=='Polygon'):
                borderlines = [[lonlat for lonlat in coords[0]]]
            else:
                print("Skip " + name)
            print(name)
            print(type)
            data[name] =  {'name' : name, 'type' : type, 'borderlines' : borderlines}

        with open(self.output_file_pth, 'w') as outfile:
            json.dump(data, outfile)

if __name__=='__main__':
    Geo2Json().run()