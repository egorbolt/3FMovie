//
//  ExploreViewController.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 08/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


fileprivate enum SectionTags: Int {
    case trending = 1
    case nowPlaying = 2
    case genres = 3
    case popular = 4
    case topRated = 5
    case upcoming = 6
}


class ExploreViewController: UIViewController, API {
    
    // MARK: - UI Outlets
    // MARK: Sections
    @IBOutlet weak var trendingSection: CollectionViewWithTitle!
    @IBOutlet weak var nowPlayingSection: NowPlayingSection!
    @IBOutlet weak var genresSection: CollectionViewWithTitle!
    @IBOutlet weak var popularSection: CollectionViewWithTitle!
    @IBOutlet weak var topRatedSection: CollectionViewWithTitle!
    @IBOutlet weak var upcomingSection: CollectionViewWithTitle!
    
    // MARK: Scroll Views
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    // MARK: Public properties
    var movieData = [Int: [Movie]]()
    var genreData = [Genre]()
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        setupSections()
        setupTabBar()
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 70 * 1024 * 1024
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: trendingSection.collectionView)
            registerForPreviewing(with: self, sourceView: popularSection.collectionView)
            registerForPreviewing(with: self, sourceView: topRatedSection.collectionView)
            registerForPreviewing(with: self, sourceView: upcomingSection.collectionView)
        }
        setShowAllActions()
        setupScrollView()
        setupNavigationBar()
        reloadData()
    }
    
    // MARK: - Methods
    // MARK: Private methods
    @objc private func reloadData() {
        let donwloadDataOperation = BlockOperation {
            let downloadDataDispatchGroup = DispatchGroup()
            
            downloadDataDispatchGroup.enter()
            self.loadMovies(url: self.urlTrending()) { (trendingMovies, count) in
                self.movieData[1] = trendingMovies
                downloadDataDispatchGroup.leave()
            }
            
            downloadDataDispatchGroup.enter()
            self.loadMovies(url: self.urlNowPlaying()) { (nowPlayingMovies, count) in
                self.movieData[2] = nowPlayingMovies
                downloadDataDispatchGroup.leave()
            }
            
            downloadDataDispatchGroup.enter()
            self.loadGenres(language: MoviesListManager.shared.locale) { (genres, nil) in
                self.genreData = genres
                downloadDataDispatchGroup.leave()
            }
            
            downloadDataDispatchGroup.enter()
            self.loadMovies(url: self.urlPopular()) { (trendingMovies, count) in
                self.movieData[4] = trendingMovies
                downloadDataDispatchGroup.leave()
            }
            
            downloadDataDispatchGroup.enter()
            self.loadMovies(url: self.urlTopRated()) { (trendingMovies, count) in
                self.movieData[5] = trendingMovies
                downloadDataDispatchGroup.leave()
            }
            
            downloadDataDispatchGroup.enter()
            self.loadMovies(url: self.urlUpcoming()) { (trendingMovies, count) in
                self.movieData[6] = trendingMovies
                downloadDataDispatchGroup.leave()
            }
            
            downloadDataDispatchGroup.wait()
        }
        
        let dataUpdateOperation = BlockOperation {
            DispatchQueue.main.async {
                self.trendingSection.collectionView.reloadData()
                self.nowPlayingSection.reloadData(data: self.movieData[self.nowPlayingSection.tag]!)
                self.popularSection.collectionView.reloadData()
                self.genresSection.collectionView.reloadData()
                self.topRatedSection.collectionView.reloadData()
                self.upcomingSection.collectionView.reloadData()
                self.scrollView.refreshControl?.endRefreshing()
            }
        }
        
        dataUpdateOperation.addDependency(donwloadDataOperation)
        let reloadDataOperationQueue = OperationQueue()
        reloadDataOperationQueue.addOperation(donwloadDataOperation)
        reloadDataOperationQueue.addOperation(dataUpdateOperation)
    }
    
}


// MARK: - Setup methods
extension ExploreViewController {
    
    private func setupSections() {
        let trendingCellNib = UINib(nibName: Constants.NibNames.trendingCellNib, bundle: nil)
        let genresCellNib = UINib(nibName: Constants.NibNames.genresCellNib, bundle: nil)
        trendingSection.delegate = self
        trendingSection.dataSource = self
        trendingSection.collectionView.tag = 1
        trendingSection.collectionView.register(trendingCellNib, forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell)
        trendingSection.title = L10n.ExploreViewController.TrendingSection.title
        
        nowPlayingSection.delegate = self
        nowPlayingSection.tag = 2
        nowPlayingSection.sectionTitleLabel.text = L10n.ExploreViewController.NowPlayingSection.title
        
        genresSection.delegate = self
        genresSection.dataSource = self
        genresSection.collectionView.tag = 3
        genresSection.collectionView.register(genresCellNib, forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.genresCell)
        genresSection.collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        genresSection.title = L10n.ExploreViewController.GenresSection.title
        
        popularSection.delegate = self
        popularSection.dataSource = self
        popularSection.collectionView.tag = 4
        popularSection.collectionView.register(trendingCellNib, forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell)
        popularSection.title = L10n.ExploreViewController.PopularSection.title
        
        topRatedSection.delegate = self
        topRatedSection.dataSource = self
        topRatedSection.collectionView.tag = 5
        topRatedSection.collectionView.register(trendingCellNib, forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell)
        topRatedSection.title = L10n.ExploreViewController.TopRatedSection.title
        
        upcomingSection.delegate = self
        upcomingSection.dataSource = self
        upcomingSection.collectionView.tag = 6
        upcomingSection.collectionView.register(trendingCellNib, forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell)
        upcomingSection.title = L10n.ExploreViewController.UpcomingSection.title
    }
    
