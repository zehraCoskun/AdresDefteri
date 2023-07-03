//
//  LocationTableVM.swift
//  Adres Defteri
//
//  Created by Zehra Coşkun on 9.06.2023.
//

import Foundation
import Firebase

struct LocationTableVM  {
    var locations = [Location]()
}

extension LocationTableVM {
    
    func numberOfRowsInSection () -> Int {
        return self.locations.count
    }
    
    func newAtIndexPath ( _ index: Int) -> LocationVM {
        let location = self.locations[index]
        return LocationVM(location: location)
    }
}

struct LocationVM {
    let location :Location
    var personName : String {
        return self.location.personName
    }
    var locationName : String {
        return self.location.locationName
    }
    var personImage : String {
        return self.location.personImage
    }
}

