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

class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var boxNode = SCNNode()
    var boxNode1 = SCNNode()
    var boxNode2 = SCNNode()
    var scene =  SCNScene()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
    var latitudeField: UITextField = UITextField()
    var longitudeField: UITextField = UITextField()
    
    var latitudeCountry = 0.0
    var longitudeCountry = 0.0
    
    var pos: SCNVector3 = SCNVector3()
    
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
        scene.rootNode.addChildNode(boxNode)
        

        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY

        let rect1 = CGRect(x: midX - 100, y: midY + 200, width: 200, height: 70)
        
        // search button
        let searchButton = UIButton(frame: rect1)
        searchButton.setTitle("Search Position", for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        let image = UIImage(named: "./art.scnassets/52016_preview.png")
        searchButton.setBackgroundImage(image, for: UIControl.State.normal)

        self.view.addSubview(searchButton)
        
        // Create UITextField
        latitudeField = UITextField(frame: CGRect(x: 20, y: midY + 100, width: self.view.bounds.width - 40, height: 40.00));
        latitudeField.placeholder = "Input latitude"
        latitudeField.borderStyle = UITextField.BorderStyle.line
        latitudeField.backgroundColor = UIColor.white
        latitudeField.textColor = UIColor.black
        latitudeField.keyboardType = .numberPad
        
        latitudeField.delegate = self
        latitudeField.returnKeyType = .done
        self.view.addSubview(latitudeField)
        
        longitudeField = UITextField(frame: CGRect(x: 20, y: midY + 140, width: self.view.bounds.width - 40, height: 40.00));
        longitudeField.placeholder = "Input longitude"
        longitudeField.borderStyle = UITextField.BorderStyle.line
        longitudeField.backgroundColor = UIColor.white
        longitudeField.textColor = UIColor.black
        longitudeField.keyboardType = .numberPad
        
        longitudeField.delegate = self
        longitudeField.returnKeyType = .done
        self.view.addSubview(longitudeField)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        latitudeField.resignFirstResponder()
        longitudeField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -200 // Move view 200 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    @objc func search(sender: UIButton!) {
        print("Touch search button")
        let latitude = latitudeField.text
        let longitude = longitudeField.text
        latitudeCountry = Double(latitude ?? "0") ?? 0.0
        longitudeCountry = Double(longitude ?? "0") ?? 0.0
        print(latitudeCountry)
        print(longitudeCountry)
        if (latitude?.isEmpty)!
        {
          // Display Alert dialog window if the TextField is empty
//            makeAlert("No latitude", message: "Please input latitude.", printStatement: "No latitude")
            print("empty")
            return
        }
        else
        {
            let currentLocation = self.locationManager.location?.coordinate
            print(currentLocation?.latitude ?? 0)
            print(currentLocation?.longitude ?? 0)
            pos = coordinateTransform(selfLat: currentLocation!.latitude, selfLon: currentLocation!.longitude, countryLat: latitudeCountry, countryLon: longitudeCountry)
            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
            // add box
            createBoxNode(pos: pos)
        }
        
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
            let pos = self.coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: -location.latitude, countryLon: 180+location.longitude)
            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
            // add box
            self.createBoxNode(pos: pos)
        }
    }
}
