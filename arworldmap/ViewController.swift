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
import SideMenu

class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, MenuControllerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var boxNode = SCNNode()
    var boxNode1 = SCNNode()
    var boxNode2 = SCNNode()
    var scene =  SCNScene()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
    private var sideMenu: SideMenuNavigationController?
    
    private let settingsController = SettingsViewController()
    private let infoController = InfoViewController()
    
    var searchButton = UIButton()
                                                            
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

        
        let menu = MenuController(with: ["Discover", "Search Country", "Search Position"])
        menu.delegate = self
        sideMenu = SideMenuNavigationController(rootViewController: menu)
        sideMenu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: view)
        
        addChildControllers()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.delegate = self
    }
    
    func didSelectMenuItem(named: String) {
        sideMenu?.dismiss(animated: true, completion: {[weak self] in
            
            self?.title = named
//            self?.scene.rootNode.enumerateChildNodes { (node, stop) in
//                    node.removeFromParentNode()
//            }
            
            if named == "Discover" {
                self?.settingsController.view.isHidden = true
                self?.infoController.view.isHidden = true
                self!.addDiscoverButton()
            }
            else if named == "Search Country" {
                self?.searchButton.removeFromSuperview()
                self?.settingsController.view.isHidden = true
                self?.infoController.view.isHidden = false
            }
            else if named == "Search Position" {
                self?.searchButton.removeFromSuperview()
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
    
    func addDiscoverButton(){
        let midX = self.view.bounds.midX
        let midY = self.view.bounds.midY

        let rect1 = CGRect(x: midX - 80, y: midY + 200, width: 160, height: 70)
        
        // search button
        searchButton = UIButton(frame: rect1)
        searchButton.setTitle("Discover", for: .normal)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        let image = UIImage(named: "./art.scnassets/52016_preview.png")
        searchButton.setBackgroundImage(image, for: UIControl.State.normal)

        self.view.addSubview(searchButton)
    }
    
    @objc func search(sender: UIButton!) {
        if (searchButton.titleLabel?.text == "Discover") {
            print("Touch search button")
            // do something
            searchButton.setTitle("Back", for: .normal)
        }
        else if (searchButton.titleLabel?.text == "Back"){
            print("get back")
            // do something
            searchButton.setTitle("Discover", for: .normal)
        }
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
