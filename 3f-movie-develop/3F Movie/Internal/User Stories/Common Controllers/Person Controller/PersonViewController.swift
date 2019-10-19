//
//  AuthorViewController.swift
//  3F Movie
//
//  Created by stud on 14/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit
import Kingfisher
import SKPhotoBrowser

class PersonViewController: UIViewController {
    var personId: Int?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var born: UILabel!
    @IBOutlet private weak var from: UILabel!
    @IBOutlet private weak var Description: UILabel!
    @IBOutlet private weak var imagesCollectionView: CollectionViewWithTitle!
    @IBOutlet private weak var moviesCollectionView: CollectionViewWithTitle!
    @IBOutlet private weak var biography: UILabel!
    @IBOutlet private weak var info: UILabel!    
    @IBOutlet private weak var fromInfo: UILabel!
    @IBOutlet private weak var bornInfo: UILabel!
    private var spinnerView: UIView?
    private var images: [String] = []
    private var movies: [ShowAllData] = []
    
    private var skPhotos = [SKPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        self.moviesCollectionView.delegate = self
        self.moviesCollectionView.dataSource = self
        
        imagesCollectionView.collectionView.register(ImageCell.nib,
                                                     forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.imageCell)
        imagesCollectionView.hideShowAllButton()
        imagesCollectionView.title = NSLocalizedString("PersonViewController.Images", comment: "")
        
        moviesCollectionView.collectionView.register(UINib(nibName: Constants.CellReuseIdentifiers.trendingCell,
                                                           bundle: .main),
                                                     forCellWithReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell)
        moviesCollectionView.title = NSLocalizedString("PersonViewController.Movies", comment: "")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        biography.text = NSLocalizedString("PersonViewController.Biography", comment: "")
        info.text = NSLocalizedString("PersonViewController.Info", comment: "")
        
        setupSpiner()
        loadPersonDetailedInfo()
        loadImages()
        loadMovies()
        
        self.moviesCollectionView.setShowAll(action: { [ weak self ] in
            guard let self = self else { return }
            let storyboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
            let showAllVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.showAllControllerID) as! ShowAllViewController
            showAllVC.showMethod = .moviesData(self.movies, self.name.text ?? "")
            self.navigationController?.pushViewController(showAllVC, animated: true)
        })
    }
}

private extension PersonViewController {
    func setupSpiner() {
        spinnerView = UIView.init(frame: self.view.bounds)
        spinnerView?.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.25)
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = self.view.center
        spinnerView?.addSubview(ai)
    }
    
    func setupDetailedInfo(personInfo: Person) {
        navigationItem.title = personInfo.name
        name.text = personInfo.name
        
        if let birthday = personInfo.birthday {
            born.text = NSLocalizedString("PersonViewController.BornOn", comment: "")
            bornInfo.text = birthday
        } else {
            born.text = NSLocalizedString("PersonViewController.BornOnNOImformation", comment: "")
            bornInfo.text = ""
        }
        if let place = personInfo.place_of_birth {
            from.text = NSLocalizedString("PersonViewController.From", comment: "")
            fromInfo.text = place
        } else {
            from.text = NSLocalizedString("PersonViewController.FromNoInformation", comment: "")
            fromInfo.text = ""
        }
        
        Description.text = personInfo.biography
        
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        guard let poster = personInfo.profile_path else {
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "personPlaceholder")
            return
        }
        imageView.clipsToBounds = true
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(poster)"),
                                   options: [])
    }
}

extension PersonViewController: API {
    private func loadPersonDetailedInfo() {
        if let personId = personId {
            if let spinner = self.spinnerView {
                self.view.addSubview(spinner)
            }
            loadPersonDetailedInfo(personId: personId, language: MoviesListManager.shared.locale) { person in
                guard let person = person else { return }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.setupDetailedInfo(personInfo: person)
                    
                    if let spinner = self.spinnerView {
                        spinner.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func loadImages() {
        if let personId = personId {
            loadPersonImages(personId: personId, language: MoviesListManager.shared.locale) { [weak self] paths in
                guard let self = self else { return }
                self.images = paths
                
                for image in self.images {
                    let photo = SKPhoto.photoWithImageURL(self.urlSingleImage(image: image))
                    photo.shouldCachePhotoURLImage = true
                    self.skPhotos.append(photo)
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.imagesCollectionView.collectionView.reloadData()
                    if self.images.isEmpty {
                        self.imagesCollectionView.hideShowAllButton()
                        self.imagesCollectionView.showNoContentMessage(message: "No images")
                    }
                }
            }
        }
    }
    
    private func loadMovies() {
        guard let personId = personId else { return }
        loadPersonMovies(personId: personId, language: MoviesListManager.shared.locale) { [weak self] personMovies in
            guard let self = self, let personMovies = personMovies else { return }
            
            for element in personMovies.cast {
                self.movies.append(ShowAllData(element))
            }
            for element in personMovies.crew {
                self.movies.append(ShowAllData(element))
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.moviesCollectionView.collectionView.reloadData()
                if self.movies.isEmpty {
                    self.moviesCollectionView.hideShowAllButton()
                    self.moviesCollectionView.showNoContentMessage(message: "No movies")
                }
            }
        }
    }    
}

extension PersonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imagesCollectionView.collectionView {
            return images.count
        }
        if movies.count > 15 {
            return 15
        }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == imagesCollectionView.collectionView {
            guard let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIdentifiers.imageCell,
                                                   for: indexPath) as? ImageCell else {
                                                    fatalError("Wrong cell")
            }
            cell.setupImage(path: images[indexPath.item])
            return cell
        }
        
        guard let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIdentifiers.trendingCell,
                                               for: indexPath) as? TrendingCell else {
                                                fatalError("Wrong cell")
        }
        guard let scope = movies[indexPath.item].vote_average else { fatalError("Wrong scope") }
        
        cell.setupCell(moviePoster: "https://image.tmdb.org/t/p/w500/\(movies[indexPath.item].imageUrl ?? "")",
            movieName: movies[indexPath.item].name,
            movieScore: scope)
        cell.clipsToBounds = false
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == imagesCollectionView.collectionView {
            guard !skPhotos.isEmpty else { return }
            let browser = SKPhotoBrowser(photos: skPhotos, initialPageIndex: indexPath.item)
            present(browser, animated: true, completion: {})
            return
        }
        
        let identifier = Constants.StoryboardIDs.movieControllerID
        let storyboard = UIStoryboard(name: identifier, bundle: .none)
        let viewController =
            storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.movieControllerID)
        
        if let newMovieViewController = viewController as? MovieViewController {
            newMovieViewController.setMovieID(movieID: movies[indexPath.item].id)
            navigationController?.pushViewController(newMovieViewController, animated: true)
        }
    }
}

extension PersonViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * 0.5, height: collectionView.frame.height * 0.9)
    }
}
