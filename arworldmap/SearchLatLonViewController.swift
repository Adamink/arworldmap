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

class SearchLatLonViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, CLLocationManagerDelegate, UITextFieldDelegate{
    
    var searchView: ARSCNView!
    
    var sceneSetting =  SCNScene()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
    var latitudeField: UITextField = UITextField()
    var longitudeField: UITextField = UITextField()
    
    var latitudeCountry = 0.0
    var longitudeCountry = 0.0
    
    var pos: SCNVector3 = SCNVector3()
    
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
//        else if (latitudeCountry == -25.0 && longitudeCountry == 130.0)
//        {
//            let leftLon = 112.901452
//            let rightLon = 158.966830
//            let topLat = -10.132839
//            let bottomLat = -54.757221
//            let mapPos = coordinateTransform(selfLat: currentLocation!.latitude, selfLon: currentLocation!.longitude, countryLat: (topLat+bottomLat)/2, countryLon: (leftLon+rightLon)/2)
//            createMapNode(width: CGFloat(rightLon-leftLon)/90, height: CGFloat(topLat-bottomLat)/90, pos: SCNVector3(mapPos.x, mapPos.y, mapPos.z))
//        }
//        else if (latitudeCountry == 30.0 && longitudeCountry == 100.0)
//        {
//            let leftLon = 73.554302
//            let rightLon = 134.775703
//            let topLat = 53.561780
//            let bottomLat = 18.155060
//            let mapPos = coordinateTransform(selfLat: currentLocation!.latitude, selfLon: currentLocation!.longitude, countryLat: (topLat+bottomLat)/2, countryLon: (leftLon+rightLon)/2)
//            createMapNodeChina(width: CGFloat(rightLon-leftLon)/90, height: CGFloat(topLat-bottomLat)/90, pos: SCNVector3(mapPos.x, mapPos.y, mapPos.z))
//            
//        }
//        else
//        {
//            print(currentLocation?.latitude ?? 0)
//            print(currentLocation?.longitude ?? 0)
//            pos = coordinateTransform(selfLat: currentLocation!.latitude, selfLon: currentLocation!.longitude, countryLat: latitudeCountry, countryLon: longitudeCountry)
//            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
//            // add box
//            createBoxNode(pos: pos)
//        }
        getCountry(lat: latitudeCountry, long: longitudeCountry)
    }
    
    func getCountry(lat:Double, long:Double) {
        let tmpCLGeocoder = CLGeocoder.init()
        let tmpDataLoc = CLLocation.init(latitude: lat, longitude: long)
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
                return
            }

            // City
    //        guard let cityLocality = placeMark.locality else{
    //            print("error get city")
    //            return
    //        }

//            print(placeMark)
//            print(countryLocality)
//            print(cityLocality)
            
            if (countryNames.contains(countryLocality))
            {
                print("find corresponding country")
                // do something
            }
            else{
                print("country not found")
            }
        })
    }
    
    func createMapNode(width : CGFloat, height: CGFloat,pos: SCNVector3){
        let plane = SCNPlane(width: width, height: height)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIImage(named:"art.scnassets/chinaHigh.png")
        
        plane.materials = [planeMaterial]
        let mapNode = SCNNode(geometry: plane)
        mapNode.position = pos
        
        // calculate eulerAngle
        let planeDir = -simd_normalize(simd_double3((Double)(pos.x), (Double)(pos.y), (Double)(pos.z)) - 0)
        let alpha = atan(planeDir.y / sqrt(planeDir.x*planeDir.x + planeDir.z*planeDir.z)) * 180 / Double.pi
        let beta = atan(planeDir.x / planeDir.z) * 180 / Double.pi
        var betaReformat = beta
        if (planeDir.z < 0)
        {
            betaReformat = beta + 180
        }
        let xAngle = -alpha * Double.pi / 180
        let yAngle = betaReformat * Double.pi / 180
        mapNode.eulerAngles = SCNVector3(xAngle, yAngle, 0)
        
        self.sceneSetting.rootNode.addChildNode(mapNode)  // not shown
        print("new node")
        self.sceneSetting.rootNode.enumerateChildNodes { (node, stop) in
            print(node)
        }
    }
    
    func createMapNodeChina(width : CGFloat, height: CGFloat,pos: SCNVector3){
        let plane = SCNPlane(width: width, height: height)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIImage(named:"art.scnassets/chinaHigh.png")
        
        plane.materials = [planeMaterial]
        let mapNode = SCNNode(geometry: plane)
        mapNode.position = pos
//        mapNode.position = SCNVector3(0.5, 0.5, 0.5)

        // calculate eulerAngle
        let planeDir = -simd_normalize(simd_double3((Double)(pos.x), (Double)(pos.y), (Double)(pos.z)) - 0)
        let alpha = atan(planeDir.y / sqrt(planeDir.x*planeDir.x + planeDir.z*planeDir.z)) * 180 / Double.pi
        let beta = atan(planeDir.x / planeDir.z) * 180 / Double.pi
        var betaReformat = beta
        // if (planeDir.x < 0)
        if (planeDir.z < 0)
        {
            betaReformat = beta + 180
        }
        let xAngle = -alpha * Double.pi / 180
        let yAngle = betaReformat * Double.pi / 180
        mapNode.eulerAngles = SCNVector3(xAngle, yAngle, 0)
        
        sceneSetting.rootNode.addChildNode(mapNode)
        print("hidden?  ", mapNode.isHidden)
        print("new node")
        self.sceneSetting.rootNode.enumerateChildNodes { (node, stop) in
            print(node)
        }
    }
    
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
        let searchButton = UIButton(frame: rect1)
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
    }
}
