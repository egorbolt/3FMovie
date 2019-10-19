import Kingfisher
import SKPhotoBrowser
import YoutubePlayer_in_WKWebView
import Foundation
import FaveButton

protocol MovieViewControllerDelegate: AnyObject {
    func updateTableView(sender: MovieViewController)
}

enum MovieViewControllerPublicConsts {
    /// Actors don't have a department
    static let noPositionProvided = ""
}

enum MovieViewControllerPrivateConsts {
    /// How many cells we want our custom collection view to show
    fileprivate static let collectionViewCellAmount = 10
    /// ID for PersonCell XIB
    fileprivate static let personCellIdentifier = "PersonCell"
    /// ID for TrailerCell XIB
    fileprivate static let trailerCellIdentifier = "TrailerCell"
    /// ID for person's placeholder picture (check it in assets)
    fileprivate static let personPlaceholder = "personPlaceholder"
    /// ID for backdrop's placeholder picture (check it in assets)
    fileprivate static let backdropPlaceholder = "backdropPlaceholder"
    /// ID for webplayer VC
    fileprivate static let webPlayerVCID = "WebPlayerViewController"
    /// Name of this very VC
    fileprivate static let vcName = NSLocalizedString("MovieVC.View.title", comment: "")
}

final class MovieViewController: UIViewController, API {
    /// Outlet for movie's main image (+tapping on it shows image gallery)
    @IBOutlet private weak var imageView: UIImageView!
    /// Outlet for movie's release date
    @IBOutlet private weak var labelYear: UILabel!
    /// Outlet for movie's time duration
    @IBOutlet private weak var labelTimeDuration: UILabel!
    /// Outlet for movie's name
    @IBOutlet private weak var labelMovieName: UILabel!
    /// Outlet for movie's genres
    @IBOutlet private weak var labelGenres: UILabel!
    /// Outlet for movie's short description
    @IBOutlet private weak var labelDescription: UILabel!
    /// Outlet for movie actors custom collection view
    @IBOutlet private weak var collectionViewActors: CollectionViewWithTitle!
    /// Outlet for movie crew's custom collection view
    @IBOutlet private weak var collectionViewCrew: CollectionViewWithTitle!
    /// Outlet for movie trailers custom collection view
    @IBOutlet private weak var collectionViewTrailers: CollectionViewWithTitle!
    @IBOutlet private weak var buttonFavorites: FaveButton!
    @IBOutlet private weak var buttonWatchLater: FaveButton!
    @IBOutlet private weak var buttonAddToList: UIButton!
    
    /// Variable for storing information about movie's team (actors and crew)
    private var team: Team?
    /// Variable for storing information about movie's trailers
    private var trailerInfo: [TrailerInfo] = []
    /// Variable for storing information about movie's related images
    private var skPhotos = [SKPhoto]()
    /// Variable for storing random movie ID (for debug purposes)
    private var movieID = 517148
    // 299534 - avengers
    // 517148 - error film
    private var movieInfo: MovieInfo?
    
