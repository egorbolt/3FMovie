import Foundation
import UIKit

enum ListsViewControllerPrivateConsts {
    fileprivate static let listCellIdentifier = "ListCell"
}

class ListsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet var buttonAddList: UIButton!
    
    private var moviesLists: [ListModel] = []
    private var isShownLikeTab = true
    var passedMovie: MovieInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        MoviesListManager.shared.getMovieLists(completion: { result -> () in
            DispatchQueue.main.async() {
                self.moviesLists = result!
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonAddList.setTitle(NSLocalizedString("ListsVC.View.Button.AddList", comment: ""), for: .normal)
        navigationItem.title = NSLocalizedString("ListsVC.View.title", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if !isShownLikeTab {
            let leftBarButton = UIBarButtonItem(title: NSLocalizedString("ListsVC.Button.Back", comment: ""), style: .plain, target: self, action: #selector(didTapBackButton))
            navigationItem.leftBarButtonItem = leftBarButton
        }
        
        MoviesListManager.shared.getMovieLists(completion: { result -> () in
            DispatchQueue.main.async() {
                self.moviesLists = result!
                self.tableView.reloadData()
            }
        })
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        let nib = UINib(nibName: ListsViewControllerPrivateConsts.listCellIdentifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: ListsViewControllerPrivateConsts.listCellIdentifier)
    }
    
    @IBAction func didTouchAddListButton(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("ListsVC.Button.AddList.Alert.title", comment: ""), message: NSLocalizedString("ListsVC.Button.AddList.Alert.message", comment: ""), preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.Button.AddList.Alert.OK", comment: ""), style: .default, handler: { [weak alert, weak self] (_) in
            guard let self = self else { return }
            let newName = alert?.textFields![0] 
            
            MoviesListManager.shared.register(list: ListModel(listName: newName!.text!, movies: []), completion: { _ in
                MoviesListManager.shared.getMovieLists(completion: { result -> () in
                    DispatchQueue.main.async {
                        self.moviesLists = result!
                        self.tableView.reloadData()
                    }
                })
                
            })
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.Button.AddList.Alert.Cancel", comment: ""), style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setIsShownLikeTabFalse() {
        self.isShownLikeTab = false
    }
    
    func passMovie(movie: MovieInfo) {
        passedMovie = movie
    }
}

extension ListsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoviesListManager.shared.moviesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListsViewControllerPrivateConsts.listCellIdentifier, for: indexPath) as! ListCell
        let model = MoviesListManager.shared.moviesList[indexPath.row]
        cell.configureCell(listName: model.listName, listMoviesAmount: String(model.listMoviesAmount))
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: NSLocalizedString("ListsVC.Button.DeleteList.Alert.title", comment: ""),
                                          message: NSLocalizedString("ListsVC.Button.DeleteList.Alert.message", comment: ""),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.Button.DeleteList.Alert.Yes", comment: ""), style: .default, handler: { action in
                if !MoviesListManager.shared.moviesList[indexPath.row].movies.isEmpty {
                    let al = UIAlertController(title: NSLocalizedString("ListsVC.Button.DeleteList.ApprovingAlert.title", comment: ""),
                                                  message: NSLocalizedString("ListsVC.Button.DeleteList.ApprovingAlert.message", comment: ""),
                                                  preferredStyle: .alert)
                    
                    al.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.Button.DeleteList.Alert.Yes", comment: ""), style: .default, handler: { _ in
                        MoviesListManager.shared.unregister(list: self.moviesLists[indexPath.row], completion: { result in
                            if result {
                                MoviesListManager.shared.getMovieLists(completion: { ml -> () in
                                    guard let ml = ml else { return }
                                    
                                    DispatchQueue.main.async {
                                        self.moviesLists = ml
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
                    al.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.Button.DeleteList.Alert.No", comment: ""), style: .cancel, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(al, animated: true)
                } else {
                    MoviesListManager.shared.unregister(list: self.moviesLists[indexPath.row], completion: { result in
                        if result {
                            MoviesListManager.shared.getMovieLists(completion: { ml -> () in
                                guard let ml = ml else { return }
                                
                                DispatchQueue.main.async {
                                    self.moviesLists = ml
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
                }
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.Button.DeleteList.Alert.No", comment: ""), style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true)
        }
        
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row <= 1 || !isShownLikeTab  {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let a: SystemListID?
        if !isShownLikeTab {
            
            guard let passedMovie = passedMovie else {
                dismiss(animated: true, completion: nil)
                return
            }
            
            switch indexPath.row {
            case 0:
                a = .favorites
            case 1:
                a = .watchLater
            default:
                a = nil
            }
            
            if MoviesListManager.shared.findInLists(id: a, listToSearch: moviesLists[indexPath.row], movie: passedMovie) {
                let alert = UIAlertController(title: NSLocalizedString("ListsVC.View.Modal.AddingMovie.Alert.title", comment: ""),
                                              message: NSLocalizedString("ListsVC.View.Modal.AddingMovie.Alert.message", comment: ""),
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.View.Modal.AddingMovie.Alert.OK", comment: ""), style: .default, handler: nil))
                present(alert, animated: true)
            } else {
                MoviesListManager.shared.putFilmIntoUserList(listID: indexPath.row, movie: passedMovie)
                isShownLikeTab = true
                dismiss(animated: true, completion: nil)
            }
        } else {
            let storyboard = UIStoryboard(name: "MovieListViewController", bundle: nil)
            let movielistVC = storyboard.instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
            movielistVC.setMovies(movies: MoviesListManager.shared.moviesList[indexPath.row])
            movielistVC.title = MoviesListManager.shared.moviesList[indexPath.row].listName
            
            navigationController?.pushViewController(movielistVC, animated: true)
        }
    }
}

private extension ListsViewController {
    @objc func didTapBackButton() {
        isShownLikeTab = true
        dismiss(animated: true, completion: nil)
    }
    
    func raiseError() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("ListsVC.View.Error.Alert.title", comment: ""),
                                      message: NSLocalizedString("ListsVC.View.Error.Alert.message", comment: ""),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ListsVC.View.Error.Alert.OK", comment: ""), style: .default, handler: nil))
        return alert
    }
}

extension ListsViewController: MovieViewControllerDelegate {
    func updateTableView(sender: MovieViewController) {
        MoviesListManager.shared.getMovieLists(completion: { result -> () in
            self.moviesLists = result!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}
