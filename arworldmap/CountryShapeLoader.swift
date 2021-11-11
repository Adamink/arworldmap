import UIKit

struct Collection : Decodable {
    let type : String
    let features : [Feature]
}

struct Feature : Decodable {
    let type : String
    let geometry : Geometry
    let properties : Properties
}

struct Geometry : Decodable {
    let type : String
    let coordinates : [[Point]]
}

struct Point : Decodable {
    let lat: Double
    let lon : Double
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        lat = try container.decode(Double.self)
        lon = try container.decode(Double.self)
    }
}

struct Properties : Decodable {
    let join_name : String
    let cntry_name : String
}

class CountryShapeLoader {
    public func parse(){
        if let urlBar = Bundle.main.url(forResource: "sample_country_shapes", withExtension: "geojson") {
            do {
                let jsonData = try Data(contentsOf: urlBar)
                let result = try JSONDecoder().decode(Collection.self, from: jsonData)
                for feature in result.features {
                    print("join_name", feature.properties.join_name, "cntry_name", feature.properties.cntry_name)
                    print("(lat, long) = ", feature.geometry.coordinates[0][0].lon, feature.geometry.coordinates[0][0].lat)
                }
            } catch { print("Error while parsing: \(error)") }
        }
    }
}

var countryLoader = CountryLoader()
countryLoader.parse()
