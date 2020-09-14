//
//  PreferredWeatherViewController.swift
//  Meteo
//
//  Created by Massimiliano Bonafede on 09/08/2020.
//  Copyright © 2020 Massimiliano Bonafede. All rights reserved.
//

import UIKit
import Lottie
import RealmSwift

protocol SetupPreferedWeatherAfterFetching: class {
    func setupUI(_ weather: [MainWeather])
}


class PreferredWeatherViewController: UIViewController, Storyboarded {
    
    //MARK: - Outlets
    
    #warning("cambiare il testo e metterlo in inglese")
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var progressSave: UIProgressView!
    
    @IBOutlet weak var lottieContainer: UIView!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    //MARK: - Properties
    var delegate: SetupPreferedWeatherAfterFetching?
    private var loadingView = AnimationView()
    var coordinator: MainCoordinator?
    var progress = Progress(totalUnitCount: 10)
    var dataSource: PreferredDataSource?

    var state: State = .loading {
        didSet {
            switch state {
            case .loading:
                navigationController?.navigationBar.isHidden = true
                tableView.isHidden = true
                progressLabel.isHidden = true
                progressSave.isHidden = true
                backgroundImage.isHidden = true
                lottieContainer.isHidden = false
                let animation = Animation.named("loading")
                setupAnimation(for: animation!)
            case .preparing:
                navigationController?.navigationBar.isHidden = false
                tableView.isHidden = false
                progressSave.isHidden = false
                progressLabel.isHidden = false
                backgroundImage.isHidden = false
                lottieContainer.isHidden = true
                loadingView.stop()
            }
        }
    }
    

    
//    var fetchManger = WeatherFetchManager()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        state = .loading
        self.delegate = self
        self.delegate?.setupUI(self.coordinator?.savedWeather?.retriveWeathers ?? [])
        //self.delegate?.setupUI((coordinator?.savedWeather)!)

        let leftButton = UIBarButtonItem(image: UIImage(named: "new_back"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        navigationItem.leftBarButtonItem = leftButton
        
        let nib = UINib(nibName: "PreferredTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PreferredTableViewCell")
        tableView.delegate = self
        let footerView = UIView()
        footerView.backgroundColor = .red
        tableView.tableFooterView = footerView
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
    
    
    
    //MARK: - Actions
    
    
    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        coordinator?.provenienceDelegate?.proveniceDidSelected(.preferedViewController)
        coordinator?.popViewController()
    }
    
    
    func setupAnimation(for animation: Animation) {
        loadingView.frame = animation.bounds
        loadingView.animation = animation
        loadingView.contentMode = .scaleAspectFill
        lottieContainer.addSubview(loadingView)
        loadingView.backgroundBehavior = .pauseAndRestore
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.topAnchor.constraint(equalTo: lottieContainer.topAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: lottieContainer.bottomAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: lottieContainer.trailingAnchor).isActive = true
        loadingView.leadingAnchor.constraint(equalTo: lottieContainer.leadingAnchor).isActive = true
        self.loadingView.play(fromProgress: 0, toProgress: 1, loopMode: .loop, completion: nil)
    }
    
    func setupNavigationBarColor(_ condition: MainWeather.WeatherCondition) {
        
        switch condition {
        case .tempesta:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .pioggia:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .pioggiaLeggera:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .neve:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .nebbia:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .sole:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .nuvole:
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    
    func setCurrentProgress(_ progressDone: Int) {
        progress.completedUnitCount = Int64(progressDone)
        let progressFloat = Float(progress.fractionCompleted)
        progressSave.setProgress(progressFloat, animated: true)
    }
    
}


//MARK: - UITableViewDelegate

extension PreferredWeatherViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
    }
    
    private func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let configuration = UISwipeActionsConfiguration(actions: [self.removePreferredWeather(forRowAt: indexPath)])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func removePreferredWeather(forRowAt indexPath: IndexPath)-> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "") { (contextualAction: UIContextualAction, view : UIView,completion: (Bool) -> Void) in
            
            self.state = .loading
            self.coordinator?.savedWeather?.realmManager?.delegate = self
            self.coordinator?.savedWeather?.realmManager?.deleteWeather(indexPath)
            self.coordinator?.savedWeather?.retriveWeathers?.remove(at: indexPath.row)
            self.coordinator?.savedWeather?.realmManager?.retriveWeatherForFetchManager()
            self.coordinator?.savedWeather?.realmManager?.checkForLimitsCitySaved()
            guard let weather = self.coordinator?.savedWeather?.retriveWeathers else { return }
            
            if weather.count == 0 {
                self.coordinator?.provenienceDelegate?.proveniceDidSelected(.mainViewController)
                self.coordinator?.popViewController()
            } else {
                self.delegate?.setupUI(weather)
            }
            
        }
        
        action.image = UIImage(named: "i_Elimina")
        action.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        return action
    }
    
}



extension PreferredWeatherViewController: SetupPreferedWeatherAfterFetching {
    func setupUI(_ weather: [MainWeather]) {
        self.dataSource = PreferredDataSource(weatherManager: weather)
        self.tableView.dataSource = self.dataSource
        self.backgroundImage.image = dataSource?.imageNavigationBar()
        self.setupNavigationBarColor((dataSource?.conditionForNavigationBar())!)
        self.tableView.reloadData()
        self.setCurrentProgress(weather.count)
        self.state = .preparing
        
    }
}

extension PreferredWeatherViewController: RealmManagerDelegate {
    func retriveIsEmpty(_ isEmpty: Bool?) {
        if isEmpty == true {
            coordinator?.savedWeather?.isDatabaseEmpty = isEmpty
            coordinator?.provenienceDelegate?.proveniceDidSelected(.mainViewController)
            self.coordinator?.popViewController()
        }
    }
    
    func isLimitDidOver(_ isLimitOver: Bool) {
        /// Non viene effettuato nessun check in questo ViewController
    }

    func locationDidSaved(_ isPresent: Bool) {
        /// Non viene effettuato nessun check in questo ViewController
    }

    func retriveWeatherDidFinisched(_ weather: Results<RealmWeatherManager>) {
        self.coordinator?.savedWeather?.weatherResults = weather
    }

}

extension PreferredWeatherViewController {
    enum State {
        case loading
        case preparing
    }
}
