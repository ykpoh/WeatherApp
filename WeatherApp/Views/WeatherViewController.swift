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
    
    lazy var hoverView: UIView = {
        let hoverView = UIView(frame: view.bounds)
        hoverView.translatesAutoresizingMaskIntoConstraints = false
        hoverView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        return hoverView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = hoverView.center
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    let locationManager = CLLocationManager()
    
    var viewModel: WeatherViewModelProtocol = WeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "\(WeatherDetailTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(WeatherDetailTableViewCell.self)")
        
        locationButton.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
        
        requestLocationAccess()
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
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
        
        viewModel.errorMessage.bind { [weak self] value in
            guard let strongSelf = self else { return }
            guard let value = value else { return }
            strongSelf.showAlert(value)
        }
        
        viewModel.showSpinner.bind { [weak self] value in
            guard let strongSelf = self else { return }
            if value {
                strongSelf.showSpinner()
            } else {
                strongSelf.removeSpinner()
            }
        }
    }
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
        
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            presentAllowLocationAlert()
        default:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation()
            } else {
                presentAllowLocationAlert()
            }
        }
    }
    
    @objc func locationButtonPressed() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "\(SearchLocationController.self)") as? SearchLocationController
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}

// MARK: UI helpers
extension WeatherViewController {
    func showSpinner() {
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.addSubview(hoverView)
    }
    
    func removeSpinner() {
        hoverView.removeFromSuperview()
        activityIndicator.removeFromSuperview()
    }
    
    private func presentAllowLocationAlert() {
        let alertController = UIAlertController(title: "WeatherApp works best with Location Services turned on.", message: "You will get accurate weather forecast based on your current location when you turn on Location Services for WeatherApp", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Keep Location Services Off", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Turn On in Settings", style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        present(alertController, animated: true, completion: nil)
    }
}

class MockLocationManager: CLLocationManager {
    override func requestLocation() {
        super.requestLocation()
        delegate?.locationManager?(self, didUpdateLocations: [CLLocation()])
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latitude = manager.location?.coordinate.latitude, let longitude = manager.location?.coordinate.longitude else { return }
        viewModel.getCurrentWeather(latitude: latitude, longitude: longitude)
    }
    
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
