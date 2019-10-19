import Foundation

enum SystemListID {
    case favorites
    case watchLater
    
    var id: Int {
        switch self {
        case .favorites:
            return 0
        case .watchLater:
            return 1
        }
    }
    
    var readableText: String {
        switch self {
        case .favorites:
            return NSLocalizedString("MoviesListManager.SystemListID.Favorites", comment: "")
        case .watchLater:
            return NSLocalizedString("MoviesListManager.SystemListID.WatchLater", comment: "")
        }
    }
}

struct Languages {
    static var currentLanguage: String {
        switch Locale.current.languageCode {
        case "en", "en_US", "en_GB":
            return "en-US"
        case "ru":
            return "ru-RU"
        default:
            return "en-US"
        }
    }
}

protocol RecordsManagerType {
    var moviesList: [ListModel] { get }
    func register(list: ListModel, completion: @escaping (Bool) -> Void) throws
    func unregister(list: ListModel, completion: @escaping (Bool) -> Void)
    func update(list: ListModel, completion: @escaping (Bool) -> Void)
    func synchronize(completion: @escaping (Bool) -> Void) throws
}

final class MoviesListManager: RecordsManagerType {
    static let shared = MoviesListManager()
    private(set) lazy var moviesList = loadCachedRecords()
    let locale = Languages.currentLanguage
    
