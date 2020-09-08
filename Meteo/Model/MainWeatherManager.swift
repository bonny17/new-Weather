//
//  MainWeatherManager.swift
//  Meteo
//
//  Created by Massimiliano Bonafede on 01/09/2020.
//  Copyright © 2020 Massimiliano Bonafede. All rights reserved.
//
//
//import UIKit
//import Alamofire
//import SwiftyJSON
//
//
//protocol MainWeatherManagerDelegate: class {
//    func weatherDataDidFinischedToFetch(weather: WeatherGeneralManager)
//}
//
//class MainWeatherManager: NSObject {
//    
//    fileprivate var realmManager: RealmManager?
//    fileprivate var weatherCities: WeatherGeneralManager?
//    var delegate: MainWeatherManagerDelegate?
//    
//    init(latitude: Double, longitude: Double) {
//        super.init()
//        
//        getMyWeatherData(forLatitude: latitude, forLongitude: longitude) { [weak self] in
//            
//            guard let self = self else { return }
//            
//            self.delegate?.weatherDataDidFinischedToFetch(weather: $0)
//        }
//    }
//    
//    
//    fileprivate func getMyWeatherData(forLatitude latitude: Double, forLongitude longitude: Double, completion: @escaping (WeatherGeneralManager) -> ()){
//        
//        guard let language = Locale.current.languageCode else { return }
//        
//        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&lang=\(language)&APPID=b40d5e51a29e2610c4746682f85099b2&units=metric") else { return }
//        
//        AF.request(url).responseJSON { (response) in
//            switch response.result{
//            case .success(let value):
//                let json: JSON = JSON(arrayLiteral: value)
//                debugPrint(json)
//                let weather = self.JSONTransform(json)
//                print("DONEEEEEEEEEEEEEEEEEEEEEEEE")
//                completion(weather)
//                
//            case .failure(let error):
//                print(error.localizedDescription)
//                MyAlert.alertError(forError: error.localizedDescription, forViewController: MainViewController())
//            }
//        }
//    }
//    
//    
//
//    fileprivate func JSONTransform(_ json: JSON) -> WeatherGeneralManager {
//        //fetchCitiesFromJONS()
//        let name = "\(json[0]["city"]["name"])"
//        let population = Int("\(json[0]["city"]["population"])") ?? 0
//        let country = "\(json[0]["city"]["country"])"
//        let temperature = Double("\(json[0]["list"][0]["main"]["temp"])") ?? 0.0
//        let id = Int("\(json[0]["list"][0]["weather"][0]["id"])") ?? 0
//        let sunrise = Double("\(json[0]["city"]["sunrise"])") ?? 0.0
//        let sunset = Double("\(json[0]["city"]["sunset"])") ?? 0.0
//        
//        let list = json[0]["list"]
//        
//        var weatherCell: [WeatherGeneralManagerCell] = []
//        for i in 0 ... list.count - 1{
//            let temperatureMax = Double("\(json[0]["list"][i]["main"]["temp_max"])")!
//            let temperatureMin = Double("\(json[0]["list"][i]["main"]["temp_min"])")!
//            let weatherID = Int("\(json[0]["list"][i]["weather"][0]["id"])")!
//            let description = "\(json[0]["list"][i]["weather"][0]["description"])"
//            let time = "\(json[0]["list"][i]["dt_txt"])"
//            
//            let cell = WeatherGeneralManagerCell(tempMax: temperatureMax, tempMin: temperatureMin, conditionID: weatherID, description: description, time: time)
//            
//            weatherCell.append(cell)
//        }
//            
//        var weatherGeneralManager: WeatherGeneralManager?
//        weatherGeneralManager = WeatherGeneralManager(name: name, population: population, country: country, temperature: temperature, conditionID: id, sunset: sunset,sunrise: sunrise, weathersCell: weatherCell)
//        
//        return weatherGeneralManager!
//        
//    }
//}