    /**
     Sets which movie VC must show
     
     - Parameters:
     - movieID: movie's ID
     */
    func setMovieID(movieID: Int) {
        self.movieID = movieID
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let movieInfo = movieInfo else { return }
        if MoviesListManager.shared.findInFavoriteList(movie: movieInfo) {
            buttonFavorites.setSelected(selected: true, animated: true)
        } else {
            buttonFavorites.setSelected(selected: false, animated: true)
        }
        
        if MoviesListManager.shared.findInWatchLaterList(movie: movieInfo) {
            buttonWatchLater.setSelected(selected: true, animated: true)
        } else {
            buttonWatchLater.setSelected(selected: false, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupCollectionViews()
        setupImageGestureRecognizer()
        
        collectionViewCrew.title = NSLocalizedString("ShowAllView.Title.Crew", comment: "")
        collectionViewActors.title = NSLocalizedString("ShowAllView.Title.Actors", comment: "")
        collectionViewTrailers.title = NSLocalizedString("ShowAllView.Title.Trailers", comment: "")

        buttonFavorites.delegate = self
        buttonWatchLater.delegate = self

        loadTrailers(movieID: self.movieID, language: MoviesListManager.shared.locale, completion: { [weak self] trailers -> () in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionViewTrailers.delegate = self
                self.collectionViewTrailers.dataSource = self
                /// We don't want to show "Show all" button for trailer section
                self.collectionViewTrailers.hideShowAllButton()
                self.trailerInfo = trailers
                
                if self.trailerInfo.isEmpty {
                    self.collectionViewTrailers.hideShowAllButton()
                    self.collectionViewTrailers.showNoContentMessage(message: NSLocalizedString("MovieVC.CollectionView.Trailers.warning", comment: ""))
                }
            }
        })
        
        loadMovieImages(movieID: self.movieID, language: MoviesListManager.shared.locale, completion: { [weak self] loadedImages -> () in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                /// Converting all downloaded image URLs for SKPhoto's image browser (see SKPhoto's reference)
                loadedImages.forEach { [weak self] image in
                    guard let self = self else { return }
                    let photo = SKPhoto.photoWithImageURL(self.urlSingleImage(image: image))
                    photo.shouldCachePhotoURLImage = true
                    self.skPhotos.append(photo)
                }
            }
        })
        
        loadMovieInfo(movieID: self.movieID, language: MoviesListManager.shared.locale, completion: { [weak self] result -> () in
            guard let self = self, let movieInfo = result else { return }
            self.movieInfo = movieInfo
            
            if MoviesListManager.shared.findInLists(id: .favorites, listToSearch: nil, movie: movieInfo) {
                DispatchQueue.main.async {
                    self.buttonFavorites.setSelected(selected: true, animated: true)
                }
            }
            
            if MoviesListManager.shared.findInLists(id: .watchLater, listToSearch: nil, movie: movieInfo) {
                DispatchQueue.main.async {
                    self.buttonWatchLater.setSelected(selected: true, animated: true)
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.loadPeople(idMovie: self.movieID, language: MoviesListManager.shared.locale, completion: { [weak self] team -> () in
                    guard let self = self else { return }
                    self.collectionViewActors.delegate = self
                    self.collectionViewActors.dataSource = self
                    self.collectionViewCrew.delegate = self
                    self.collectionViewCrew.dataSource = self
                    
                    self.team = team
                    guard let team = team else {
                        self.collectionViewActors.hideShowAllButton()
                        self.collectionViewActors.showNoContentMessage(message: NSLocalizedString("MovieVC.CollectionView.Actors.warning", comment: ""))
                        self.collectionViewCrew.hideShowAllButton()
                        self.collectionViewCrew.showNoContentMessage(message: NSLocalizedString("MovieVC.CollectionView.Crew.warning", comment: ""))
                        return
                    }
                    if team.cast.isEmpty {
                        self.collectionViewActors.hideShowAllButton()
                        self.collectionViewActors.showNoContentMessage(message: NSLocalizedString("MovieVC.CollectionView.Actors.warning", comment: ""))
                    }
                    if team.crew.isEmpty {
                        self.collectionViewCrew.hideShowAllButton()
                        self.collectionViewCrew.showNoContentMessage(message: NSLocalizedString("MovieVC.CollectionView.Crew.warning", comment: ""))
                    }
                })
                
                self.imageView.kf.indicatorType = .activity
                if let backdrop = movieInfo.backdrop_path {
                    self.imageView.kf.setImage(with: URL(string: self.urlSingleImage(image: backdrop)))
                } else {
                    self.imageView.image = UIImage(named: MovieViewControllerPrivateConsts.backdropPlaceholder)
                }

                /// Localizing date for device's current locale
                self.labelYear.text = DateFormatter.getLocalizedDate(oldDate: movieInfo.release_date)
                
                if let runtime = movieInfo.runtime {
                    self.labelTimeDuration.text = "\(runtime)" + NSLocalizedString("MovieVC.Time.minutes", comment: "")
                } else {
                    self.labelTimeDuration.isHidden = true
                }
                
                self.labelMovieName.text = movieInfo.title
                self.labelGenres.text = MovieViewController.getGenres(genres: movieInfo.genres)
                self.labelDescription.text = movieInfo.overview
                
                self.collectionViewActors.setShowAll(action: { [ weak self ] in
                    guard let self = self else { return }
                    let storyboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
                    let showAllVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.showAllControllerID) as! ShowAllViewController
                    showAllVC.showMethod = .actors(self.movieID)
                    self.navigationController?.pushViewController(showAllVC, animated: true)
                })
                self.collectionViewCrew.setShowAll(action: { [ weak self ] in
                    guard let self = self else { return }
                    let storyboard = UIStoryboard(name: Constants.StoryboardIDs.showAllControllerID, bundle: nil)
                    let showAllVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.showAllControllerID) as! ShowAllViewController
                   showAllVC.showMethod = .crew(self.movieID)
                    self.navigationController?.pushViewController(showAllVC, animated: true)
                })
            }
        })
        

    }
    @IBAction func didPressedAddToFavorites(_ sender: Any) {
        guard let movieInfo = movieInfo else { return }
        if buttonFavorites.isSelected {
            buttonFavorites.setSelected(selected: true, animated: false)
            MoviesListManager.shared.putFilmIntoSystemList(list: .favorites, movie: movieInfo)
        } else {
            buttonFavorites.setSelected(selected: false, animated: false)
            MoviesListManager.shared.deleteFilmFromSystemList(list: .favorites, movie: movieInfo)
        }
    }
    
    @IBAction func didPressedAddToWatchLater(_ sender: Any) {
        guard let movieInfo = movieInfo else { return }
        if buttonWatchLater.isSelected {
            buttonWatchLater.setSelected(selected: true, animated: false)
            MoviesListManager.shared.putFilmIntoSystemList(list: .watchLater, movie: movieInfo)
        } else {
            buttonWatchLater.setSelected(selected: false, animated: false)
            MoviesListManager.shared.deleteFilmFromSystemList(list: .watchLater, movie: movieInfo)
        }
    }
    
    @IBAction func didPressedAddToList(_ sender: Any) {
        guard let movieInfo = movieInfo else { return }
        if !buttonAddToList.isSelected {
            let storyboard = UIStoryboard(name: "ListsTab", bundle: nil)
            let listsVC = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as! ListsViewController
            listsVC.setIsShownLikeTabFalse()
            listsVC.passMovie(movie: movieInfo)
            
            let navigationController = UINavigationController(rootViewController: listsVC)
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    func setButtonFavoritesSelected(state: Bool) {
        buttonFavorites.setSelected(selected: state, animated: true)
    }
    
    func setButtonWatchLaterSelected(state: Bool) {
        buttonWatchLater.setSelected(selected: state, animated: true)
    }
}

private extension MovieViewController {
    /**
     Gets all movie's genres
     
     - Parameters:
     - genres: received genres from server
     
     - Returns: prepared string with all movie's genres
     */
    static func getGenres(genres: [Genre]) -> String {
        var result = ""
        if genres.isEmpty {
            result = NSLocalizedString("MovieVC.View.Genres.warning", comment: "")
            return result
        }
        genres.forEach { genre in
            result.append("\(genre.name), ")
        }
        result.removeLast(2)
        return result
    }
    /**
     Shows image browser if user taps on movie's backdrop
     
     - Parameters:
     - tapGestureRecognizer: registed gesture recognizer
     */
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        guard !skPhotos.isEmpty else { return }
        let browser = SKPhotoBrowser(photos: skPhotos)
        browser.initializePageIndex(0)
        present(browser, animated: true, completion: {})
    }
}

