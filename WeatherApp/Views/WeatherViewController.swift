//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by YK Poh on 20/06/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var conditionImageView: ImageLoader!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    @IBOutlet weak var currentConditionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    let viewModel = WeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "\(WeatherDetailTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(WeatherDetailTableViewCell.self)")
        
        locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }
        
        viewModel.locationButtonTitle.bind { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.locationButton.setTitle(value, for: .normal)
        }
        
        viewModel.conditionIconImageURL.bind { [weak self] value in
            guard let strongSelf = self else { return }
            if let value = value {
                strongSelf.conditionImageView.loadImageWithUrl(value)
            }
        }
        
        viewModel.conditionText.bind { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.conditionLabel.text = value
        }
        
        viewModel.feelsLikeTemperature.bind { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.feelsLikeLabel.text = value
        }
        
        viewModel.temperature.bind { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.temperatureLabel.text = value
        }
        
        viewModel.weatherDetails.bind { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
        
        viewModel.error.bind { [weak self] value in
            guard let strongSelf = self else { return }
            guard let value = value else { return }
            strongSelf.showAlert(value.localizedDescription)
        }
    }
    
    @objc func locationButtonPressed() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "\(SearchLocationController.self)") as? SearchLocationController
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latitude = manager.location?.coordinate.latitude, let longitude = manager.location?.coordinate.longitude else { return }
        viewModel.getCurrentWeather(latitude: latitude, longitude: longitude)
    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .denied, .notDetermined, .restricted:
//            locationManager.requestWhenInUseAuthorization()
//        default:
//            print("location not allowed")
//        }
//    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.weatherDetails.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(WeatherDetailTableViewCell.self)", for: indexPath) as! WeatherDetailTableViewCell
        cell.configure(viewModel: viewModel.weatherDetails.value[indexPath.row])
        return cell
    }
}
