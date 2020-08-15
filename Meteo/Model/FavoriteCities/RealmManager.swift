//
//  RealmManager.swift
//  Meteo
//
//  Created by Massimiliano Bonafede on 09/08/2020.
//  Copyright © 2020 Massimiliano Bonafede. All rights reserved.
//

import UIKit
import RealmSwift


protocol RealmWeatherManagerDelegate: class {
    func retriveResultsDidFinished(_ weather: WeatherGeneralManager)
}


class RealmManager {
    
    var delegation: RealmWeatherManagerDelegate?
    var weatherFetchManager: WeatherFetchManager?
    var isElementsAreEmpty: Bool = false
    
    func saveWeather(_ cityName: String, _ latitude: Double, _ longitude: Double) {
        
        do {
            let realm = try Realm.init()
            
            let weather = RealmWeatherManager.init()
            weather.name = cityName
            weather.latitude = latitude
            weather.longitude = longitude
            
            try realm.write {
                realm.add(weather)
                debugPrint("ITEM ADDED: \(cityName)")
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
   

    func retriveWeatherForFetchManager(completion: @escaping() -> ()) {
        
        do {
            let realm = try Realm.init()
            
            let results = realm.objects(RealmWeatherManager.self)
            
            if results.count == 0 {
                isElementsAreEmpty = true
            } else {
                isElementsAreEmpty = false
            }
            
            for i in results {
                weatherFetchManager = WeatherFetchManager(latitude: i.latitude, longitude: i.longitude){ weatherManager in
                    self.delegation?.retriveResultsDidFinished(weatherManager)
                }
                
                completion()
            }
            
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }

    
    func deleteWeather(_ index: IndexPath) {
        
        do {
            let realm = try Realm.init()
            
            let results = realm.objects(RealmWeatherManager.self)
            
            try realm.write {
                realm.delete(results[index.row])
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
    }
}