private extension MovieViewController {
    /**
     Registers all custom cells for corresponding custom collection view
     */
    func setupCollectionViews() {
        collectionViewActors.collectionView.register(UINib(nibName: MovieViewControllerPrivateConsts.personCellIdentifier,
                                                           bundle: nil),
                                                     forCellWithReuseIdentifier: MovieViewControllerPrivateConsts.personCellIdentifier)
        collectionViewCrew.collectionView.register(UINib(nibName: MovieViewControllerPrivateConsts.personCellIdentifier,
                                                         bundle: nil),
                                                   forCellWithReuseIdentifier: MovieViewControllerPrivateConsts.personCellIdentifier)
        collectionViewTrailers.collectionView.register(UINib(nibName: MovieViewControllerPrivateConsts.trailerCellIdentifier,
                                                             bundle: nil),
                                                       forCellWithReuseIdentifier: MovieViewControllerPrivateConsts.trailerCellIdentifier)
    }
    
    /**
     Registers a tap recognizer
     */
    func setupImageGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /**
     Sets up this very VC's navigation bar
     */
    func setupNavbar() {
        navigationItem.title = MovieViewControllerPrivateConsts.vcName
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension MovieViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewActors.collectionView {
            guard let team = team else { return 0 }
            if team.cast.count <= MovieViewControllerPrivateConsts.collectionViewCellAmount {
                return team.cast.count
            }
        } else if collectionView == collectionViewCrew.collectionView {
            guard let team = team else { return 0 }
            if team.crew.count <= MovieViewControllerPrivateConsts.collectionViewCellAmount {
                return team.crew.count
            }
        } else if collectionView == collectionViewTrailers.collectionView {
            return trailerInfo.count
        }
        
        return MovieViewControllerPrivateConsts.collectionViewCellAmount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = UICollectionViewCell()
        
        if collectionView == collectionViewActors.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieViewControllerPrivateConsts.personCellIdentifier, for: indexPath) as? PersonCell else {
                return UICollectionViewCell()
            }
            
