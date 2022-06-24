//
//  SearchLocationControllerTests.swift
//  WeatherAppTests
//
//  Created by YK Poh on 24/06/2022.
//

import XCTest
@testable import WeatherApp

class SearchLocationControllerTests: XCTestCase {
    
    var sut: SearchLocationController!
    var mockViewModel: MockSearchLocationViewModel!
    var mockNavigationController: MockNavigationController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(SearchLocationController.self)") as? SearchLocationController
        mockViewModel = MockSearchLocationViewModel()
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
    
    func testNavigationItemSearchController() {
        XCTAssertNotNil(sut.searchController)
        XCTAssertEqual(sut.navigationItem.searchController, sut.searchController)
    }
    
    func testHidesSearchBarWhenScrolling_ReturnsFalse() {
        XCTAssertFalse(sut.navigationItem.hidesSearchBarWhenScrolling)
    }

    func testTableViewDataSource_ViewDidLoad_SetsTableViewDataSource() {
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertTrue(sut.tableView.dataSource is SearchLocationController)
    }
    
    func testTableViewDelegate_ViewDidLoad_SetsTableViewDelegate() {
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertTrue(sut.tableView.delegate is SearchLocationController)
    }
    
    func testTableViewShowsVerticalScrollIndicator_ReturnsFalse() {
        XCTAssertFalse(sut.tableView.showsVerticalScrollIndicator)
    }
    
    func testSearchController_SetsDelegate() {
        XCTAssertNotNil(sut.searchController.delegate)
        XCTAssertTrue(sut.searchController.delegate is SearchLocationController)
    }
    
    func testSearchController_SetsSearchResultsUpdater() {
        XCTAssertNotNil(sut.searchController.searchResultsUpdater)
        XCTAssertTrue(sut.searchController.searchResultsUpdater is SearchLocationController)
    }
    
    func testTableView_AssignSearchResults_ReturnsSearchResultTableViewCell() {
        // given
        let locations: [Location] = getModel(filename: "Search")
        let searchResults = locations.compactMap {
            SearchResultTVCViewModel(address: "\($0.name ?? ""), \($0.region ?? ""), \($0.country ?? "")", location: $0)
        }
        
        // when
        mockViewModel.searchResults.value = searchResults
        
        // then
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 10)
        let cellQueried = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SearchResultTableViewCell
        XCTAssertEqual(cellQueried?.viewModel, searchResults.first)
    }
    
    func testTableViewDidSelectRow_PostNotificationAndPopViewController() {
        // given
        let locations: [Location] = getModel(filename: "Search")
        let searchResults = locations.compactMap {
            SearchResultTVCViewModel(address: "\($0.name ?? ""), \($0.region ?? ""), \($0.country ?? "")", location: $0)
        }
        mockViewModel.searchResults.value = searchResults
        
        // when
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        // then
        let location = try! XCTUnwrap(mockViewModel.postNotificationLocation)
        XCTAssertEqual(location, locations.first)
        XCTAssertTrue(mockNavigationController.popViewControllerCalled)
        XCTAssertTrue(mockNavigationController.popViewControllerAnimated)
    }
    
    func testShowAlert_WhenErrorMessageIsNotNil_PresentAlert() {
        let mockViewController = MockSearchLocationController()
        let mockViewModel = MockSearchLocationViewModel()
        mockViewController.viewModel = mockViewModel
        _ = mockViewController.view
        
        mockViewModel.errorMessage.value = "Invalid Response"
        
        let alertController = try! XCTUnwrap(mockViewController.viewControllerToPresent as? UIAlertController)
        XCTAssertEqual(mockViewController.presentAnimated, true)
        XCTAssertNil(mockViewController.presentCompletion)
        XCTAssertEqual(alertController.title, "Error")
        XCTAssertEqual(alertController.message, "Invalid Response")
        XCTAssertEqual(alertController.actions.count, 1)
        let alertAction = try! XCTUnwrap(alertController.actions.first)
        XCTAssertEqual(alertAction.title, "Ok")
        XCTAssertEqual(alertAction.style, .cancel)
    }
    
    func testUpdateSearchResult_WhenTextIsNotEmpty() {
        sut.searchController.searchBar.text = "Lond"
        sut.searchController.searchResultsUpdater?.updateSearchResults(for: sut.searchController)
        XCTAssertNotNil(mockViewModel.getLocationSearchResultQuery)
        XCTAssertEqual(mockViewModel.getLocationSearchResultQuery, "Lond")
    }
    
    func testUpdateSearchResult_WhenTextIsEmpty() {
        sut.searchController.searchBar.text = ""
        sut.searchController.searchResultsUpdater?.updateSearchResults(for: sut.searchController)
        XCTAssertNil(mockViewModel.getLocationSearchResultQuery)
    }
}

class MockSearchLocationViewModel: SearchLocationViewModelProtocol {
    var getLocationSearchResultQuery: String?
    
    var postNotificationLocation: Location?
    
    var searchResults: Box<[SearchResultTVCViewModel]> = Box([])
    
    var errorMessage: Box<String?> = Box(nil)
    
    func getLocationSearchResult(query: String) {
        getLocationSearchResultQuery = query
    }
    
    func postNotification(location: Location) {
        postNotificationLocation = location
    }
}

class MockNavigationController: UINavigationController {
    var popViewControllerCalled = false
    var popViewControllerAnimated = false
    
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerAnimated = animated
        popViewControllerCalled = true
        return super.popViewController(animated: animated)
    }
}

class MockSearchLocationController: SearchLocationController {
    override var tableView: UITableView! {
        get {
            return UITableView()
        }
        set {
            super.tableView = newValue
        }
    }
    
    var viewControllerToPresent: UIViewController?
    var presentAnimated = false
    var presentCompletion: (() -> Void)?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        self.viewControllerToPresent = viewControllerToPresent
        presentAnimated = flag
        presentCompletion = completion
    }
}
