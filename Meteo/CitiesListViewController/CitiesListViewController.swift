//
//  CitiesListViewController.swift
//  Meteo
//
//  Created by Massimiliano Bonafede on 03/08/2020.
//  Copyright © 2020 Massimiliano Bonafede. All rights reserved.
//

import UIKit

class CitiesListViewController: UIViewController, Storyboarded {
    
    
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: - Properies
    var coordinator: MainCoordinator?
    var delegate: MainViewControllerLocationDelegate?
    var citiesResult: [CitiesList]?
    var dataSource: CitiesListDataSource?
    var citiesArray: [CitiesList]? {
        coordinator?.smartManager?.allCities?.cities
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Search"
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        let leftButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelTapped(_:)))
        navigationItem.leftBarButtonItem = leftButton
        
        let nib = UINib(nibName: "CitiesListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cityCell")
        
        dataSource = CitiesListDataSource(cities: citiesArray!)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.reloadData()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView()
    }
    
    
    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        coordinator?.cameFromCitiesList = false
        coordinator?.cameFromPreferedWeather = false
        coordinator?.popViewController()
    }
    
}

//MARK: - UITableVIewDelegate

extension CitiesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var result: CitiesList?
        
        if let citiesResult = citiesResult {
            result = citiesResult[indexPath.row]
        } else {
            result = citiesArray?[indexPath.row]
        }
        
        coordinator?.cameFromCitiesList = true
        coordinator?.smartManager?.city = result
        coordinator?.popViewController()
    }
}

//MARK: - UISearchBarDelegate

extension CitiesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        citiesResult = citiesArray?.filter { $0.name.prefix(searchText.count) == searchText}
        dataSource? = CitiesListDataSource(cities: citiesResult ?? [])
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
}
