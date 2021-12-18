//
//  util.swift
//  arworldmap
//
//

import Foundation
import AVFoundation
import CoreLocation
import SceneKit

var countryNames: [String] = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahrain", "Bangladesh", "Barbados", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Cook Islands", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "Gabon", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Ivory Coast", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "North Korea", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn Islands", "Poland", "Portugal", "Puerto Rico", "Qatar", "Romania", "Russia", "Rwanda", "San Marino", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Thailand", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]

// still problematic, return 0.0 for queries
func getCountryLongLatFromName(country: String) -> [Double]{
    var latitude = 0.0;
    var longitude = 0.0;
    let infoEndpoint = "https://restcountries.com/v3.1/name/\(country)"
    
    guard let url = URL(string: infoEndpoint) else {
        print("Error: cannot create URL")
        return [0.0, 0.0]
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

            var data = data_retrieve[0]
            
            for index in 0..<data_retrieve.count {
                data = data_retrieve[index]
                guard let countryName = data["name"] as? [String: Any] else {
                    print("Could not get country name from JSON")
                    return
                }
                let text = countryName["common"] as? String
                if country.compare(text ?? "None", options: .caseInsensitive) == .orderedSame {
                    break
                }
            }
            guard let countryLatLon = data["latlng"] as? [Double] else {
                print("Could not get country latlon from JSON")
                return
            }
            latitude = countryLatLon[0]
            longitude = countryLatLon[1]
        } catch  {
            print("error trying to convert data to JSON")
            return
        }
    }
    task.resume()
    return [latitude, longitude]
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