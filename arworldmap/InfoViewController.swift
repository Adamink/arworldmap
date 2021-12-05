//
//  InfoViewController.swift
//  arworldmap
//
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import CoreLocation
import DropDown

class InfoViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate, ARSessionDelegate, CLLocationManagerDelegate{
    
    var searchView: ARSCNView!
    
    var scene =  SCNScene()
    var didFindLocation = false
    
    let locationManager = CLLocationManager()
    
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
        searchView?.scene = scene
    }
    
    
}


