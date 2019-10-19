//
//  RandomMovieViewController.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 08/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit
import FaveButton
import Kingfisher

class RandomMovieViewController: UIViewController {
    private var genres: [Genre] = []
    private var pageCount: [Int] = [] // for each genre
    private var movieId: Int?
    private var spinnerView: UIView?
    private var movieInfo: MovieInfo?
    
    @IBOutlet private weak var ratingView: UIView!
    @IBOutlet private weak var rating: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var overview: UILabel!
    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var listButton: UIButton!
    @IBOutlet private weak var watchLaterButton: FaveButton!
    @IBOutlet private weak var favoriteButton: FaveButton!
    @IBOutlet private weak var nextMovieButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("RandomMovieViewController.Title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        setupSpiner()
        loadGenresTypes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let movieInfo = movieInfo else { return }
        
        if MoviesListManager.shared.findInFavoriteList(movie: movieInfo) {
            self.favoriteButton.setSelected(selected: true, animated: true)
        } else {
            self.favoriteButton.setSelected(selected: false, animated: true)
        }
        
        if MoviesListManager.shared.findInWatchLaterList(movie: movieInfo) {
            self.watchLaterButton.setSelected(selected: true, animated: true)
        } else {
            self.watchLaterButton.setSelected(selected: false, animated: true)
        }
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        loadMovie()
    }
    