    private func setupScrollView() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    private func setupTabBar() {
        guard let tabs = tabBarController?.tabBar.items else { return }
        tabs[0].title = L10n.ExploreViewController.TabbarItem.title
        tabs[1].title = L10n.RandomMovieViewController.title
        tabs[2].title = L10n.ListsVC.View.title
    }
    
    private func setupNavigationBar() {
        navigationItem.title = L10n.ExploreViewController.NavigationItem.title
        let tv = UIStoryboard(name: Constants.StoryboardIDs.searchTableViewCeontrollerID, bundle: nil).instantiateInitialViewController() as! SearchTableView
        let searchController = UISearchController(searchResultsController: tv)
        searchController.searchResultsUpdater = tv
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    private func setShowAllActions() {
        trendingSection.setShowAll {
            let showAllStoryboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            guard let showAllController = showAllStoryboard.instantiateInitialViewController() as? ShowAllViewController else { return }
            showAllController.showMethod = .trending
            self.navigationController?.pushViewController(showAllController, animated: true)
        }
        nowPlayingSection.setShowAll {
            let showAllStoryboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            guard let showAllController = showAllStoryboard.instantiateInitialViewController() as? ShowAllViewController else { return }
            showAllController.showMethod = .nowPlaying
            self.navigationController?.pushViewController(showAllController, animated: true)
        }
        genresSection.hideShowAllButton()
        
        popularSection.setShowAll {
            let showAllStoryboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            guard let showAllController = showAllStoryboard.instantiateInitialViewController() as? ShowAllViewController else { return }
            showAllController.showMethod = .popular
            self.navigationController?.pushViewController(showAllController, animated: true)
        }
        topRatedSection.setShowAll {
            let showAllStoryboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            guard let showAllController = showAllStoryboard.instantiateInitialViewController() as? ShowAllViewController else { return }
            showAllController.showMethod = .topRated
            self.navigationController?.pushViewController(showAllController, animated: true)
        }
        upcomingSection.setShowAll {
            let showAllStoryboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            guard let showAllController = showAllStoryboard.instantiateInitialViewController() as? ShowAllViewController else { return }
            showAllController.showMethod = .upcoming
            self.navigationController?.pushViewController(showAllController, animated: true)
        }
    }
    
}


// MARK: - Collection View Delegate
extension ExploreViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionTags(rawValue: collectionView.tag) else { return }
        switch section {
        case .genres:
            let showAllStoryboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            guard let showAllController = showAllStoryboard.instantiateInitialViewController() as? ShowAllViewController else { return }
            let genre = genreData[indexPath.row]
            showAllController.showMethod = .genre(genre)
            self.navigationController?.pushViewController(showAllController, animated: true)
            
        case .trending, .nowPlaying, .popular, .topRated, .upcoming:
            let movieStoryboard = UIStoryboard(name: Constants.StoryboardIDs.movieControllerID, bundle: nil)
            guard let movieViewController = movieStoryboard.instantiateInitialViewController() as? MovieViewController else { return }
            guard let movieId = movieData.safelyGetElementFrom(key: collectionView.tag, at: indexPath) else { return }
            movieViewController.setMovieID(movieID: movieId.id)
            self.navigationController?.pushViewController(movieViewController, animated: true)
        }
    }
    
}


extension ExploreViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == genresSection.collectionView { return genreData.count }
        guard let moviesArrayForCollectionView = movieData[collectionView.tag] else { return 0 }
        return moviesArrayForCollectionView.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = SectionTags(rawValue: collectionView.tag) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .genres:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIdentifiers.genresCell, for: indexPath) as? GenresCell else {
                return UICollectionViewCell()
            }
            cell.setupCell(genreName: genreData[indexPath.row].name)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        case .trending, .popular, .topRated, .upcoming:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell, for: indexPath) as? TrendingCell else {
                return UICollectionViewCell()
            }
            guard let movieForIndexPath = movieData.safelyGetElementFrom(key: collectionView.tag, at: indexPath) else { return UICollectionViewCell() }
            cell.setupCell(moviePoster: "\(urlSingleImage(image: movieForIndexPath.poster_path ?? ""))", movieName: movieForIndexPath.title, movieScore: movieForIndexPath.vote_average)
            cell.clipsToBounds = false
            return cell
        default:
            return UICollectionViewCell()
        }
    }

}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genresSection.collectionView {
            let width = genreData[indexPath.row].name.width(withConstrainedHeight: 50, font: .systemFont(ofSize: 28, weight: .bold))
            return CGSize(width: width, height: collectionView.frame.height * 0.7)
        }
        return CGSize(width: collectionView.frame.height * 0.5, height: collectionView.frame.height * 0.9)
    }

}


extension ExploreViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let collectionViewTouched = previewingContext.sourceView as? UICollectionView,
        let indexPath = collectionViewTouched.indexPathForItem(at: location),
            let cell = collectionViewTouched.cellForItem(at: indexPath) else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        
        let movieStoryboard = UIStoryboard(name: Constants.StoryboardIDs.movieControllerID, bundle: nil)
        guard let movieViewController = movieStoryboard.instantiateInitialViewController() as? MovieViewController,
            let movieId = movieData.safelyGetElementFrom(key: collectionViewTouched.tag, at: indexPath) else { return nil }
        movieViewController.setMovieID(movieID: movieId.id)
        
        return movieViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}





