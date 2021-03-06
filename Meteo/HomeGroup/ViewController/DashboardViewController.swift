//
//  DashboardViewController.swift
//  Meteo
//
//  Created by Bonafede Massimiliano on 18/05/21.
//  Copyright © 2021 Massimiliano Bonafede. All rights reserved.
//

import UIKit
import Lottie
import Combine

func setSearchForFirstTime(_ value: Bool) {
    let userdeafult = UserDefaults.standard
    userdeafult.set(value, forKey: "searchForFirstTime")
}

func retriveSearchForFirstTime() -> Bool {
    let userdeafult = UserDefaults.standard
    return userdeafult.bool(forKey: "searchForFirstTime")
}

class DashboardViewController: BaseViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var mainWeatherImage: UIImageView!
    
    // MIDDLE SCROLL VIEW
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    
    // BOTTOM LABEL
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    
    //MARK: - Properties
    
    var viewModel = DashboardViewModel()
    private var cancelBag = Set<AnyCancellable>()
    private let menuButton = UIButton()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.animationIsNeeded = true
        
        viewModel.$_weatherObject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self, let result = result else { return }
                self.setupUIForWeather(result)
                self.animationIsNeeded = false
            }
            .store(in: &cancelBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createBarButtonMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        menuButton.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func createBarButtonMenu() {
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        menuButton.addTarget(self, action: #selector(menuIsPressed(_:)), for: .touchUpInside)
        let menuImage = UIImage(named: "menu")
        menuButton.setImage(menuImage, for: .normal)
        
        let buttonRatio = (navigationBar.frame.height - 10)
        
        ConstraintBuilder.setupConstraintFor(
            child: menuButton,
            into: navigationBar,
            constraints: [
                .height(constant: buttonRatio),
                .width(constant: buttonRatio),
                .centerY(),
                .leading(constant: 10)
            ]
        )
    }
    
    @objc func menuIsPressed(_ sender: UIButton) {
        viewModel.delegate?.openSideMenu(
            parent: self,
            height: view.frame.height,
            width: view.frame.width,
            navigationBarHeight: navigationController?.navigationBar.frame.height ?? 0
        )
    }
    
    //MARK: - Methods
    
    private func setupUIForWeather(_ weather: JSONObject) {
        let temp = weather.list.first!.main.temp.temperatureString
        self.title = "\(weather.city.name) \(temp)°C"
        self.populationLabel.text = "Population: \(weather.city.population)"
        self.mainWeatherImage.image = (weather.list.first?.weather.first?.id.weatherImage)
        self.sunriseLabel.text = weather.city.sunrise.transformTimestampToString()
        self.sunsetLabel.text = weather.city.sunset.transformTimestampToString()
        self.setupMiddleWeatherCards(with: weather.list)
    }
    
    private func setupMiddleWeatherCards(with list: [JSONObjectList]) {
        horizontalScrollView.subviews.forEach { $0.removeFromSuperview() }
        
        var containerView: [UIView] = []
        
        for i in 0 ..< list.count {
            let middleView = WeatherMiddleView()
            middleView.viewModel = WeatherMiddleView.ViewModel(
                weatherImage: list[i].weather.first!.id.weatherBackgroundImage,
                weatherTime: list[i].txt.stringDateString,
                weatherDescription: list[i].weather.first!.description,
                tempMax: list[i].main.temp_max.temperatureString,
                tempMin: list[i].main.temp_min.temperatureString
            )
            
            let containerMiddleView = UIView()
            
            ConstraintBuilder.setupConstraintFor(
                child: middleView,
                into: containerMiddleView,
                constraints: [
                    .height(constant: horizontalScrollView.frame.height),
                    .width(constant: self.view.frame.width),
                    .top(),
                    .bottom(),
                    .trailing(),
                    .leading()
                ]
            )
            
            containerView.append(containerMiddleView)
        }
        
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.contentSize = CGSize(
            width: Int(self.view.frame.width) * list.count,
            height: 1
        )
        
        let stack = UIStackView(arrangedSubviews: containerView)
        stack.axis = .horizontal
        
        ConstraintBuilder.setupAllEdgesConstrainFor(child: stack, into: horizontalScrollView)
    }
    
    //MARK: - Actions
    
    
}

//MARK: - SideMenuViewControllerDelegate

extension DashboardViewController: SideMenuViewControllerDelegate {
    func sideMenuDidPressOption(_ option: SideMenuViewController.MenuOptions) {
        guard let _ = navigationController?.navigationBar else { return }
        
        switch option {
        case .search:
            menuButton.isEnabled = false
            if retriveSearchForFirstTime() == false {
                self.viewModel.delegate?.closeSideMenu()
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        let progressPopupView = ProgressPopupView()
                        progressPopupView.delegate = self
                        progressPopupView.backgroundColor = .white
                        progressPopupView.configureWith(title: "Do you want download all cities?")
                        
                        ConstraintBuilder.setupConstraintFor(
                            child: progressPopupView,
                            into: self.view,
                            constraints: [
                                .height(constant: self.view.frame.height / 2),
                                .bottom(),
                                .leading(),
                                .trailing()
                            ]
                        )
                        
                        self.view.bringSubviewToFront(progressPopupView)
                    }
                }
            } else {
                self.viewModel.delegate?.openSearchViewController()
            }
            
        case .saved:
            viewModel.delegate?.openSavedViewController()
        }
    }
}

//MARK: - ProgressPopupViewDelegate

extension DashboardViewController: ProgressPopupViewDelegate {
    func closeProgressPopupView(_ progressPopupView: ProgressPopupView) {
        menuButton.isEnabled = true
        progressPopupView.removeFromSuperview()
    }
    
    func fetchAndSaveCitiesAreFinisched(_ progressPopupView: ProgressPopupView) {
        setSearchForFirstTime(true)
        progressPopupView.removeFromSuperview()
        self.viewModel.delegate?.openSearchViewController()
    }
}
