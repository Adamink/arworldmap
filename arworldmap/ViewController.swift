//
//  ViewController.swift
//  arworldmap
//
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var boxNode = SCNNode()
    var boxNode1 = SCNNode()
    var boxNode2 = SCNNode()
    var scene =  SCNScene()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestWhenInUseAuthorization();
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else{
            print("Location service disabled");
        }
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //create a transparent gray layer
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0,0,-0.5)
        boxNode.eulerAngles = SCNVector3(0,60,0)
        scene.rootNode.addChildNode(boxNode)
        
//        boxNode1 = SCNNode(geometry: box)
//        boxNode1.position = SCNVector3(-0.5,0,0)
//        scene.rootNode.addChildNode(boxNode1)
//
//        boxNode2 = SCNNode(geometry: box)
//        boxNode2.position = SCNVector3(0,-0.5,0)
//        scene.rootNode.addChildNode(boxNode2)
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.delegate = self
    }
    /* This method creates only Text Nodes.
     */
    func createTextNode(title: String, size: CGFloat, x: Float, y: Float, z: Float){
        let text = SCNText(string: title, extrusionDepth: 0)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont(name: "Avenir Next", size: size)
        let textNode = SCNNode(geometry: text)
        textNode.position.x = boxNode.position.x - x
        textNode.position.y = boxNode.position.y - y
        textNode.position.z = boxNode.position.z - z
        scene.rootNode.addChildNode(textNode)
    }
    
    func createBoxNode(pos: SCNVector3){
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
        box.materials = [boxMaterial]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = pos
        scene.rootNode.addChildNode(boxNode)
    }
    
    func createSphereNode(pos: SCNVector3){
        let sphere = SCNSphere(radius: 1)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/China_small.png")
        sphereMaterial.isDoubleSided = true
        sphereMaterial.transparency = 1.0
        sphere.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = pos
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func coordinateTransform(selfLat: CLLocationDegrees, selfLon: CLLocationDegrees, countryLat: CLLocationDegrees, countryLon: CLLocationDegrees) -> SCNVector3 {
        let selfPosWorld = LatLonToXYZ(lat: selfLat, lon: selfLon)
        let countryPosWorld = LatLonToXYZ(lat: countryLat, lon: countryLon)
        var countryPosLocal = countryPosWorld - selfPosWorld
        var transMtx = makeRotationMatrixAlongZ(angle: 90-selfLon)
        transMtx = simd_mul(makeRotationMatrixAlongX(angle: -selfLat), transMtx)
        transMtx = simd_mul(makeRotationMatrixAlongY(angle: 180), transMtx)
        countryPosLocal = simd_mul(transMtx, countryPosLocal) // remove simd_normalize, change radius to change object size
        return SCNVector3(countryPosLocal.x, countryPosLocal.y, countryPosLocal.z)
    }
    
    func LatLonToXYZ(lat: CLLocationDegrees, lon: CLLocationDegrees) -> simd_double3 {
        let radius = 1.0 // can change
        let x = radius * cos(lat * Double.pi / 180) * cos(lon * Double.pi / 180)
        let y = radius * cos(lat * Double.pi / 180) * sin(lon * Double.pi / 180)
        let z = radius * sin(lat * Double.pi / 180)
        return simd_double3(x, y, z)
    }
    
    func XYZToLatLon(x: Double, y: Double, z: Double) -> simd_double2 {
        let radius = sqrt(x*x + y*y + z*z)
        let lat = asin(z / radius) * 180 / Double.pi
        let long = atan(y / x) * 180 / Double.pi
        return simd_double2(lat, long)
    }
    
    func makeRotationMatrixAlongX(angle: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(1,     0,      0),
            simd_double3(0,     cos(angle * Double.pi / 180), -sin(angle * Double.pi / 180)),
            simd_double3(0,     sin(angle * Double.pi / 180), cos(angle * Double.pi / 180))
        ]
        
        return simd_double3x3(rows: rows)
    }
    
    func makeRotationMatrixAlongY(angle: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(cos(angle * Double.pi / 180),    0,     sin(angle * Double.pi / 180)),
            simd_double3(0,     1,     0),
            simd_double3(-sin(angle * Double.pi / 180),   0,      cos(angle * Double.pi / 180))
        ]
        
        return simd_double3x3(rows: rows)
    }
    
    func makeRotationMatrixAlongZ(angle: Double) -> simd_double3x3 {
        let rows = [
            simd_double3(cos(angle * Double.pi / 180), -sin(angle * Double.pi / 180), 0),
            simd_double3(sin(angle * Double.pi / 180), cos(angle * Double.pi / 180), 0),
            simd_double3(0,          0,          1)
        ]
        
        return simd_double3x3(rows: rows)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = AROrientationTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
    }
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocationCoordinate2D = manager.location?.coordinate {
            print("Your location is \(location.latitude) \(location.longitude)")
            manager.stopUpdatingLocation()
            manager.delegate = nil
            // Just some test text
            self.createTextNode(title: "lat:\(location.latitude)", size: 1.8, x: 0, y: 9, z: 50)
            self.createTextNode(title: "lon:\(location.longitude)", size: 1.8, x: 0, y: 6, z: 50)
            self.createTextNode(title: "north", size: 1.8, x: 0, y: 0, z: 50)
            
            // hard code position
            // opposite side of the globe
            let leftLon = 73.554302
            let rightLon = 134.775703
            let topLat = 53.561780
            let bottomLat = 18.155060
            
            let pos = self.coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: bottomLat, countryLon: leftLon)
            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
            // add box
            // self.createBoxNode(pos: pos)
            self.createSphereNode(pos: SCNVector3(0, -1, 0))
        }
    }
}
