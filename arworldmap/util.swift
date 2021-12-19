//
//  util.swift
//  arworldmap
//
//

import Foundation
import AVFoundation
import CoreLocation
import SceneKit

var countryNames: [String] = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahrain", "Bangladesh", "Barbados", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Cook Islands", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "Gabon", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Ivory Coast", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "North Korea", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn Islands", "Poland", "Portugal", "Puerto Rico", "Qatar", "Romania", "Russia", "Rwanda", "San Marino", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Thailand", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]

// dictionary containing center lat & lon of countries
//var countryLatLonDict: [String: simd_double2] = [
//    "China": simd_double2(30, 100),
//    "Australia": simd_double2(-33, 151),
//    "Japan": simd_double2(35, 140),
//    "South Korea": simd_double2(37,127)
//]

var countryLatLonDict: [String: simd_double2] = [
    "Afghanistan": simd_double2(33.0, 65.0),
    "Albania": simd_double2(41.0, 20.0),
    "Algeria": simd_double2(28.0, 3.0),
    "American Samoa": simd_double2(-13.6, -172.3),
    "Andorra": simd_double2(42.5, 1.5),
    "Angola": simd_double2(-12.5, 18.5),
    "Anguilla": simd_double2(18.2, -63.2),
    "Antarctica": simd_double2(-90.0, 0.0),
    "Antigua and Barbuda": simd_double2(17.1, -61.8),
    "Argentina": simd_double2(-34.0, -64.0),
    "Armenia": simd_double2(40.0, 45.0),
    "Aruba": simd_double2(12.5, -70.0),
    "Australia": simd_double2(-27.0, 133.0),
    "Austria": simd_double2(47.3, 13.3),
    "Azerbaijan": simd_double2(40.5, 47.5),
    "Bahrain": simd_double2(26.0, 50.5),
    "Bangladesh": simd_double2(24.0, 90.0),
    "Barbados": simd_double2(13.2, -59.5),
    "Belgium": simd_double2(50.8, 4.0),
    "Belize": simd_double2(17.2, -88.8),
    "Benin": simd_double2(9.5, 2.2),
    "Bermuda": simd_double2(32.3, -64.8),
    "Bhutan": simd_double2(27.5, 90.5),
    "Bolivia": simd_double2(-17.0, -65.0),
    "Bosnia and Herzegovina": simd_double2(44.0, 18.0),
    "Botswana": simd_double2(-22.0, 24.0),
    "Bouvet Island": simd_double2(-54.4, 3.4),
    "Brazil": simd_double2(-10.0, -55.0),
    "British Indian Ocean Territory": simd_double2(-6.0, 71.5),
    "British Virgin Islands": simd_double2(18.4, -64.6),
    "Brunei": simd_double2(4.5, 114.7),
    "Bulgaria": simd_double2(43.0, 25.0),
    "Burkina Faso": simd_double2(13.0, -2.0),
    "Burundi": simd_double2(-3.5, 30.0),
    "Cambodia": simd_double2(13.0, 105.0),
    "Cameroon": simd_double2(6.0, 12.0),
    "Canada": simd_double2(60.0, -95.0),
    "Cape Verde": simd_double2(16.0, -24.0),
    "Cayman Islands": simd_double2(19.5, -80.5),
    "Central African Republic": simd_double2(7.0, 21.0),
    "Chad": simd_double2(15.0, 19.0),
    "Chile": simd_double2(-30.0, -71.0),
    "China": simd_double2(35.0, 105.0),
    "Christmas Island": simd_double2(-10.5, 105.7),
    "Cocos (Keeling) Islands": simd_double2(-12.5, 96.8),
    "Colombia": simd_double2(4.0, -72.0),
    "Comoros": simd_double2(-12.2, 44.2),
    "Cook Islands": simd_double2(-21.2, -159.8),
    "Costa Rica": simd_double2(10.0, -84.0),
    "Croatia": simd_double2(45.2, 15.5),
    "Cuba": simd_double2(21.5, -80.0),
    "Cyprus": simd_double2(35.0, 33.0),
    "Denmark": simd_double2(56.0, 10.0),
    "Djibouti": simd_double2(11.5, 43.0),
    "Dominica": simd_double2(15.4, -61.3),
    "Dominican Republic": simd_double2(19.0, -70.7),
    "Ecuador": simd_double2(-2.0, -77.5),
    "Egypt": simd_double2(27.0, 30.0),
    "El Salvador": simd_double2(13.8, -88.9),
    "Equatorial Guinea": simd_double2(2.0, 10.0),
    "Eritrea": simd_double2(15.0, 39.0),
    "Estonia": simd_double2(59.0, 26.0),
    "Ethiopia": simd_double2(8.0, 38.0),
    "Faroe Islands": simd_double2(62.0, -7.0),
    "Fiji": simd_double2(-18.0, 175.0),
    "Finland": simd_double2(64.0, 26.0),
    "France": simd_double2(46.0, 2.0),
    "French Guiana": simd_double2(4.0, -53.0),
    "French Polynesia": simd_double2(-15.0, -140.0),
    "Gabon": simd_double2(-1.0, 11.8),
    "Georgia": simd_double2(42.0, 43.5),
    "Germany": simd_double2(51.0, 9.0),
    "Ghana": simd_double2(8.0, -2.0),
    "Gibraltar": simd_double2(36.1, -5.3),
    "Greece": simd_double2(39.0, 22.0),
    "Greenland": simd_double2(72.0, -40.0),
    "Grenada": simd_double2(12.1, -61.7),
    "Guadeloupe": simd_double2(16.2, -61.6),
    "Guam": simd_double2(13.5, 144.8),
    "Guatemala": simd_double2(15.5, -90.2),
    "Guernsey": simd_double2(49.5, -2.6),
    "Guinea": simd_double2(11.0, -10.0),
    "Guinea-Bissau": simd_double2(12.0, -15.0),
    "Guyana": simd_double2(5.0, -59.0),
    "Haiti": simd_double2(19.0, -72.4),
    "Honduras": simd_double2(15.0, -86.5),
    "Hungary": simd_double2(47.0, 20.0),
    "Iceland": simd_double2(65.0, -18.0),
    "India": simd_double2(20.0, 77.0),
    "Indonesia": simd_double2(-5.0, 120.0),
    "Iran": simd_double2(32.0, 53.0),
    "Iraq": simd_double2(33.0, 44.0),
    "Ireland": simd_double2(53.0, -8.0),
    "Israel": simd_double2(31.5, 35.1),
    "Italy": simd_double2(42.8, 12.8),
    "Ivory Coast": simd_double2(8.0, -5.0),
    "Jamaica": simd_double2(18.2, -77.5),
    "Japan": simd_double2(36.0, 138.0),
    "Jersey": simd_double2(49.2, -2.2),
    "Jordan": simd_double2(31.0, 36.0),
    "Kazakhstan": simd_double2(48.0, 68.0),
    "Kenya": simd_double2(1.0, 38.0),
    "Kiribati": simd_double2(1.4, 173.0),
    "Kuwait": simd_double2(29.5, 45.8),
    "Kyrgyzstan": simd_double2(41.0, 75.0),
    "Laos": simd_double2(18.0, 105.0),
    "Latvia": simd_double2(57.0, 25.0),
    "Lebanon": simd_double2(33.8, 35.8),
    "Lesotho": simd_double2(-29.5, 28.5),
    "Liberia": simd_double2(6.5, -9.5),
    "Libya": simd_double2(25.0, 17.0),
    "Liechtenstein": simd_double2(47.3, 9.5),
    "Lithuania": simd_double2(56.0, 24.0),
    "Luxembourg": simd_double2(49.8, 6.2),
    "Macau": simd_double2(22.2, 113.5),
    "Madagascar": simd_double2(-20.0, 47.0),
    "Malawi": simd_double2(-13.5, 34.0),
    "Malaysia": simd_double2(2.5, 112.5),
    "Maldives": simd_double2(3.2, 73.0),
    "Mali": simd_double2(17.0, -4.0),
    "Malta": simd_double2(35.8, 14.6),
    "Marshall Islands": simd_double2(9.0, 168.0),
    "Martinique": simd_double2(14.7, -61.0),
    "Mauritania": simd_double2(20.0, -12.0),
    "Mauritius": simd_double2(-20.3, 57.5),
    "Mayotte": simd_double2(-12.8, 45.2),
    "Mexico": simd_double2(23.0, -102.0),
    "Moldova": simd_double2(47.0, 29.0),
    "Monaco": simd_double2(43.7, 7.4),
    "Mongolia": simd_double2(46.0, 105.0),
    "Montenegro": simd_double2(42.5, 19.3),
    "Montserrat": simd_double2(16.8, -62.2),
    "Morocco": simd_double2(32.0, -5.0),
    "Mozambique": simd_double2(-18.2, 35.0),
    "Namibia": simd_double2(-22.0, 17.0),
    "Nauru": simd_double2(-0.5, 166.9),
    "Nepal": simd_double2(28.0, 84.0),
    "Netherlands": simd_double2(52.5, 5.8),
    "New Caledonia": simd_double2(-21.5, 165.5),
    "New Zealand": simd_double2(-41.0, 174.0),
    "Nicaragua": simd_double2(13.0, -85.0),
    "Niger": simd_double2(16.0, 8.0),
    "Nigeria": simd_double2(10.0, 8.0),
    "Niue": simd_double2(-19.0, -169.9),
    "Norfolk Island": simd_double2(-29.0, 167.9),
    "North Korea": simd_double2(40.0, 127.0),
    "Northern Mariana Islands": simd_double2(15.2, 145.8),
    "Norway": simd_double2(62.0, 10.0),
    "Oman": simd_double2(21.0, 57.0),
    "Pakistan": simd_double2(30.0, 70.0),
    "Panama": simd_double2(9.0, -80.0),
    "Papua New Guinea": simd_double2(-6.0, 147.0),
    "Paraguay": simd_double2(-23.0, -58.0),
    "Peru": simd_double2(-10.0, -76.0),
    "Philippines": simd_double2(13.0, 122.0),
    "Pitcairn Islands": simd_double2(-25.1, -130.1),
    "Poland": simd_double2(52.0, 20.0),
    "Portugal": simd_double2(39.5, -8.0),
    "Puerto Rico": simd_double2(18.2, -66.5),
    "Qatar": simd_double2(25.5, 51.2),
    "Romania": simd_double2(46.0, 25.0),
    "Russia": simd_double2(60.0, 100.0),
    "Rwanda": simd_double2(-2.0, 30.0),
    "San Marino": simd_double2(43.8, 12.4),
    "Saudi Arabia": simd_double2(25.0, 45.0),
    "Senegal": simd_double2(14.0, -14.0),
    "Serbia": simd_double2(44.0, 21.0),
    "Seychelles": simd_double2(-4.6, 55.7),
    "Sierra Leone": simd_double2(8.5, -11.5),
    "Singapore": simd_double2(1.4, 103.8),
    "Slovakia": simd_double2(48.7, 19.5),
    "Slovenia": simd_double2(46.1, 14.8),
    "Solomon Islands": simd_double2(-8.0, 159.0),
    "Somalia": simd_double2(10.0, 49.0),
    "South Africa": simd_double2(-29.0, 24.0),
    "South Korea": simd_double2(37.0, 127.5),
    "Spain": simd_double2(40.0, -4.0),
    "Sri Lanka": simd_double2(7.0, 81.0),
    "Sudan": simd_double2(15.0, 30.0),
    "Suriname": simd_double2(4.0, -56.0),
    "Sweden": simd_double2(62.0, 15.0),
    "Switzerland": simd_double2(47.0, 8.0),
    "Syria": simd_double2(35.0, 38.0),
    "Taiwan": simd_double2(23.5, 121.0),
    "Tajikistan": simd_double2(39.0, 71.0),
    "Thailand": simd_double2(15.0, 100.0),
    "Togo": simd_double2(8.0, 1.2),
    "Tokelau": simd_double2(-9.0, -172.0),
    "Tonga": simd_double2(-20.0, -175.0),
    "Trinidad and Tobago": simd_double2(11.0, -61.0),
    "Tunisia": simd_double2(34.0, 9.0),
    "Turkey": simd_double2(39.0, 35.0),
    "Turkmenistan": simd_double2(40.0, 60.0),
    "Turks and Caicos Islands": simd_double2(21.8, -71.6),
    "Tuvalu": simd_double2(-8.0, 178.0),
    "Uganda": simd_double2(1.0, 32.0),
    "Ukraine": simd_double2(49.0, 32.0),
    "United Arab Emirates": simd_double2(24.0, 54.0),
    "United Kingdom": simd_double2(54.0, -2.0),
    "United States": simd_double2(38.0, -97.0),
    "Uruguay": simd_double2(-33.0, -56.0),
    "Uzbekistan": simd_double2(41.0, 64.0),
    "Vanuatu": simd_double2(-16.0, 167.0),
    "Venezuela": simd_double2(8.0, -66.0),
    "Vietnam": simd_double2(16.2, 107.8),
    "Wallis and Futuna": simd_double2(-13.3, -176.2),
    "Western Sahara": simd_double2(24.5, -13.0),
    "Yemen": simd_double2(15.0, 48.0),
    "Zambia": simd_double2(-15.0, 30.0),
    "Zimbabwe": simd_double2(-20.0, 30.0)
]

// for dict generation, won't be used during runtime
func generateCountryNameLongLatDict() {
    for index in 0..<countryNames.count{
        let name = countryNames[index]
        let nameForQuery = name.replacingOccurrences(of: " ", with: "%20")
        let latLon = getCountryLongLatFromName(country: nameForQuery)
        print("\"\(name)\": simd_double2(" + String(format: "%.1f", latLon[0]) + ", " + String(format: "%.1f", latLon[1]) + "),")
    }
}

// for dict generation, won't be used during runtime
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
    let sem = DispatchSemaphore(value: 0)
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
            sem.signal()
        } catch  {
            print("error trying to convert data to JSON")
            return
        }
    }
    task.resume()
    sem.wait()
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
