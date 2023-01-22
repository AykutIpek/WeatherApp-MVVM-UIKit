//
//  ViewController.swift
//  MeWeatherApp
//
//  Created by aykut ipek on 12.01.2023.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    var viewModel : WeatherViewModel? {
        didSet{ configure() }
    }
    // MARK: - Properties
    private let backgroundImageView = UIImageView()
    private let statusImageView = UIImageView()
    private let searchStackView = SearchStackView()
    private let mainStackView = UIStackView()
    private let statusStackView = UIStackView()
    private let temperatureLabel = UILabel()
    private let cityLabel = UILabel()
    private let locationManager = CLLocationManager()
    private let service = WeatherService()
    private let locationButton = UIButton(type: .system)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureLocation()
    }
}

// MARK: - Functions
extension HomeViewController {
    
    private func setupUI(){
        style()
        layout()
    }
    
    private func style(){
        //image style
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = #imageLiteral(resourceName: "background")
        
        //mainstack View
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.spacing = 10
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        
        //statusImageView style
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.image = UIImage(systemName: "sun.max")
        statusImageView.tintColor = .label
        
        //temperatureLable style
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 80)
        temperatureLabel.attributedText = attributedText(with: "15")
        
        //cityLabel style
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = UIFont.systemFont(ofSize: 60)
        cityLabel.text = "İzmir"
        
        //searchStackView style
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.spacing = 8
        searchStackView.axis = .horizontal
    }
    
    private func configureProperties(){
        view.addSubview(backgroundImageView)
        view.addSubview(mainStackView)
        view.addSubview(locationButton)
    }
    
    private func configureStackView(){
        //MainStackView add item
        mainStackView.addArrangedSubview(searchStackView)
        mainStackView.addArrangedSubview(statusImageView)
        mainStackView.addArrangedSubview(temperatureLabel)
        mainStackView.addArrangedSubview(cityLabel)
    }
    
    
    private func layout(){
        configureProperties()
        configureStackView()
        
        
        NSLayoutConstraint.activate([
            //backgroundImageView layout
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //mainStackView layout
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            //searchStackView layout
            searchStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            
            //statusImageView layout
            statusImageView.heightAnchor.constraint(equalToConstant: 150),
            statusImageView.widthAnchor.constraint(equalToConstant: 150),
            
            //locationbutton layout
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor , constant: -10),
            locationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor , constant: -20),
            locationButton.leadingAnchor.constraint(equalTo: view.trailingAnchor , constant: -90),
            locationButton.topAnchor.constraint(equalTo: view.bottomAnchor , constant: -100)
            
        ])
    }
    
    
    private func attributedText(with text: String) -> NSMutableAttributedString{
        let attributedText = NSMutableAttributedString(string: text, attributes: [.foregroundColor : UIColor.label, .font: UIFont.boldSystemFont(ofSize: 90)])
        attributedText.append(NSAttributedString(string: "°C",attributes: [.font: UIFont.systemFont(ofSize: 50)]))
        return attributedText
    }
    
    private func configureLocation(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    private func configure(){
        guard let viewModel = self.viewModel else {return}
        self.cityLabel.text = viewModel.cityName
        self.temperatureLabel.attributedText = attributedText(with: viewModel.temparatureString!)
        self.statusImageView.image = UIImage(systemName: viewModel.statusName)
    }
    
    private func showErrorAlert(forErrorMessage message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    private func parseError(error: ServiceError){
        switch error{
        case .serverError:
            showErrorAlert(forErrorMessage: error.rawValue)
        case .decodingError:
            showErrorAlert(forErrorMessage: error.rawValue)
        }
    } 
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        locationManager.stopUpdatingLocation()
        self.service.fetchWeatherLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
            switch result{
            case .success(let result):
                self.viewModel = WeatherViewModel(weatherModel: result)
            case .failure(let error):
                self.parseError(error: error)
            }
        }
    }
}
// MARK: - SearchStackViewDelegate
extension HomeViewController: SearchStackViewDelegate{
    func updatingLocation(_ searchStackView: SearchStackView) {
        self.locationManager.startUpdatingLocation()
    }
    func didFailWithError(_ searchStackView: SearchStackView, error: ServiceError) {
        parseError(error: error)
    }
    func didFetchWeather(_ searchStackView: SearchStackView, weatherModel: WeatherModel) {
        self.viewModel = WeatherViewModel(weatherModel: weatherModel)
    }
}
