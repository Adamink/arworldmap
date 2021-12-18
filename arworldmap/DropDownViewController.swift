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
    var didFindLocation = false
    
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

        print(countries)
        print(countries.count) // 256
        
        dropDown.dataSource = countries
        
        // hard code position
        // opposite side of the globe
        let leftLon = 73.554302
        let rightLon = 134.775703
        let topLat = 53.561780
        let bottomLat = 18.155060
        let location = self.locationManager.location?.coordinate
        
        DropDown.appearance().setupCornerRadius(10)
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 20)
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            let mapPos = coordinateTransform(selfLat: location!.latitude, selfLon: location!.longitude, countryLat: (topLat+bottomLat)/2, countryLon: (leftLon+rightLon)/2)
            self?.createMapNode(width: CGFloat(rightLon-leftLon)/90,
                               height: CGFloat(topLat-bottomLat)/90, pos: SCNVector3(mapPos.x, mapPos.y, mapPos.z))
        }
        
        // Set the view's delegate
        searchView?.delegate = self
        
        // Show statistics such as fps and timing information
        searchView?.showsStatistics = true
        
        // Set the scene to the view
        searchView?.scene = sceneInfo
    }
    
    @objc func search(sender: UIButton!) {
        dropDown.show()
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
        
        self.sceneInfo.rootNode.addChildNode(mapNode)  // not shown
        print("new node")
        self.sceneInfo.rootNode.enumerateChildNodes { (node, stop) in
            print(node)
        }
    }
    
    func addSearchButton(){
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY
        let rect1 = CGRect(x: midX - 80, y: midY - 130, width: 160, height: 70)
        searchButton = UIButton(frame: rect1)
        searchButton.setTitle("Search Country", for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        let image = UIImage(named: "./art.scnassets/52016_preview.png")
        searchButton.setBackgroundImage(image, for: UIControl.State.normal)
        self.view.addSubview(searchButton)
    }
}


