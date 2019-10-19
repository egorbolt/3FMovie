//
//  SearchTableView.swift
//  3F Movie
//
//  Created by stud on 13/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

class SearchTableView: UITableViewController, API {
    
    // MARK: - Properties
    private var navController: UINavigationController!
    private var movies: [Movie] = []
    private var requestsQueue = OperationQueue()
    private var currentPage = 1
    private var totalPages = 0
    private var textToSearch = ""
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    
    // MARK: - Methods
    @objc func dismissMovieVC() {
        navController.dismiss(animated: true, completion: nil)
        navController = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        movies = []
        currentPage = 1
        totalPages = 0
        textToSearch = ""
    }
    
}


// MARK: - UISearchResultsUpdating Delegate
extension SearchTableView: UISearchResultsUpdating {
    
    private func updateSearchWith(queury: String) {
        requestsQueue.cancelAllOperations()
        let downloadDataOperation = BlockOperation {
            let downloadDataDispatchGroup = DispatchGroup()
            
            downloadDataDispatchGroup.enter()
            self.loadMovies(url: self.urlSearchMovie(query: queury)) { [weak self] (downloadedMovies, pages) in
                guard let self = self else { return }
                self.movies = downloadedMovies
                self.totalPages = pages
                downloadDataDispatchGroup.leave()
            }
            downloadDataDispatchGroup.wait()
        }
        
        let updateUIOperation = BlockOperation {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        updateUIOperation.addDependency(downloadDataOperation)
        requestsQueue.addOperation(downloadDataOperation)
        requestsQueue.addOperation(updateUIOperation)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let textToSearch = searchController.searchBar.text, textToSearch != "" else { return }
        self.textToSearch = textToSearch
        updateSearchWith(queury: textToSearch)
    }
    
}


// MARK: - UITableviewDelegate
extension SearchTableView {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieStoryboard = UIStoryboard(name: "MovieController", bundle: nil)
        let movieViewController = movieStoryboard.instantiateInitialViewController() as! MovieViewController
        movieViewController.setMovieID(movieID: movies[indexPath.row].id)
        tableView.deselectRow(at: indexPath, animated: true)
        navController = UINavigationController(rootViewController: movieViewController)
        navController.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissMovieVC))
        present(navController, animated: true, completion: nil)
    }
    
}


// MARK: - UITableviewDataSource
extension SearchTableView {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell,
            let movieAtIndexPath = movies.safelyGetElementAt(indexPath)
            else { return UITableViewCell() }
        // FIXME: - DOIT
        cell.setupCell(movieImagePath: "https://image.tmdb.org/t/p/w500\(movieAtIndexPath.poster_path ?? "")", movieName: movieAtIndexPath.title, movieOverview: movieAtIndexPath.overview)
        return cell
    }
    
}

private extension SearchTableView {
    
    private func loadNextPage() {
        currentPage += 1
        guard requestsQueue.operationCount == 0 else { return }
        loadMovies(url: "\(urlSearchMovie(query: textToSearch))&page=\(currentPage)") { (movies, pages) in
            DispatchQueue.main.async {
                self.movies.append(contentsOf: movies)
                self.tableView.reloadData()
            }
        }
    }
    
}

extension SearchTableView {
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height
            && currentPage < totalPages {
            loadNextPage()
        }
    }
    
}
