//
//  ShowAllViewController.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ShowAllViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    var showMethod: ShowMethod?
    private var data: [ShowAllData] = []
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let itemsPerRow: CGFloat = 2
    private let minimumItemSpacing: CGFloat = 8
    private let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    private var totalPages = 1
    private var currentPage = 0
    
    private var placeholder = "noMoviePoster"
    private var spinnerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        loadInformation()
        
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 70 * 1024 * 1024
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ShowAllCell.nib,
                                forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.showAllCell)
        
        setupSpiner()
    }
}

private extension ShowAllViewController {
    func setupNavbar() {        
        if let method = showMethod {
            switch method {
            case .trending:
                navigationItem.title = NSLocalizedString("ShowAllView.Title.Trending", comment: "")
            case .nowPlaying:
                navigationItem.title = NSLocalizedString("ShowAllView.Title.NowPlaying", comment: "")
            case .popular:
                navigationItem.title = NSLocalizedString("ShowAllView.Title.Popular", comment: "")
            case .topRated:
                navigationItem.title = NSLocalizedString("ShowAllView.Title.TopRated", comment: "")
            case .upcoming:
                navigationItem.title = NSLocalizedString("ShowAllView.Title.Upcoming", comment: "")
            case .genre(let genre):
                navigationItem.title = genre.name
            case .actors(_):
                navigationItem.title = NSLocalizedString("ShowAllView.Title.Actors", comment: "")
                placeholder = "personPlaceholder"
            case .crew(_):
                navigationItem.title = NSLocalizedString("ShowAllView.Title.Crew", comment: "")
                placeholder = "personPlaceholder"
            case .moviesData(_, let title):
                navigationItem.title = title
            }
        }
        navigationController?.navigationBar.prefersLargeTitles = true        
    }
    
    func setupSpiner() {
        spinnerView = UIView.init(frame: self.view.bounds)
        spinnerView?.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.25)
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = self.view.center
        spinnerView?.addSubview(ai)
    }
}

//MARK: -  Form data

private extension ShowAllViewController {
    func formData(movies: [Movie], pageCount: Int) {
        for element in movies {
            data.append(ShowAllData(element))
        }
        totalPages = pageCount
    }
    
    func formData(actors: [Actor]) {
        for element in actors {
            data.append(ShowAllData(element))
        }
        totalPages = 1
    }
    
    func formData(crew: [CrewPerson]) {
        for element in crew {
            data.append(ShowAllData(element))
        }
        totalPages = 1
    }
}

// MARK: - UICollectionViewDataSource
extension ShowAllViewController: UICollectionViewDataSource {
    func numberOfSections(in: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIdentifiers.showAllCell,
                                 for: indexPath) as? ShowAllCell else {
                                    fatalError("Wrong cell")
        }
        
        cell.update(data: data[indexPath.item], placeholder: placeholder)
        return cell
    }
}

// MARK: - Pagination

extension ShowAllViewController {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let method = showMethod else { return }
        switch method {
        case .actors(_), .crew(_), .moviesData(_, _):
            return
        default:
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height
                && currentPage < totalPages {
                loadInformation()
            }
        }
    }
}

//MARK: - Load data

extension ShowAllViewController: API {
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.collectionView.reloadData()
            if let spinner = self.spinnerView {
                spinner.removeFromSuperview()
            }
        }
    }
    
    private func loadInformation() {
        currentPage += 1
        guard let method = showMethod else { return }
        if let spinner = spinnerView {
            view.addSubview(spinner)
        }
        var url: String = ""
        
        switch method {
        case .trending:
            url = "\(urlTrending())&page=\(currentPage)&language=\(MoviesListManager.shared.locale)"
            
        case .nowPlaying:
            url = "\(urlNowPlaying())&page=\(currentPage)&language=\(MoviesListManager.shared.locale)"
            
        case .popular:
            url = "\(urlPopular())&page=\(currentPage)&language=\(MoviesListManager.shared.locale)"
            
        case .topRated:
            url = "\(urlTopRated())&page=\(currentPage)&language=\(MoviesListManager.shared.locale)"
            
        case .upcoming:
            url = "\(urlUpcoming())&page=\(currentPage)&language=\(MoviesListManager.shared.locale)"
            
        case .genre(let genre):
            url = ["\(host())/discover/movie?\(key())",
                "&include_adult=false&page=\(currentPage)",
                "&with_genres=\(genre.id)&language=\(MoviesListManager.shared.locale)"].joined()
            
        default:
            break
        }
        
        switch method {
        case .trending, .nowPlaying, .popular, .topRated, .upcoming, .genre(_):
            loadMovies(url: url) { [weak self] movies, pageCount in
                guard let self = self else { return }
                self.formData(movies: movies, pageCount: pageCount)
                self.reloadData()
            }
            
        case .actors(let idMovie):
            loadPeople(idMovie: idMovie, language: MoviesListManager.shared.locale) { [weak self] team in
                guard let self = self else { return }
                if let team = team {
                    self.formData(actors: team.cast)
                    self.reloadData()
                }
            }
            
        case .crew(let idMovie):
            loadPeople(idMovie: idMovie, language: MoviesListManager.shared.locale) { [weak self] team in
                guard let self = self else { return }
                if let team = team {
                    self.formData(crew: team.crew)
                    self.reloadData()
                }
            }
            
        case .moviesData(let movies, _):
            data = movies
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ShowAllViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace =
            sectionInsets.left + sectionInsets.right + minimumItemSpacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem * 1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let method = showMethod else { return }
        
        switch method {
        case .trending, .nowPlaying, .popular, .topRated, .upcoming, .genre(_), .moviesData(_):
            let identifier = Constants.StoryboardIDs.movieControllerID
            let storyboard = UIStoryboard(name: identifier, bundle: .none)
            let viewController =
                storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.movieControllerID)
            
            if let newMovieViewController = viewController as? MovieViewController {
                newMovieViewController.setMovieID(movieID: data[indexPath.item].id)
                navigationController?.pushViewController(newMovieViewController, animated: true)
            }
            
        case .actors(_), .crew(_):
            let storyboard = UIStoryboard(name: Constants.StoryboardIDs.actorControllerID, bundle: .none)
            let viewController =
                storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.actorControllerID)
            
            if let newMovieViewController = viewController as? PersonViewController {
                newMovieViewController.personId = data[indexPath.item].id
                navigationController?.pushViewController(newMovieViewController, animated: true)
            }
        }
        KingfisherManager.shared.cache.clearMemoryCache()
    }
}