            guard let team = team else { return UICollectionViewCell() }
            
            /// If an actor doensn't have a picture, show a placeholder
            guard let actorProfile = team.cast[indexPath.row].profile_path else {
                cell.setupCell(personImage: nil,
                               personName: team.cast[indexPath.row].name,
                               personPosition: MovieViewControllerPublicConsts.noPositionProvided,
                               imagePlaceholder: MovieViewControllerPrivateConsts.personPlaceholder)
                return cell
            }
            
            cell.setupCell(personImage: urlSingleImage(image: actorProfile),
                           personName: team.cast[indexPath.row].name,
                           personPosition: MovieViewControllerPublicConsts.noPositionProvided,
                           imagePlaceholder: MovieViewControllerPrivateConsts.personPlaceholder)
            return cell
            
        } else if collectionView == collectionViewCrew.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieViewControllerPrivateConsts.personCellIdentifier, for: indexPath) as? PersonCell else {
                return UICollectionViewCell()
            }
            
            /// If a crew person doensn't have a picture, show a placeholder
            guard let crewProfile = team?.crew[indexPath.row].profile_path else {
                cell.setupCell(personImage: nil,
                               personName: team?.crew[indexPath.row].name ?? "",
                               personPosition: team?.crew[indexPath.row].department ?? "",
                               imagePlaceholder: MovieViewControllerPrivateConsts.personPlaceholder)
                return cell
            }
            
            cell.setupCell(personImage: urlSingleImage(image: crewProfile),
                           personName: team?.crew[indexPath.row].name ?? "",
                           personPosition: team?.crew[indexPath.row].department ?? "",
                           imagePlaceholder: MovieViewControllerPrivateConsts.personPlaceholder)
            return cell
        } else if collectionView == collectionViewTrailers.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieViewControllerPrivateConsts.trailerCellIdentifier, for: indexPath) as? TrailerCell else {
                return UICollectionViewCell()
            }
            
            cell.setupCell(trailerImage: urlSingleImageFromYoutube(image: trailerInfo[indexPath.row].key),
                           trailerName: trailerInfo[indexPath.row].name)
            return cell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// If collectionView is not related to trailers, we should do nothing
        if collectionView == collectionViewTrailers.collectionView {
            let storyboard = UIStoryboard(name: MovieViewControllerPrivateConsts.webPlayerVCID, bundle: nil)
            let webPlayerVC = storyboard.instantiateViewController(withIdentifier: MovieViewControllerPrivateConsts.webPlayerVCID) as! WebPlayerViewController
            webPlayerVC.setupWebView(url: trailerInfo[indexPath.row].key)
            
            let navigationController = UINavigationController(rootViewController: webPlayerVC)
            present(navigationController, animated: true, completion: nil)
        } else if collectionView == collectionViewActors.collectionView {
            let storyboard = UIStoryboard(name: Constants.StoryboardIDs.actorControllerID, bundle: .none)
            let personVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.actorControllerID) as! PersonViewController
            personVC.personId = team?.cast[indexPath.row].id
            
            navigationController?.pushViewController(personVC, animated: true)
        } else if collectionView == collectionViewCrew.collectionView {
            let storyboard = UIStoryboard(name: Constants.StoryboardIDs.actorControllerID, bundle: .none)
            let personVC = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardIDs.actorControllerID) as! PersonViewController
            personVC.personId = team?.crew[indexPath.row].id
            
            navigationController?.pushViewController(personVC, animated: true)
        }
    }
}


extension MovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * 0.6, height: collectionView.frame.height * 0.9)
    }
}
