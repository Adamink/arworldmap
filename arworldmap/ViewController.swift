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
    var newsBoard = SCNNode()
    var countryInfoBoard = SCNNode()
    var videoBoard = SCNNode()
    var anchorNode = SCNNode()
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
        
        infoController.sceneInfo = self.scene
        settingsController.sceneSetting = self.scene
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
            enterDiscover(conutryName: "Anstralia", pos: SCNVector3(0,0,0))
            searchButton.setTitle("Back", for: .normal)
        }
        else if (searchButton.titleLabel?.text == "Back"){
            print("get back")
            exitDiscover()
            searchButton.setTitle("Discover", for: .normal)
        }
    }
    
    func enterDiscover(conutryName: String, pos: SCNVector3)
    {
        self.scene.rootNode.addChildNode(anchorNode)
        createNewsBoard(transparentBackground: false)
        createCountryInfoBoard(transparentBackground: false)
//        createVideoBoard()
    }
    
    func exitDiscover()
    {
        anchorNode.removeFromParentNode()
    }
    
    func createVideoBoard()
    {
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
        videoBoard = SCNNode(geometry: background)
        videoBoard.position = SCNVector3(2,0,0)
        videoBoard.eulerAngles = SCNVector3(0, -0.4 * Double.pi, 0)
        anchorNode.addChildNode(videoBoard)
    }
        
    //    func createNewsBoard(pos: SCNVector3, eulerAngles: SCNVector3, country: String)
    func createNewsBoard(transparentBackground: Bool)
    {
        let headlines = [SKLabelNode(), SKLabelNode(), SKLabelNode(), SKLabelNode()]
        let news_images = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
        
        let spriteKitScene = SKScene(size: CGSize(width: 1600, height: 600))
        var fontColor = UIColor.white
        if transparentBackground{
            spriteKitScene.backgroundColor = UIColor.clear
            fontColor = UIColor.black
        }
        
        for i in 0...3 {
            news_images[i].position = CGPoint(x: spriteKitScene.size.width / 2.0 - 600 + 400 * CGFloat(i), y: spriteKitScene.size.height / 2.0 - 150)
            news_images[i].size = CGSize(width: 400, height: 300)
            news_images[i].yScale = -1
            spriteKitScene.addChild(news_images[i])
        }
        
        let news = SKLabelNode(text: "News in Australia")
        news.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0 + 50)
        news.yScale = -1
        if transparentBackground{
            spriteKitScene.backgroundColor = UIColor.clear
        }
        news.fontColor = fontColor
        news.fontName = "Avenir Next"
        spriteKitScene.addChild(news)
        
        for i in 0...3 {
            headlines[i].position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0 + 100 + 50 * CGFloat(i))
            headlines[i].yScale = -1
            headlines[i].fontSize = 20
            headlines[i].fontColor = fontColor
            headlines[i].fontName = "Avenir Next"
            spriteKitScene.addChild(headlines[i])
        }
        
        let background = SCNPlane(width: CGFloat(8), height: CGFloat(3))
        background.firstMaterial?.diffuse.contents = spriteKitScene
        newsBoard = SCNNode(geometry: background)
        newsBoard.position = SCNVector3(2,0,5)
        newsBoard.eulerAngles = SCNVector3(0, -0.9 * Double.pi, 0)
        anchorNode.addChildNode(newsBoard)
        getHeadlines(country: "australia", headlines: headlines, imgs: news_images)
    }
        
    func getHeadlines(country: String, headlines: [SKLabelNode], imgs: [SKSpriteNode]){
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
                
                var idx = 0, i = 0
                while i < 4 && idx < newsList.count {
                    guard let img_url = newsList[idx]["urlToImage"] as? String else
                    {
                        print("error get img url")
                        idx += 1
                        continue
                    }
                    headlines[i].text = newsList[idx]["title"] as? String
                    self.load_news_img(urlString: img_url, num: i, imgs: imgs)
                    idx += 1
                    i += 1
                }
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func load_news_img(urlString : String, num: Int, imgs: [SKSpriteNode]) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imgs[num].texture = SKTexture(image: image)
                        print("Loaded news img!")
                    }
                }
            }
        }
    }
    
    func createCountryInfoBoard(transparentBackground: Bool)
    {
        let country_info = [SKLabelNode(), SKLabelNode(), SKLabelNode(), SKLabelNode(), SKLabelNode(), SKLabelNode()] // common name, official name, continents, latlng, capital, population
        let country_flag_img = SKSpriteNode()
        
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 1600))
        var fontColor = UIColor.white
        if transparentBackground{
            spriteKitScene.backgroundColor = UIColor.clear
            fontColor = UIColor.black
        }
        
        // add images
        country_flag_img.position = CGPoint(x: 300, y: 300) // spriteKitScene.size.width / height
        country_flag_img.size = CGSize(width: 600, height: 600)
        country_flag_img.yScale = -1
        spriteKitScene.addChild(country_flag_img)
        
        // add country info text
        for i in 0...5 {
            country_info[i].position = CGPoint(x: spriteKitScene.size.width / 2.0, y: 600 + 100 + 50 * CGFloat(i))
            country_info[i].yScale = -1
            if (i==0) {
                country_info[i].fontSize = 32
            }
            else {
                country_info[i].fontSize = 20
            }
            country_info[i].fontColor = fontColor
            country_info[i].fontName = "Avenir Next"
            spriteKitScene.addChild(country_info[i])
        }
        
        let background = SCNPlane(width: CGFloat(2), height: CGFloat(3))
        background.firstMaterial?.diffuse.contents = spriteKitScene
        countryInfoBoard = SCNNode(geometry: background)
        countryInfoBoard.position = SCNVector3(-3,0,5.5)
        countryInfoBoard.eulerAngles = SCNVector3(0, -1.2 * Double.pi, 0)
        anchorNode.addChildNode(countryInfoBoard)
        getCountryInfo(country: "australia", infotexts: country_info, img: country_flag_img)
    }
    
    func getCountryInfo(country: String, infotexts: [SKLabelNode], img: SKSpriteNode){
        let infoEndpoint = "https://restcountries.com/v3.1/name/\(country)"
        
        guard let url = URL(string: infoEndpoint) else {
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
                guard let data_retrieve = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [[String: Any]] else {
                        print("error trying to convert data to JSON")
                        return
                }
                let data = data_retrieve[0]
                
                // common name, official name, continents, latlng, capital, population
                
                guard let countryName = data["name"] as? [String: Any] else {
                    print("Could not get country name from JSON")
                    return
                }
                
                infotexts[0].text = countryName["common"] as? String
                infotexts[1].text = "Official Name:  \(countryName["official"])"
                
                guard let countryContinent = data["continents"] as? [String] else {
                    print("Could not get country continents from JSON")
                    return
                }
                infotexts[2].text = "Continent: \(countryContinent[0])"
                
                guard let countryLatLon = data["latlng"] as? [Float] else {
                    print("Could not get country latlon from JSON")
                    return
                }
                infotexts[3].text = "Latitude: \(countryLatLon[0]) " + " Longitude: \(countryLatLon[1])"
                
                guard let countryCaptial = data["capital"] as? [String] else {
                    print("Could not get country capital from JSON")
                    return
                }
                infotexts[4].text = "Captial: \(countryCaptial[0])"
                
                guard let countryPopulation = data["population"] as? Int else {
                    print("Could not get country population from JSON")
                    return
                }
                infotexts[5].text = "Population: \(countryPopulation)"
                
                guard let countryFlagImg = data["flags"] as? [String: Any] else {
                    print("Could not get country flag image from JSON")
                    return
                }
                
                guard let img_url = countryFlagImg["png"] as? String else {
                    print("Could not get country image url from JSON")
                    return
                }
                self.load_country_img(urlString: img_url, img: img)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
        
    func load_country_img(urlString : String, img: SKSpriteNode) {
        guard let url = URL(string: urlString)else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        img.texture = SKTexture(image: image)
                        print("Loaded country img!")
                    }
                }
            }
        }
    }
    
    func createPlaceMarkerNode(pos: SCNVector3, title: String)
    {
        let sphere = SCNSphere(radius: 0.03)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
        sphere.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = pos
        scene.rootNode.addChildNode(sphereNode)
        
        let spriteKitScene = SKScene(size: CGSize(width: 400, height: 100))
        spriteKitScene.backgroundColor = UIColor.clear
        let text = SKLabelNode(text: title)
        text.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
        text.yScale = -1
        text.fontSize = 60
        text.fontName = "Avenir Next"
//        text.fontColor = UIColor.black
        spriteKitScene.addChild(text)
        let background = SCNPlane(width: CGFloat(0.2), height: CGFloat(0.05))
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
        let axis = cross(z, pos_normalized)
        backgroundNode.rotate(by: SCNQuaternion(x: Float(s * axis.x), y: Float(s * axis.y), z: Float(s * axis.z), w: Float(half_vec.z)), aroundTarget: backgroundNode.position)
        scene.rootNode.addChildNode(backgroundNode)
    }
    
    func createSphereNode(pos: SCNVector3, selfLat: CLLocationDegrees, selfLon: CLLocationDegrees){
        let sphere = SCNSphere(radius: 1.0)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIImage(named:"art.scnassets/China_small.png")
        sphereMaterial.isDoubleSided = true
        sphereMaterial.transparency = 1.0
        sphere.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = pos
//        sphereNode.eulerAngles = SCNVector3(-(90-selfLat)/180*Double.pi, -selfLon/180*Double.pi,0)
        var s = sin(-selfLon/180*Double.pi/2)
        var c = cos(-selfLon/180*Double.pi/2)
        sphereNode.rotate(by: SCNQuaternion(x: 0, y: Float(s), z: 0, w: Float(c)), aroundTarget: pos)
        
        s = sin(-(90-selfLat)/180*Double.pi/2)
        c = cos(-(90-selfLat)/180*Double.pi/2)
        sphereNode.rotate(by: SCNQuaternion(x: Float(s), y: 0, z: 0, w: Float(c)), aroundTarget: pos)
        scene.rootNode.addChildNode(sphereNode)
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
        let cameraTransform = SCNMatrix4(frame.camera.transform)
        let cameraDirection = simd_double3(-1 * Double(cameraTransform.m31),
                                       -1 * Double(cameraTransform.m32),
                                       -1 * Double(cameraTransform.m33))
        let a = cameraDirection.x
        let b = cameraDirection.y
        let c = cameraDirection.z
        let x = -2 * b / (a * a + b * b + c * c)
        let intersect_pos = simd_double3(a * x, b * x, c * x)
//        if(dot(intersect_pos, cameraDirection) > 0)
//        {
//            print(intersect_pos)
//        }
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
            
//            let pos = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: bottomLat, countryLon: leftLon)
//            print("World location XYZ is \(pos.x) \(pos.y) \(pos.z)")
//            // self.createBoxNode(pos: pos)
//
//            let pos0 = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: bottomLat, countryLon: rightLon)
//            print("World location XYZ is \(pos0.x) \(pos0.y) \(pos0.z)")
//            // self.createBoxNode(pos: pos0)
//
//            let pos1 = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: topLat, countryLon: leftLon)
//            print("World location XYZ is \(pos1.x) \(pos1.y) \(pos1.z)")
//            // self.createBoxNode(pos: pos1)
//
//            let pos2 = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: topLat, countryLon: rightLon)
//            print("World location XYZ is \(pos2.x) \(pos2.y) \(pos2.z)")
//            // self.createBoxNode(pos: pos2)
            var pos = coordinateTransform(selfLat: location.latitude, selfLon: location.longitude, countryLat: (bottomLat+topLat)/2, countryLon: (leftLon+rightLon)/2)
            self.createPlaceMarkerNode(pos: pos, title: "China")
            print(pos.x * pos.x + (pos.y + 1) * (pos.y + 1) + pos.z * pos.z)
            
            self.createSphereNode(pos: SCNVector3(0, -1, 0), selfLat: location.latitude, selfLon: location.longitude)
        }
    }
}
