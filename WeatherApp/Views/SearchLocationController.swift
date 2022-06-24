//
//  SearchLocationController.swift
//  WeatherApp
//
//  Created by YK Poh on 21/06/2022.
//

import UIKit

class SearchLocationController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search Location..."
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        return searchController
    }()
    
    var viewModel: SearchLocationViewModelProtocol = SearchLocationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "\(SearchResultTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(SearchResultTableViewCell.self)")
        
        setupSubscribers()
    }
    
    func setupSubscribers() {
        viewModel.searchResults.bind { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
        }
        
        viewModel.errorMessage.bind { [weak self] value in
            guard let strongSelf = self else { return }
            guard let value = value else { return }
            strongSelf.showAlert(value)
        }
    }
    
}

extension SearchLocationController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        viewModel.getLocationSearchResult(query: text)
    }
}

extension SearchLocationController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SearchResultTableViewCell.self)", for: indexPath) as! SearchResultTableViewCell
        cell.configure(viewModel: viewModel.searchResults.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let location = viewModel.searchResults.value[indexPath.row].location.value else { return }
        viewModel.postNotification(location: location)
        navigationController?.popViewController(animated: true)
    }
    
}
