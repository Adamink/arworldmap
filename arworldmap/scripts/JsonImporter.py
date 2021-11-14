import json

class JsonImporter:
    def __init__(self, file_pth):
        self.file_pth = file_pth
    
    def load(self):
        with open(self.file_pth ,'r') as f:
            data = json.loads(f.read())
            return data