//
//  WeatherService.swift
//  MeWeatherApp
//
//  Created by aykut ipek on 12.01.2023.
//

import UIKit
import CoreLocation

enum ServiceError : String , Error {
    case serverError = "İnternet bağlantınızı kontrol ediniz"
    case decodingError = "Decoding Error"
}


struct WeatherService {
    
    let url = "https://api.openweathermap.org/data/2.5/weather?&appid=7f5b84111382553370612153fd214b6b&units=metric"
    
    func fetchWeatherCityName(forCityName cityName: String , completion: @escaping(Result<WeatherModel,ServiceError>) -> Void){
        let url = URL(string: "\(url)&q=\(cityName)")!
        fetchWeather(url: url, completion: completion)
    }
    
    func fetchWeatherLocation(latitude: CLLocationDegrees,longitude: CLLocationDegrees ,completion: @escaping(Result<WeatherModel,ServiceError>) -> Void){
        let url = URL(string: "\(url)&lat=\(latitude)&lon=\(longitude)")!
        fetchWeather(url: url, completion: completion)
    }
          
    
    private func fetchWeather(url: URL, completion: @escaping(Result<WeatherModel,ServiceError>) -> Void){
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(.failure(.serverError))
                    return
                }
                guard let data = data else {return}
                guard let result = parseJSON(data: data) else {
                    completion(.failure(.decodingError))
                    return
                }
                completion(.success(result))
            }
        }.resume()
    }
    
    private func parseJSON(data: Data) -> WeatherModel?{
        do {
            let result = try JSONDecoder().decode(WeatherModel.self, from: data)
            return result
        } catch  {
            return nil
        }
    }
}
