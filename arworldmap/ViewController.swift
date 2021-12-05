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
import DropDown
import SideMenu

class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, MenuControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var boxNode = SCNNode()
    var boxNode1 = SCNNode()
    var boxNode2 = SCNNode()
    var scene =  SCNScene()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
    let dropDown = DropDown()
    var searchButton = UIButton()
    
    // to do: change content
    private var sideMenu: SideMenuNavigationController?
    
    private let settingsController = SettingsViewController()
    private let infoController = InfoViewController()
                                                            
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
//        scene.rootNode.addChildNode(boxNode)
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY
        
        let menu = MenuController(with: ["Home", "Info", "Settings"])
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        addChildControllers()
        
        let rect1 = CGRect(x: midX - 80, y: midY - 130, width: 160, height: 70)
        searchButton = UIButton(frame: rect1)
        searchButton.setTitle("Search Position", for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        let image = UIImage(named: "./art.scnassets/52016_preview.png")
        searchButton.setBackgroundImage(image, for: UIControl.State.normal)
        self.view.addSubview(searchButton)
        
        dropDown.dataSource = ["China", "Switzerland", "America"]
        
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
            self!.createMapNode(width: CGFloat(rightLon-leftLon)/90,
                               height: CGFloat(topLat-bottomLat)/90, pos: SCNVector3(mapPos.x, mapPos.y, mapPos.z))
        }
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.delegate = self
    }
    /* This method creates only Text Nodes.
     */
    @objc func search(sender: UIButton!) {
        dropDown.show()
    }
    
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: {[weak self] in
            
            self?.title = named
            self?.scene.rootNode.enumerateChildNodes { (node, stop) in
                    node.removeFromParentNode()
            }
            
            if named == "Home" {
                self?.settingsController.view.isHidden = true
                self?.infoController.view.isHidden = true
            }
            else if named == "Info" {
                self?.settingsController.view.isHidden = true
                self?.infoController.view.isHidden = false
            }
            else if named == "Settings" {
                self?.settingsController.view.isHidden = false
                self?.infoController.view.isHidden = true
            }
        })
        
    }
    
    @IBAction func didTapMenuButton() {
        present(sideMenu!, animated: true)
    }
    
    private func addChildControllers() {
        addChild(self.settingsController)
        addChild(self.infoController)
        
        view.addSubview(settingsController.view)
        view.addSubview(infoController.view)
        
//        settingsController.view.frame = view.bounds
//        infoController.view.frame = view.bounds
        
        settingsController.didMove(toParent: self)
        infoController.didMove(toParent: self)
        
        settingsController.view.isHidden = true
        infoController.view.isHidden = true
    }
    
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
    
    func createMapNode(width : CGFloat, height: CGFloat,pos: SCNVector3){
        let plane = SCNPlane(width: width, height: height)
//        let sphere = SCNSphere(radius: 0.5)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIImage(named:"art.scnassets/chinaHigh.png")
//        planeMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(0.1, 0.1, 0.1)
        // planeMaterial.isDoubleSided = true
        
        plane.materials = [planeMaterial]
        let mapNode = SCNNode(geometry: plane)
        mapNode.position = pos
//        mapNode.position = SCNVector3(1, -1, 0)
        // some random angle
        // mapNode.eulerAngles = SCNVector3(0, 90 / 180 * Double.pi, 0)
        
        // calculate eulerAngle
        let planeDir = -simd_normalize(simd_double3((Double)(pos.x), (Double)(pos.y), (Double)(pos.z)) - 0)
        let alpha = atan(planeDir.y / sqrt(planeDir.x*planeDir.x + planeDir.z*planeDir.z)) * 180 / Double.pi
        // let beta = atan(planeDir.z / planeDir.x) * 180 / Double.pi
        let beta = atan(planeDir.x / planeDir.z) * 180 / Double.pi
        var betaReformat = beta
        // if (planeDir.x < 0)
        if (planeDir.z < 0)
        {
            betaReformat = beta + 180
        }
        let xAngle = -alpha * Double.pi / 180
        // let yAngle = (90-betaReformat) * Double.pi / 180
        let yAngle = betaReformat * Double.pi / 180
        mapNode.eulerAngles = SCNVector3(xAngle, yAngle, 0)
        
        scene.rootNode.addChildNode(mapNode)
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
            
            let pos = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: bottomLat, countryLon: leftLon)
            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
            // self.createBoxNode(pos: pos)
            
            let pos0 = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: bottomLat, countryLon: rightLon)
            print("World location XYZ is \(pos0.x) \(pos0.y) \(pos0.z)")
            // self.createBoxNode(pos: pos0)
            
            let pos1 = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: topLat, countryLon: leftLon)
            print("World location XYZ is \(pos1.x) \(pos1.y) \(pos1.z)")
            // self.createBoxNode(pos: pos1)
            
            let pos2 = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: topLat, countryLon: rightLon)
            print("World location XYZ is \(pos2.x) \(pos2.y) \(pos2.z)")
            // self.createBoxNode(pos: pos2)
            
//            let mapPos = self.coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: (topLat+bottomLat)/2, countryLon: (leftLon+rightLon)/2)
//            self.createMapNode(width: CGFloat(rightLon-leftLon)/90,
//                               height: CGFloat(topLat-bottomLat)/90, pos: SCNVector3(mapPos.x, mapPos.y, mapPos.z))
        }
    }
}
