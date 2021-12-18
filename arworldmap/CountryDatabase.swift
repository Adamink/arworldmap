import Foundation
import UIKit
import MapKit

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}

class CountryDatabase {
    func findCountryByLonLat(lon: Double, lat: Double) -> String? {
        let location = CLLocation(latitude: lon, longitude: lat)
        var result: String?
        location.fetchCityAndCountry { city, country, error in
            guard let _ = city, let country = country, error == nil else { return }
            result = country
        }
        return result
    }
}
