import Foundation

struct Genre: Codable, Equatable {
    let id: Int
    let name: String
}

struct GenreList: Codable {
    let genres: [Genre]
}
