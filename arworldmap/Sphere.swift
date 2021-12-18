import Foundation
import SceneKit

class Sphere {
    var sphereNode = SCNNode()
    var image_fd = "art.scnassets/country_shape_masks_alpha/"
    
    init() {
        self.createSphereNode()
    }
    
    func createSphereNode() {
        let sphere = SCNSphere(radius: 1)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/earth_1620_810.png")
        sphereMaterial.isDoubleSided = true
        sphere.materials = [sphereMaterial]
        
        self.sphereNode = SCNNode(geometry: sphere)
    }
    
    func addSphereNode(scene: SCNScene, pos: SCNVector3 = SCNVector3(0, -1, 0)) {
        self.sphereNode.position = pos
        scene.rootNode.addChildNode(self.sphereNode)
    }
    
    func selectCountry(country: String) {
        let mask_file = image_fd + country + ".png"
        sphereNode.geometry?.firstMaterial?.transparent.contents = UIImage(named: mask_file)
    }
}