    func register(list: ListModel, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            self.moviesList.append(list)
            do {
                try self.synchronize(completion: { result -> () in
                    completion(true)
                    return
                })
            } catch let error {
                print(error.localizedDescription)
                completion(false)
                return
            }
        }
    }
    
    func unregister(list: ListModel, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            guard let index = self.moviesList.firstIndex(of: list) else {
                return
            }
            self.moviesList.remove(at: index)
            do {
                try self.synchronize(completion: { result -> () in
                    completion(true)
                    return
                })
            } catch let error {
                print(error.localizedDescription)
                completion(false)
                return
            }
        }
    }
    
    func update(list: ListModel, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if let firstElement = self.moviesList.enumerated().first(where: { $0.element.id == list.id }) {
                self.moviesList[firstElement.offset] = ListModel(id: list.id, listName: list.listName, movies: list.movies)

                do {
                    try self.synchronize(completion: { result -> () in
                        completion(true)
                        return
                    })
                    
                } catch let error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
            }
        }
    }
    
    func synchronize(completion: @escaping (Bool) -> Void) throws {
        try DispatchQueue.global().sync {
            let data = try JSONEncoder().encode(self.moviesList)
            guard let url = MoviesListManager.managerUrl else {
                completion(false)
                return
            }
            try data.write(to: url)
            completion(true)
            return
        }
    }
    
    func updateName(list: ListModel, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            self.getMovieList(id: list.id, completion: { result -> () in
                if var target = result {
                    target.listName = list.listName
                    self.update(list: target, completion: { result -> () in
                        completion(true)
                        return
                    })
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func getMovieLists(completion: @escaping ([ListModel]?) -> Void) {
        DispatchQueue.global().async {
            var moviesLists = self.moviesList
            moviesLists[0].listName = NSLocalizedString("MoviesListManager.SystemListID.Favorites", comment: "")
            moviesLists[1].listName = NSLocalizedString("MoviesListManager.SystemListID.WatchLater", comment: "")
            self.updateName(list: moviesLists[0], completion: { (_) -> () in
            })
            self.updateName(list: moviesLists[1], completion: { (_) -> () in
            })

            completion(moviesLists)
        }
    }
    
    
    
    func getMovieList(index: Int, completion: @escaping (ListModel) -> Void) {
        DispatchQueue.global().async {
            let moviesList = self.moviesList[index]
            completion(moviesList)
        }
    }
    
    func putFilmIntoUserList(listID: Int, movie: MovieInfo) {
        DispatchQueue.global().async {
            self.getMovieList(index: listID, completion: { result -> () in
                var targetList = result
                
                targetList.movies.append(movie)
                self.moviesList[listID].movies.append(movie)
                self.update(list: targetList, completion: { result -> () in
                })
            })
        }
    }
    
    func deleteFilmFromUserList(listID: Int, movie: MovieInfo) {
        DispatchQueue.global().async {
            self.getMovieList(index: listID, completion: { result -> () in
                var targetList = result
                
                if let firstElement = targetList.movies.enumerated().first(where: { $0.element.id == movie.id }) {
                    targetList.movies.remove(at: firstElement.offset)
                    self.update(list: targetList, completion: { result -> () in
                    })
                }
            })
        }
    }
    
    func putFilmIntoSystemList(list: SystemListID, movie: MovieInfo) {
        DispatchQueue.global().async {
            self.getMovieList(index: list.id, completion: { result -> () in
                var targetList = result
                
                targetList.movies.append(movie)
                switch list {
                case .favorites:
                    self.moviesList[0].movies.append(movie)
                case .watchLater:
                    self.moviesList[1].movies.append(movie)
                }
                self.update(list: targetList, completion: { result -> () in
                })
            })
        }
    }
    
    func deleteFilmFromSystemList(list: SystemListID, movie: MovieInfo) {
        DispatchQueue.global().async {
            self.getMovieList(index: list.id, completion: { result -> () in
                var targetList = result
                
                if let firstElement = targetList.movies.enumerated().first(where: { $0.element.id == movie.id }) {
                    targetList.movies.remove(at: firstElement.offset)
                    switch list {
                    case .favorites:
                        let a = self.moviesList[0].movies.enumerated().first(where: { $0.element.id == movie.id })
                        self.moviesList[0].movies.remove(at: a!.offset)
                    case .watchLater:
                        let a = self.moviesList[1].movies.enumerated().first(where: { $0.element.id == movie.id })
                        self.moviesList[1].movies.remove(at: a!.offset)
                    }
                    self.update(list: targetList, completion: { result -> () in
                    })
                }
            })
        }
    }
    
    func deleteFilmFromList(listID: String, id: Int, movie: MovieInfo, completion: @escaping (Bool) -> ()) {
        DispatchQueue.global().async {
            self.getMovieList(id: listID, completion: { result -> () in
                let targetList = result
                if var targetList = targetList, let movieToDelete = targetList.movies.enumerated().first(where: { $0.element.id == movie.id }) {
                    targetList.movies.remove(at: movieToDelete.offset)
                    self.update(list: targetList, completion: { result -> () in
                        completion(true)
                    })
                } else {
                    completion(false)
                }
            })
        }
    }
    
    func findInLists(id: SystemListID?, listToSearch: ListModel?, movie: MovieInfo) -> Bool {
        switch id {
        case .favorites?:
            if moviesList[0].movies.contains(movie) {
                return true
            }
        case .watchLater?:
            if moviesList[1].movies.contains(movie) {
                return true
            }
        case .none:
            guard let listToSearch = listToSearch else { return false }
            if listToSearch.movies.contains(movie) {
                return true
            }
        }
        return false
    }
    
    func findInFavoriteList(movie: MovieInfo) -> Bool {
        if moviesList[0].movies.contains(movie) {
            return true
        }
        return false
    }
    
    func findInWatchLaterList(movie: MovieInfo) -> Bool {
        if moviesList[1].movies.contains(movie) {
            return true
        }
        return false
    }
    
    func getMovieList(id: String, completion: @escaping (ListModel?) -> Void) {
        DispatchQueue.global().async {
            if let firstElement = self.moviesList.first(where: { $0.id == id }) {
                completion(firstElement)
            } else {
                completion(nil)
            }
        }
    }
    
}

private extension MoviesListManager {
    func loadCachedRecords() -> [ListModel] {
        guard let url = MoviesListManager.managerUrl else { return [] }
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            let records = try JSONDecoder().decode([ListModel].self, from: data)
            return records
        } catch let error {
            print(error.localizedDescription)
            let a = ListModel(listName: NSLocalizedString("MoviesListManager.SystemListID.Favorites", comment: ""), movies: [])
            let a1 = ListModel(listName: NSLocalizedString("MoviesListManager.SystemListID.WatchLater", comment: ""), movies: [])
            let b = [a, a1]
            guard let dec = try? JSONEncoder().encode(b) else { return [] }
            FileManager.default.createFile(atPath: url.path, contents: dec, attributes: nil)
            return b
        }
    }
    
    private static var managerUrl: URL? {
        let defaultFileNameForLocalStore = "AwesomeFileName.dat"
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let fileURLForLocalStore = documentDirectoryURL?.appendingPathComponent(defaultFileNameForLocalStore)
        return fileURLForLocalStore
    }
}
