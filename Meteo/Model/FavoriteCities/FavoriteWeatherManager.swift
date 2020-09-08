//
//  WeatherManager.swift
//  Meteo
//
//  Created by Massimiliano Bonafede on 12/08/2020.
//  Copyright © 2020 Massimiliano Bonafede. All rights reserved.
//

//import UIKit
//
//
//class WeatherManagerModel {
//    var arrayName: [String] = []
//    var arrayForCell: [WeatherGeneralManagerCell] = []
//    var arrayConditon: [WeatherGeneralManager.WeatherCondition] = []
//    var arrayImages: [UIImage] = []
//    var arrayGradi: [String] = []
//    
//    func deleteAll() {
//        arrayName.removeAll()
//        arrayForCell.removeAll()
//        arrayConditon.removeAll()
//        arrayImages.removeAll()
//        arrayGradi.removeAll()
//    }
//}
//
//
//class FavoriteWeatherManager {
//    
//    var weather = WeatherManagerModel()
//    var isLimitBeenOver: Bool = false
//    fileprivate var cell: [[WeatherGeneralManagerCell]] = []
//    fileprivate var weatherFetchManager = WeatherFetchManager()
//    var isEmptyDataBase: Bool {
//        realmManager.isElementsAreEmpty
//    }
//    fileprivate var realmManager: RealmManager
//    
//    init(completion:@escaping () -> ()) {
//        self.realmManager = RealmManager()
//        self.realmManager.delegation = self
//        self.realmManager.retriveWeatherForFetchManager()
//        DispatchQueue.main.async {
//            completion()
//        }
//    }
//    
//    init() {
//        self.realmManager = RealmManager()
//        self.realmManager.delegation = self
//        DispatchQueue.main.async {
//            
//            self.realmManager.checkForLimitsCitySaved { (result) in
//                if result == true {
//                    self.isLimitBeenOver = true
//                } else {
//                    self.isLimitBeenOver = false
//                }
//                self.realmManager.retriveWeatherForFetchManager()
//            }
//        }
//        
//    }
//}
//
//
//extension FavoriteWeatherManager: RealmWeatherManagerDelegate {
//    func retriveEmptyResult() {
//        debugPrint("No Item Saved Into Database !!!")
//    }
//    
//    func retriveResultsDidFinished(_ weather: WeatherGeneralManager) {
//        self.cell.append(weather.weathersCell)
//        self.weather.arrayGradi.append(weather.temperatureString)
//        self.weather.arrayName.append(weather.name)
//        self.weather.arrayConditon.append(weather.condition)
//        self.weather.arrayImages.append(UIImage(named: weather.condition.getWeatherConditionFromID(weatherID: weather.conditionID).rawValue)!)
//        self.weather.arrayForCell = cell.first!
//    }
//    
//}
