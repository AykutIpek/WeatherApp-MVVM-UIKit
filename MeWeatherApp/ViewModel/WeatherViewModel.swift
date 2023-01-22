//
//  WeatherViewModel.swift
//  MeWeatherApp
//
//  Created by aykut ipek on 12.01.2023.
//

import Foundation

struct WeatherViewModel{
    let id : Int
    let cityName : String
    let temparature : Double
    init(weatherModel: WeatherModel) {
        self.id = weatherModel.weather[0].id
        self.cityName = weatherModel.name
        self.temparature = weatherModel.main.temp
    }
    
    var temparatureString: String?{
        return String(format: "%.0f", temparature)
    }
    
    var statusName : String {
        switch id {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}

