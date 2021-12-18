//
//  SearchLatLonViewController.swift
//  arworldmap
//
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import CoreLocation
import DropDown

class SearchLatLonViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, CLLocationManagerDelegate, UITextFieldDelegate{
    
    var searchView: ARSCNView!
    
    var sceneSetting =  SCNScene()
    var sphereNode = SCNNode()
    var markersAnchorNode = SCNNode()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
    var latitudeField: UITextField = UITextField()
    var longitudeField: UITextField = UITextField()
    
    var countryField: UITextField = UITextField()
    
    var latitudeCountry = 0.0
    var longitudeCountry = 0.0
    
    var curLatitude = 0.0
    var curLongitude = 0.0
    
    var pos: SCNVector3 = SCNVector3()
    
    var searchButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .blue
        // Do any additional setup after loading the view.
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
        searchView?.delegate = self
        
        // Show statistics such as fps and timing information
        searchView?.showsStatistics = true
        
        // Set the scene to the view
        searchView?.scene = sceneSetting
        
        // add search button
        addButton()
        
        // Create UITextField
        addTextfield()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
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
        if (searchButton.titleLabel?.text == "Search Position") {
            print("Touch search button")
            let latitude = latitudeField.text
            let longitude = longitudeField.text
            latitudeCountry = Double(latitude ?? "0") ?? 0.0
            longitudeCountry = Double(longitude ?? "0") ?? 0.0
            print(latitudeCountry)
            print(longitudeCountry)
            let currentLocation = self.locationManager.location?.coordinate
            
            if (latitude?.isEmpty)!
            {
              // Display Alert dialog window if the TextField is empty
    //            makeAlert("No latitude", message: "Please input latitude.", printStatement: "No latitude")
                print("empty")
                return
            }
    
            getCountry(lat: latitudeCountry, lon: longitudeCountry)
            latitudeField.removeFromSuperview()
            longitudeField.removeFromSuperview()
//            self.sceneSetting.rootNode.addChildNode(anchorNode)
            searchButton.setTitle("Back", for: .normal)
            
        }
        else if (searchButton.titleLabel?.text == "Back") {
            self.view.addSubview(latitudeField)
            self.view.addSubview(longitudeField)
//            anchorNode.removeFromParentNode()
            searchButton.setTitle("Search Position", for: .normal)
        }
    }
    
    func getCountry(lat: Double, lon: Double) {
        let tmpCLGeocoder = CLGeocoder.init()
        let tmpDataLoc = CLLocation.init(latitude: lat, longitude: lon)
        let language_loc = Locale(identifier: "en_US")
        tmpCLGeocoder.reverseGeocodeLocation(tmpDataLoc, preferredLocale: language_loc, completionHandler: {(placemarks,error) in

            guard let tmpPlacemarks = placemarks else{
                print("error get placemark")
                return
            }
            let placeMark = tmpPlacemarks[0] as CLPlacemark

            // Country
            guard let countryLocality = placeMark.country else{
                print("error get country")
                self.countryField.text = "This position doesn't belong to any country"
                return
            }

            // City
            guard let cityLocality = placeMark.locality else{
                print("error get city")
                if (countryNames.contains(countryLocality))
                {
                    print("find corresponding country")
                    self.countryField.text = "This position is in \(countryLocality)"
                    self.changeSphereTexture(countryName: countryLocality)
                    self.createPlaceMarkerNode(lat: lat, lon: lon, title: countryLocality)
                }
                else{
                    self.countryField.text = "This position doesn't belong to any country"
                    print("country not found")
                }
                return
            }

            if (countryNames.contains(countryLocality))
            {
                print("find corresponding country")
                self.countryField.text = "This position is \(cityLocality), \(countryLocality)"
                // do something
                self.changeSphereTexture(countryName: countryLocality)
                self.createPlaceMarkerNode(lat: lat, lon: lon, title: "\(cityLocality), \(countryLocality)")
            }
            else{
                self.countryField.text = "This position doesn't belong to any country"
                print("country not found")
            }
        })
    }
    
    func changeSphereTexture(countryName: String)
    {
//        let sphereMaterial = SCNMaterial()
//        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/\(countryName).png")
//        sphereMaterial.isDoubleSided = true
//        sphereMaterial.transparency = 1.0
//        self.sphereNode.geometry?.materials = [sphereMaterial]
//        self.sphereNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
    }
    
