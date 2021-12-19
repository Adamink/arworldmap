//
//  DropDownViewController.swift
//  arworldmap
//
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import CoreLocation
import DropDown

class DropDownViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, CLLocationManagerDelegate{
    
    var searchView: ARSCNView!
    
    var sceneInfo =  SCNScene()
    var sphereNode = SCNNode()
    var markersAnchorNode = SCNNode()
    var didFindLocation = false
    
    var curLatitude = 0.0
    var curLongitude = 0.0
    
    let locationManager = CLLocationManager()
    
    let dropDown = DropDown()
    var searchButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        addSearchButton()
        
        dropDown.anchorView = searchButton
        dropDown.bottomOffset = CGPoint(x: -50, y:(dropDown.anchorView?.plainView.bounds.height)! - 5)
        dropDown.width = 260
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                    // Setup your custom UI components
                    cell.optionLabel.textAlignment = .center
        } // center text
        
//        dropDown.dataSource = ["China", "Switzerland", "America", "Australia"]
        
//        let countries = NSLocale.isoCountryCodes.map { (code:String) -> String in
//            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
//            return NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
//        }
        
        let countries = countryNames

//        print(countries)
//        print(countries.count)
        
        dropDown.dataSource = countries
        
        // hard code position
        // opposite side of the globe
//        let leftLon = 73.554302
//        let rightLon = 134.775703
//        let topLat = 53.561780
//        let bottomLat = 18.155060
//        let location = self.locationManager.location?.coordinate
        
        DropDown.appearance().setupCornerRadius(10)
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 20)
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self?.changeSphereTexture(countryName: item)
            let latlon = countryLatLonDict[item]!
            self?.createPlaceMarkerNode(lat: latlon.x, lon: latlon.y, title: item)
//            let mapPos = coordinateTransform(selfLat: location!.latitude, selfLon: location!.longitude, countryLat: (topLat+bottomLat)/2, countryLon: (leftLon+rightLon)/2)
//            self?.createMapNode(width: CGFloat(rightLon-leftLon)/90,
//                               height: CGFloat(topLat-bottomLat)/90, pos: SCNVector3(mapPos.x, mapPos.y, mapPos.z))
            
        }
        
        // Set the view's delegate
        searchView?.delegate = self
        
        // Show statistics such as fps and timing information
        searchView?.showsStatistics = true
        
        // Set the scene to the view
        searchView?.scene = sceneInfo
    }
    
    @objc func search(sender: UIButton!) {
        if (searchButton.titleLabel?.text == "Search Country") {
            dropDown.show()
            searchButton.setTitle("Back", for: .normal)
        }
        else if (searchButton.titleLabel?.text == "Back"){
            searchButton.setTitle("Search Country", for: .normal)
            markersAnchorNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
            makeSphereTransparent()
        }
    }
    
    func changeSphereTexture(countryName: String)
    {
        let mask_file = "art.scnassets/country_shape_masks_alpha/" + countryName + ".png"
        sphereNode.geometry?.firstMaterial?.transparent.contents = UIImage(named: mask_file)
    }
    
    func makeSphereTransparent()
    {
        let mask_file = "art.scnassets/totallyTransparentSphere.png"
        sphereNode.geometry?.firstMaterial?.transparent.contents = UIImage(named: mask_file)
    }
    
    func createPlaceMarkerNode(lat: Double, lon: Double, title: String)
    {
        let pos = coordinateTransform(selfLat: curLatitude, selfLon: curLongitude, countryLat: lat, countryLon: lon)
        
        let norm = sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z)
        
        // remove all old place markers
        markersAnchorNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        let sphere = SCNSphere(radius: 0.02 * CGFloat(norm))
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.orange
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
        backgroundNode.eulerAngles = SCNVector3(xAngle, yAngle, 0)
        
        markersAnchorNode.addChildNode(backgroundNode)
    }
    
//    func createMapNode(width : CGFloat, height: CGFloat,pos: SCNVector3){
//        let plane = SCNPlane(width: width, height: height)
//        let planeMaterial = SCNMaterial()
//        planeMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg") //chinaHigh.png
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
//        anchorNode.addChildNode(mapNode)  // not shown
//        print("new node")
//        self.sceneInfo.rootNode.enumerateChildNodes { (node, stop) in
//            print(node)
//        }
//    }
    
    func addSearchButton(){
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY
        let rect1 = CGRect(x: midX - 80, y: midY - 280, width: 160, height: 70)
        searchButton = UIButton(frame: rect1)
        searchButton.setTitle("Search Country", for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        let image = UIImage(named: "./art.scnassets/52016_preview.png")
        searchButton.setBackgroundImage(image, for: UIControl.State.normal)
        self.view.addSubview(searchButton)
    }
}


