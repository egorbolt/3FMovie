import Foundation

struct MoviesCollection: Codable, Equatable {
    let id: Int
    let backdrop_path: String?
    let name: String
    let poster_path: String?
}
