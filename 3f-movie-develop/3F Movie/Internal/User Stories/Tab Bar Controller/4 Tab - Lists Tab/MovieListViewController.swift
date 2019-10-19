import Foundation
import UIKit

class MovieListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    private var movies: ListModel?
    
    override func viewWillAppear(_ animated: Bool) {
        guard let movies = movies else {
            navigationController?.popViewController(animated: true)
            return
        }
        MoviesListManager.shared.getMovieList(id: movies.id, completion: { result -> () in
            guard let result = result else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            DispatchQueue.main.async() {
                self.movies = result
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let movies = movies else { return }
        if movies.listName != NSLocalizedString("MoviesListManager.SystemListID.Favorites", comment: "") && movies.listName != NSLocalizedString("MoviesListManager.SystemListID.WatchLater", comment: "") {
            let rightBarButton = UIBarButtonItem(title: NSLocalizedString("MovieListVC.NavBar.RightButton.title", comment: ""), style: .plain, target: self, action: #selector(didTapEditButton))
            navigationItem.rightBarButtonItem = rightBarButton
        }

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    func setMovies(movies: ListModel) {
        self.movies = movies
    }
    
    func raiseError() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("MovieListVC.View.Error.Alert.title", comment: ""),
                                      message: NSLocalizedString("MovieListVC.View.Error.Alert.message", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("MovieListVC.View.Error.Alert.OK", comment: ""), style: .default, handler: nil))
        return alert
    }
    
    @objc func didTapEditButton() {
        guard var movies = movies else { return }
        
        let alert = UIAlertController(title: NSLocalizedString("MovieListVC.NavBar.RightButton.Action.Alert.title", comment: ""), message: NSLocalizedString("MovieListVC.NavBar.RightButton.Action.Alert.message", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = movies.listName
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("MovieListVC.NavBar.RightButton.Action.Alert.OK", comment: ""), style: .default, handler: { [weak alert] (_) in
            let newName = alert?.textFields![0]
            
            guard let name = newName?.text else { return }
            if (movies.listName != name) {
                movies.listName = name
                MoviesListManager.shared.update(list: movies, completion: { result -> () in
                    DispatchQueue.main.async() {
                        self.navigationItem.title = movies.listName
                    }
                    MoviesListManager.shared.getMovieList(id: movies.id, completion: { result -> () in
                        guard let result = result else {
                            self.navigationController?.popViewController(animated: true)
                            return
                        }
                        DispatchQueue.main.async() {
                            self.movies = result
                            self.tableView.reloadData()
                        }
                    })
                })
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("MovieListVC.NavBar.RightButton.Action.Alert.Cancel", comment: ""), style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        

    }
    
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let movies = movies else { return 0 }
        return movies.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movies = movies else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let model = movies.movies[indexPath.row]
        cell.setupCell(movieImagePath: "https://image.tmdb.org/t/p/w500\(model.poster_path ?? "")", movieName: model.title, movieOverview: model.overview ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movies = movies else { return }
        let movieStoryboard = UIStoryboard(name: "MovieController", bundle: nil)
        let movieViewController = movieStoryboard.instantiateInitialViewController() as! MovieViewController
        movieViewController.setMovieID(movieID: movies.movies[indexPath.row].id)
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(movieViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let movies = movies else { return }
        if editingStyle == .delete {
            let alert = UIAlertController(title: NSLocalizedString("MovieListVC.Button.DeleteList.Alert.title", comment: ""),
                                          message: NSLocalizedString("MovieListVC.Button.DeleteList.Alert.message", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("MovieListVC.Button.DeleteList.Alert.Yes", comment: ""), style: .default, handler: { action in
                MoviesListManager.shared.deleteFilmFromList(listID: movies.id, id: movies.movies[indexPath.row].id, movie: movies.movies[indexPath.row], completion: { result -> () in
                    if result {
                        MoviesListManager.shared.getMovieList(id: movies.id, completion: { result -> () in
                            guard let result = result else { return }
                            DispatchQueue.main.async() {
                                self.movies = result
                                self.tableView.reloadData()
                            }
                        })
                    } else {
                        DispatchQueue.main.async() {
                            let errorAlert = self.raiseError()
                            self.present(errorAlert, animated: true)
                        }
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("MovieListVC.Button.DeleteList.Alert.No", comment: ""), style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true)
        }
    }
}
