//
//  util.swift
//  arworldmap
//
//  Created by 时海彤 on 05.12.21.
//

import Foundation
import AVFoundation
import CoreLocation
import SceneKit

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
