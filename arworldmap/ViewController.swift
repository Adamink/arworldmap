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
    var headlines = [SKLabelNode(), SKLabelNode(), SKLabelNode(), SKLabelNode()]
    var news_images = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    
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
//        boxNode.eulerAngles = SCNVector3(0,60,0)
        scene.rootNode.addChildNode(boxNode)
        
        let spriteKitScene = SKScene(size: CGSize(width: sceneView.frame.width, height: sceneView.frame.height))
        spriteKitScene.scaleMode = .aspectFit
//        guard let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") else { return }
//
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
//        let player = AVPlayer(url: url)
        
        let videoSpriteKitNode = SKVideoNode(fileNamed: "australia.mp4")
//        let videoSpriteKitNode = SKVideoNode(avPlayer: player)
        videoSpriteKitNode.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
        videoSpriteKitNode.size = spriteKitScene.size
        videoSpriteKitNode.yScale = -1
        videoSpriteKitNode.play()
        spriteKitScene.addChild(videoSpriteKitNode)
        let background = SCNPlane(width: CGFloat(1.6), height: CGFloat(0.9))
        background.firstMaterial?.diffuse.contents = spriteKitScene
        let backgroundNode = SCNNode(geometry: background)
        backgroundNode.position = SCNVector3(2,0,0)
        backgroundNode.eulerAngles = SCNVector3(0, -0.4 * Double.pi, 0)
        scene.rootNode.addChildNode(backgroundNode)
        
//        let spriteKitScene1 = SKScene(size: CGSize(width: sceneView.frame.width, height: sceneView.frame.height))
//        spriteKitScene1.scaleMode = .aspectFit
//        spriteKitScene1.backgroundColor = UIColor(cgColor: CGColor(gray: 1, alpha: 0))
//        let map = SKSpriteNode(imageNamed: "art.scnassets/australiaHigh.png")
//        map.position = CGPoint(x: spriteKitScene1.size.width / 2.0, y: spriteKitScene1.size.height / 2.0)
//        map.yScale = -0.5
//        map.xScale = 0.5
//        spriteKitScene1.addChild(map)
//
//        let background1 = SCNPlane(width: CGFloat(1.5), height: CGFloat(2))
//        background1.firstMaterial?.diffuse.contents = spriteKitScene1
//        let backgroundNode1 = SCNNode(geometry: background1)
//        backgroundNode1.position = SCNVector3(2,0,1)
//        backgroundNode1.eulerAngles = SCNVector3(0, -0.6 * Double.pi, 0)
//        scene.rootNode.addChildNode(backgroundNode1)
        
        let spriteKitScene2 = SKScene(size: CGSize(width: 1600, height: 600))
        for i in 0...3 {
            news_images[i].position = CGPoint(x: spriteKitScene2.size.width / 2.0 - 600 + 400 * CGFloat(i), y: spriteKitScene2.size.height / 2.0 - 150)
            news_images[i].size = CGSize(width: 400, height: 300)
            news_images[i].yScale = -1
            spriteKitScene2.addChild(news_images[i])
        }
        
        let news = SKLabelNode(text: "News in Australia")
        news.position = CGPoint(x: spriteKitScene2.size.width / 2.0, y: spriteKitScene2.size.height / 2.0 + 50)
        news.yScale = -1
        news.fontName = "Avenir Next"
        spriteKitScene2.addChild(news)
        
        for i in 0...3 {
            headlines[i].position = CGPoint(x: spriteKitScene2.size.width / 2.0, y: spriteKitScene2.size.height / 2.0 + 100 + 50 * CGFloat(i))
            headlines[i].yScale = -1
            headlines[i].fontSize = 20
            headlines[i].fontName = "Avenir Next"
            spriteKitScene2.addChild(headlines[i])
        }
        
        let background2 = SCNPlane(width: CGFloat(8), height: CGFloat(3))
        background2.firstMaterial?.diffuse.contents = spriteKitScene2
        let backgroundNode2 = SCNNode(geometry: background2)
        backgroundNode2.position = SCNVector3(2,0,5)
        backgroundNode2.eulerAngles = SCNVector3(0, -0.9 * Double.pi, 0)
        scene.rootNode.addChildNode(backgroundNode2)
        
        getHeadlines(country: "australia")
//        let text1 = SCNText(string: "Australia", extrusionDepth: 0)
//        text1.firstMaterial?.diffuse.contents = UIColor.white
//        text1.font = UIFont(name: "Avenir Next", size: 0.3)
//        let textNode1 = SCNNode(geometry: text1)
//        textNode1.position = SCNVector3(2,-1,1.5)
//        textNode1.eulerAngles = SCNVector3(0, -0.6 * Double.pi, 0)
//        scene.rootNode.addChildNode(textNode1)
        
        let mapPlane = SCNPlane(width: 0.8, height: 0.6)
        mapPlane.firstMaterial?.diffuse.contents = UIImage(named:"art.scnassets/australiaHigh.png")
        let mapNode = SCNNode(geometry: mapPlane)
        mapNode.position = SCNVector3(1,-0.5,0.5)
        mapNode.eulerAngles = SCNVector3(0, -0.6 * Double.pi, 0)
        scene.rootNode.addChildNode(mapNode)
        
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
    
    func getHeadlines(country: String){
        let newsEndpoint = "https://newsapi.org/v2/top-headlines?q=\(country)&apiKey=b36706581f614d52828c4cd597af6065"
        
        guard let url = URL(string: newsEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error calling GET")
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let data = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                guard let newsList = data["articles"] as? [[String: Any]] else {
                    print("Could not get w as AnyeatherList from JSON")
                    return
                }
                
                for i in 0...3 {
                    self.headlines[i].text = newsList[i]["title"] as? String
                    let img_url = newsList[i]["urlToImage"] as? String
                    self.load_news_img(urlString: img_url!, num: i)
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func load_news_img(urlString : String, num: Int) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.news_images[num].texture = SKTexture(image: image)
                        print("loaded!")
                    }
                }
            }
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
    
    func createSphereNode(pos: SCNVector3, selfLat: CLLocationDegrees, selfLon: CLLocationDegrees){
        let sphere = SCNSphere(radius: 1)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/China_small.png")
        sphereMaterial.isDoubleSided = true
        sphereMaterial.transparency = 1.0
        sphere.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = pos
        sphereNode.eulerAngles = SCNVector3(-(90-selfLat)/180*Double.pi, -selfLon/180*Double.pi,0)
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
            
            let pos = self.coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: (bottomLat+topLat)/2, countryLon: (leftLon+rightLon)/2)
            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
            // add box
            self.createBoxNode(pos: pos)
            self.createSphereNode(pos: SCNVector3(0, -1, 0), selfLat: location.latitude, selfLon: location.longitude)
        }
    }
}
