//
//  util.swift
//  arworldmap
//
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

var countryNames: [String] = ["American Samoa", "Bhutan", "Colombia", "Central African Republic", "French Polynesia", "Honduras", "Indonesia", "Iran", "Kenya", "Mozambique", "Nigeria", "Papua New Guinea", "Tajikistan", "Taiwan", "Bosnia and Herzegovina", "Dominican Republic", "Pakistan", "Turkmenistan", "Uganda", "Albania", "Austria", "Belgium", "Cyprus", "Faroe Islands", "Guyana", "Luxembourg", "Niue", "Romania", "Antarctica", "Cambodia", "Germany", "Haiti", "Iceland", "Jamaica", "Peru", "Slovenia", "Singapore", "Trinidad and Tobago", "Zimbabwe", "Gibraltar", "Guinea", "Christmas Island", "Malawi", "New Zealand", "Serbia", "Eritrea", "Israel", "Ivory Coast", "Lebanon", "Latvia", "Argentina", "Iraq", "Suriname", "Portugal", "Spain", "Sweden", "Tokelau", "Australia", "Bangladesh", "Belize", "Italy", "Norway", "Syria", "Aruba", "Bahrain", "Guam", "India", "Lesotho", "Morocco", "Senegal", "Algeria", "Armenia", "New Caledonia", "Turks and Caicos Islands", "Venezuela", "Angola", "Barbados", "Cuba", "Ecuador", "French Guiana", "Nepal", "Antigua and Barbuda", "Anguilla", "Burundi", "Egypt", "Equatorial Guinea", "Kyrgyzstan", "South Korea", "Nicaragua", "Switzerland", "Burkina Faso", "Yemen", "Ghana", "Japan", "Kiribati", "Kazakhstan", "Nauru", "United Kingdom", "Vietnam", "Hong Kong", "Comoros", "San Marino", "Tunisia", "Ukraine", "British Virgin Islands", "Andorra", "Bouvet Island", "Sri Lanka", "Dominica", "Thailand", "Bolivia", "Chad", "Cocos (Keeling) Islands", "Gabon", "British Indian Ocean Territory", "Liberia", "Mali", "Mauritius", "Puerto Rico", "Cayman Islands", "Denmark", "Lithuania", "Mayotte", "Poland", "Bulgaria", "Finland", "Guatemala", "Marshall Islands", "Turkey", "Uzbekistan", "Solomon Islands", "Cape Verde", "Cook Islands", "Liechtenstein", "Moldova", "Monaco", "Mauritania", "Paraguay", "Sudan", "Wallis and Futuna", "Chile", "Cameroon", "Greenland", "Croatia", "North Korea", "Niger", "Seychelles", "Brazil", "China", "Martinique", "Montenegro", "Mexico", "Vanuatu", "Panama", "Saudi Arabia", "South Africa", "Sierra Leone", "Tonga", "Uruguay", "Benin", "Northern Mariana Islands", "Costa Rica", "Fiji", "Madagascar", "Macau", "Botswana", "Bermuda", "El Salvador", "France", "Hungary", "Western Sahara", "Brunei", "Guadeloupe", "Laos", "Libya", "Montserrat", "Malta", "Norfolk Island", "United Arab Emirates", "Tuvalu", "Zambia", "Ireland", "Estonia", "Grenada", "Netherlands", "Russia", "Somalia", "Afghanistan", "Georgia", "Greece", "Jordan", "Slovakia", "Oman", "Qatar", "Djibouti", "Ethiopia", "Guernsey", "Jersey", "Kuwait", "Maldives", "Malaysia", "Pitcairn Islands", "Philippines", "Rwanda", "Namibia", "Azerbaijan", "Canada", "Mongolia", "Guinea-Bissau", "Togo"]
