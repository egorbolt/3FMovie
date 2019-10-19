import Foundation

struct ListModel: Codable, Equatable {
    var id = UUID().uuidString
    var listName: String
    var movies: [MovieInfo]
    var listMoviesAmount: Int {
        return movies.count
    }
    
    init(listName: String, movies: [MovieInfo]) {
        self.listName = listName
        self.movies = movies
    }
    
    init(id: String, listName: String, movies: [MovieInfo]) {
        self.init(listName: listName, movies: movies)
        self.id = id
    }
}
