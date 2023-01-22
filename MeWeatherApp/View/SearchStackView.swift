//
//  SearchStackView.swift
//  MeWeatherApp
//
//  Created by aykut ipek on 12.01.2023.
//

import UIKit

protocol SearchStackViewDelegate: AnyObject {
    func didFetchWeather(_ searchStackView: SearchStackView, weatherModel: WeatherModel)
    func didFailWithError(_ searchStackView: SearchStackView, error: ServiceError)
    func updatingLocation(_ searchStackView: SearchStackView)
}

class SearchStackView : UIStackView {
    //MARK: Properties
    weak var delegate: SearchStackViewDelegate?
    private let searchTextField = UITextField()
    private let searchButton = UIButton(type: .system)
    private let service = WeatherService()
    private let locationButton = UIButton(type: .system)
    
    
    //MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//MARK: Functions
extension SearchStackView {
    private func setupUI(){
        style()
        layout()
    }
    
    
    private func style(){
        //searchTextField style
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.layer.cornerRadius = 40 / 2
        searchButton.tintColor = .label
        searchButton.contentVerticalAlignment = .fill
        searchButton.contentHorizontalAlignment = .fill
        searchButton.addTarget(self, action: #selector(handleSearchButton), for: .touchUpInside)
        
        
        //searchTextField style
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Şehir ismi giriniz",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        searchTextField.font = UIFont.preferredFont(forTextStyle: .title2)
        searchTextField.borderStyle = .roundedRect
        searchTextField.textAlignment = .left
        searchTextField.textColor = .white
        searchTextField.backgroundColor = .systemFill
        searchTextField.delegate = self


        //locationButton style
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        locationButton.tintColor = .label
        locationButton.layer.cornerRadius = 40 / 2
        locationButton.contentVerticalAlignment = .fill
        locationButton.contentHorizontalAlignment = .fill
        //locationButton.addTarget(self, action: #selector(handleLocationButton), for: .touchUpInside)
    }
    
    private func layout(){
        //add layout
        addArrangedSubview(searchTextField)
        addArrangedSubview(searchButton)
        addArrangedSubview(locationButton)
        
        
        //layout
        NSLayoutConstraint.activate([
            
            //searchTextField layout
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            
            //searchButton layout
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            searchButton.widthAnchor.constraint(equalToConstant: 45),
            
            locationButton.heightAnchor.constraint(equalToConstant: 40),
            locationButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}
// MARK: - Selector

extension SearchStackView{
    @objc private func handleSearchButton(_ sender: UIButton){
        self.searchTextField.endEditing(true)
    }
    @objc private func handleLocationButton(_ sender: UIButton){
        self.delegate?.updatingLocation(self)
    }
}

// MARK: - UITextFieldDelegate
extension SearchStackView : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.searchTextField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != ""{
            return true
        }else{
            searchTextField.placeholder = "Arama"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let cityName = searchTextField.text else { return }
        service.fetchWeatherCityName(forCityName: cityName) { result in
            switch result{
            case .success(let result):
                self.delegate?.didFetchWeather(self, weatherModel: result)
            case .failure(let error):
                self.delegate?.didFailWithError(self, error: error)
            }
        }
        self.searchTextField.text = ""
    }
}