    @IBAction func didTapFavoriteButton(_ sender: Any) {
        guard let movieId = movieId else { return }
        loadMovieInfo(movieID: movieId, language: MoviesListManager.shared.locale) { movieInfo in
            guard let movieInfo = movieInfo else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.favoriteButton.isSelected {
                    self.favoriteButton.setSelected(selected: true, animated: false)
                    MoviesListManager.shared.putFilmIntoSystemList(list: .favorites,
                                                                   movie: movieInfo)
                } else {
                    self.favoriteButton.setSelected(selected: false, animated: false)
                    MoviesListManager.shared.deleteFilmFromSystemList(list: .favorites,
                                                                      movie: movieInfo)
                }
            }
        }
    }
    
    @IBAction func didTapWatchLaterButton(_ sender: Any) {
        guard let movieId = movieId else { return }
        loadMovieInfo(movieID: movieId, language: MoviesListManager.shared.locale) { movieInfo in
            guard let movieInfo = movieInfo else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.watchLaterButton.isSelected {
                    self.watchLaterButton.setSelected(selected: true, animated: false)
                    MoviesListManager.shared.putFilmIntoSystemList(list: .watchLater,
                                                                   movie: movieInfo)
                } else {
                    self.watchLaterButton.setSelected(selected: false, animated: false)
                    MoviesListManager.shared.deleteFilmFromSystemList(list: .watchLater,
                                                                      movie: movieInfo)
                }
            }
        }
    }
    
    @IBAction func didTapListButton(_ sender: Any) {
        guard let movieId = movieId else { return }
        loadMovieInfo(movieID: movieId, language: MoviesListManager.shared.locale) { [weak self] movieInfo in
            guard let movieInfo = movieInfo else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.listButton.isSelected {
                    let storyboard = UIStoryboard(name: "ListsTab", bundle: nil)
                    let listsVC = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as! ListsViewController
                    listsVC.setIsShownLikeTabFalse()
                    listsVC.passMovie(movie: movieInfo)
                    
                    let navigationController = UINavigationController(rootViewController: listsVC)
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setButtonFavoritesSelected(state: Bool) {
        favoriteButton.setSelected(selected: state, animated: true)
    }
    
    private func setButtonWatchLaterSelected(state: Bool) {
        watchLaterButton.setSelected(selected: state, animated: true)
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            loadMovie()
        }
    }
}

//MARK: - Load data

extension RandomMovieViewController: API {
    
    // Generate random genre -> random page -> random movie
    private func loadMovie() {
        KingfisherManager.shared.cache.clearMemoryCache()
        if genres.count != 0 {
            let genreIndex = Int.random(in: 0 ... genres.count - 1)
            let genre = genres[genreIndex]
            var page = Int.random(in: 0...pageCount.count)
            if page == 0 { page += 1 }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let spinner = self.spinnerView {
                    self.view.addSubview(spinner)
                }
            }
            
            loadMovies(url: ["\(host())/discover/movie?\(key())",
                "&include_adult=false&page=\(page)",
                "&with_genres=\(genre.id)",
                "&language=\(MoviesListManager.shared.locale)"].joined()) { [weak self] movies, pageCount in
                    guard let self = self else { return }
                    
                    self.pageCount[genreIndex] = pageCount
                    if !movies.isEmpty {
                        let movie = movies[Int.random(in: 0 ... movies.count - 1)]
                        DispatchQueue.main.sync { [weak self] in
                            guard let self = self else { return }
                            self.setupComponents(movie: movie)
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.overview?.text = "Failed to load movie..."
                        }
                    }
                    
                    guard let movieId = self.movieId else {
                        if let spinner = self.spinnerView {
                            spinner.removeFromSuperview()
                        }
                        return
                    }
                    
                    self.loadMovieInfo(movieID: movieId, language: MoviesListManager.shared.locale) { movieInfo in
                        guard let movieInfo = movieInfo else { return }
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.movieInfo = movieInfo
                            
                            if MoviesListManager.shared.findInFavoriteList(movie: movieInfo) {
                                self.favoriteButton.setSelected(selected: true, animated: true)
                            } else {
                                self.favoriteButton.setSelected(selected: false, animated: true)
                            }
                            
                            if MoviesListManager.shared.findInWatchLaterList(movie: movieInfo) {
                                self.watchLaterButton.setSelected(selected: true, animated: true)
                            } else {
                                self.watchLaterButton.setSelected(selected: false, animated: true)
                            }
                            
                            if let spinner = self.spinnerView {
                                spinner.removeFromSuperview()
                            }
                        }
                    }
            }
        }
    }
    
    private func loadGenresTypes() {
        loadGenres(language: MoviesListManager.shared.locale) { [weak self] genres, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.overview?.text = error
                }
                return
            }
            self.genres = genres
            self.loadMovie()
            for _ in genres {
                self.pageCount.append(1)
            }
        }
    }
    
    private func setupComponents(movie: Movie) {
        rating?.text = String(movie.vote_average)
        
        rating.textColor = .white
        overview?.text = movie.overview

        ratingView.layer.cornerRadius = ratingView.frame.height / 2
        ratingView.layer.shadowColor = UIColor.black.cgColor
        ratingView.layer.shadowOffset = CGSize(width: 3, height: 3)
        ratingView.layer.shadowOpacity = 0.3
        ratingView.layer.shadowRadius = 4.0
        
        if movie.vote_average > 8 {
            ratingView.backgroundColor = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1)
            
        } else if movie.vote_average > 6 {
            ratingView.backgroundColor = UIColor(red: 74.0/255.0, green: 105.0/255.0, blue: 189.0/255.0, alpha: 1)
            
        } else {
            ratingView.backgroundColor = UIColor(red: 229.0/255.0, green: 80.0/255.0, blue: 57.0/255.0, alpha: 1)
        }
        
        movieId = movie.id
        name.text = movie.title
        
        guard let poster = movie.poster_path else {
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "noMovieImage")
            return
        }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(poster)"),
                                   options: [])
    }
}

private extension RandomMovieViewController {
   
    // image tap
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let id = movieId else { return}
        
        let identifier = Constants.StoryboardIDs.movieControllerID
        let storyboard = UIStoryboard(name: identifier, bundle: .none)
        let viewController =
            storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.movieControllerID)
        
        if let newMovieViewController = viewController as? MovieViewController {
            newMovieViewController.setMovieID(movieID: id)
            navigationController?.pushViewController(newMovieViewController, animated: true)
        }
        
        KingfisherManager.shared.cache.clearMemoryCache()
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
