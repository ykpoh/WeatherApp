//
//  WeatherViewControllerTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 24/06/2022.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class WeatherViewControllerTests: XCTestCase {
    
    var sut: WeatherViewController!
    var mockViewModel: MockWeatherViewModel!
    var mockNavigationController: MockNavigationController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(WeatherViewController.self)") as? WeatherViewController
        mockViewModel = MockWeatherViewModel()
        mockNavigationController = MockNavigationController()
        sut.viewModel = mockViewModel
        mockNavigationController
                    = MockNavigationController(rootViewController: sut)
        _ = sut.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockViewModel = nil
        mockNavigationController = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testTableViewNotNil() {
        XCTAssertNotNil(sut.tableView)
    }

    func testTableViewDataSource_ViewDidLoad_SetsTableViewDataSource() {
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertTrue(sut.tableView.dataSource is WeatherViewController)
    }
    
    func testTableViewDelegate_ViewDidLoad_SetsTableViewDelegate() {
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertTrue(sut.tableView.delegate is WeatherViewController)
    }
    
    func testSetLocationButtonTitle() {
        mockViewModel.locationButtonTitle.value = "button title"
        XCTAssertEqual(sut.locationButton.title(for: .normal), "button title")
    }
    
    func testConditionLabelText() {
        mockViewModel.conditionText.value = "Cloudy"
        XCTAssertEqual(sut.conditionLabel.text, "Cloudy")
    }
    
    func testFeelsLikeTemperature() {
        mockViewModel.feelsLikeTemperature.value = "Feels like 25°"
        XCTAssertEqual(sut.feelsLikeLabel.text, "Feels like 25°")
    }
    
    func testTemperature() {
        mockViewModel.temperature.value = "25°"
        XCTAssertEqual(sut.temperatureLabel.text, "25°")
    }
    
    func testTableView_AssignSearchResults_ReturnsSearchResultTableViewCell() {
        // given
        let currentWeather: CurrentWeather = getModel(filename: "Current")
        let weatherDetailViewModels = parseCurrentWeatherResponse(currentWeather)
        
        // when
        mockViewModel.weatherDetails.value = weatherDetailViewModels
        
        // then
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 5)
        let cellQueried = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? WeatherDetailTableViewCell
        XCTAssertEqual(cellQueried?.viewModel, weatherDetailViewModels.first)
    }
    
    func testPushSearchLocationController_WhenPressLocationButton() {
        sut.locationButtonPressed()
        
        let exp = expectation(description: "sonething")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
            XCTAssertEqual(self.mockNavigationController.viewControllers.count, 2)
            XCTAssertTrue(self.mockNavigationController.viewControllers.last is SearchLocationController)
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 2.0)
    }

    private func parseCurrentWeatherResponse(_ response: CurrentWeather) -> [WeatherDetailTVCViewModel] {
        var weatherDetailViewModels = [WeatherDetailTVCViewModel]()
        
        if let current = response.current {
            let wind = WeatherDetailTVCViewModel(title: "Wind", value: "\(current.windDir ?? "") \(current.windKph ?? 0.0) km/h")
            weatherDetailViewModels.append(wind)
            
            let windGust = WeatherDetailTVCViewModel(title: "Wind Gust", value: "\(current.gustKph ?? 0.0) km/h")
            weatherDetailViewModels.append(windGust)
            
            let humidity = WeatherDetailTVCViewModel(title: "Humidity", value: "\(current.humidity ?? 0.0)%")
            weatherDetailViewModels.append(humidity)
            
            let pressure = WeatherDetailTVCViewModel(title: "Pressure", value: "\(current.pressureMB ?? 0.0) mb")
            weatherDetailViewModels.append(pressure)
            
            let visibility = WeatherDetailTVCViewModel(title: "Visibility", value: "\(current.visKM ?? 0.0) km")
            weatherDetailViewModels.append(visibility)
        }
        
        return weatherDetailViewModels
    }
}

class MockWeatherViewModel: WeatherViewModelProtocol {
    var locationButtonTitle: Box<String?> = Box(nil)
    
    var temperature: Box<String?> = Box(nil)
    
    var conditionText: Box<String?> = Box(nil)
    
    var conditionIconImageURL: Box<URL?> = Box(nil)
    
    var feelsLikeTemperature: Box<String?> = Box(nil)
    
    var weatherDetails: Box<[WeatherDetailTVCViewModel]>  = Box([])
    
    var errorMessage: Box<String?> = Box(nil)
    
    var showSpinner: Box<Bool> = Box(false)
    
    func getCurrentWeather(latitude: Double, longitude: Double) {
        
    }
    
    func updateLocation(_ notification: Notification) {
        
    }
}