//    func createMapNode(width : CGFloat, height: CGFloat,pos: SCNVector3){
//        let plane = SCNPlane(width: width, height: height)
//        let planeMaterial = SCNMaterial()
//        planeMaterial.diffuse.contents = UIImage(named:"art.scnassets/chinaHigh.png")
//
//        plane.materials = [planeMaterial]
//        let mapNode = SCNNode(geometry: plane)
//        mapNode.position = pos
//
//        // calculate eulerAngle
//        let planeDir = -simd_normalize(simd_double3((Double)(pos.x), (Double)(pos.y), (Double)(pos.z)) - 0)
//        let alpha = atan(planeDir.y / sqrt(planeDir.x*planeDir.x + planeDir.z*planeDir.z)) * 180 / Double.pi
//        let beta = atan(planeDir.x / planeDir.z) * 180 / Double.pi
//        var betaReformat = beta
//        if (planeDir.z < 0)
//        {
//            betaReformat = beta + 180
//        }
//        let xAngle = -alpha * Double.pi / 180
//        let yAngle = betaReformat * Double.pi / 180
//        mapNode.eulerAngles = SCNVector3(xAngle, yAngle, 0)
//
//        self.sceneSetting.rootNode.addChildNode(mapNode)  // not shown
//        print("new node")
//        self.sceneSetting.rootNode.enumerateChildNodes { (node, stop) in
//            print(node)
//        }
//    }
    
    func createBoxNode(pos: SCNVector3){
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
        box.materials = [boxMaterial]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = pos
        sceneSetting.rootNode.addChildNode(boxNode)
    }
    
    func addButton(){
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY

        let rect1 = CGRect(x: midX - 100, y: midY + 200, width: 200, height: 70)
        
        // search button
        searchButton = UIButton(frame: rect1)
        searchButton.setTitle("Search Position", for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        let image = UIImage(named: "./art.scnassets/52016_preview.png")
        searchButton.setBackgroundImage(image, for: UIControl.State.normal)

        self.view.addSubview(searchButton)
    }
    
    func addTextfield(){
        let midY = self.view.bounds.midY
        
        latitudeField = UITextField(frame: CGRect(x: 20, y: midY + 100, width: self.view.bounds.width - 40, height: 40.00));
        latitudeField.placeholder = "Input latitude"
        latitudeField.borderStyle = UITextField.BorderStyle.line
        latitudeField.backgroundColor = UIColor.white
        latitudeField.textColor = UIColor.black
        latitudeField.keyboardType = .numbersAndPunctuation
        
        latitudeField.delegate = self
        latitudeField.returnKeyType = .done
        self.view.addSubview(latitudeField)
        
        longitudeField = UITextField(frame: CGRect(x: 20, y: midY + 140, width: self.view.bounds.width - 40, height: 40.00));
        longitudeField.placeholder = "Input longitude"
        longitudeField.borderStyle = UITextField.BorderStyle.line
        longitudeField.backgroundColor = UIColor.white
        longitudeField.textColor = UIColor.black
        longitudeField.keyboardType = .numbersAndPunctuation
        
        longitudeField.delegate = self
        longitudeField.returnKeyType = .done
        self.view.addSubview(longitudeField)
        
        countryField = UITextField(frame: CGRect(x: 20, y: midY + 60, width: self.view.bounds.width - 40, height: 40.00));
        countryField.placeholder = ""
        countryField.borderStyle = UITextField.BorderStyle.none
        countryField.backgroundColor = UIColor.clear
        countryField.textColor = UIColor.white
        countryField.keyboardType = .numbersAndPunctuation
        
        countryField.delegate = self
        countryField.returnKeyType = .done
        self.view.addSubview(countryField)
    }
    
    func createPlaceMarkerNode(lat: Double, lon: Double, title: String)
    {
        let pos = coordinateTransform(selfLat: curLatitude, selfLon: curLongitude, countryLat: lat, countryLon: lon)
        print(curLatitude, curLongitude)
        
        let norm = sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z)
        
        // remove all old place markers
        markersAnchorNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        let sphere = SCNSphere(radius: 0.03 * CGFloat(norm))
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
        sphere.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = pos
        markersAnchorNode.addChildNode(sphereNode)
        
        let spriteKitScene = SKScene(size: CGSize(width: 800, height: 100))
        spriteKitScene.backgroundColor = UIColor.clear
        let text = SKLabelNode(text: title)
        text.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
        text.yScale = -1
        text.fontSize = 40
        text.fontName = "Avenir Next"
        spriteKitScene.addChild(text)
        
        let background = SCNPlane(width: CGFloat(0.4 * norm), height: CGFloat(0.05 * norm))
        background.firstMaterial?.diffuse.contents = spriteKitScene
        let backgroundNode = SCNNode(geometry: background)
        backgroundNode.position.x = pos.x * 0.5
        backgroundNode.position.y = pos.y * 0.5
        backgroundNode.position.z = pos.z * 0.5
        
        let pos_normalized = -normalize(simd_double3(Double(pos.x), Double(pos.y), Double(pos.z)))
        let z = simd_double3(0, 0, 1)
        let half_vec = normalize((z + pos_normalized) / 2)
        let angle = acos(half_vec.z)
        let s = sin(angle)
        let axis = cross(z, half_vec)
        
        backgroundNode.rotate(by: SCNQuaternion(x: Float(s * axis.x), y: Float(s * axis.y), z: Float(s * axis.z), w: Float(half_vec.z)), aroundTarget: backgroundNode.position)
        
        markersAnchorNode.addChildNode(backgroundNode)
    }
}
