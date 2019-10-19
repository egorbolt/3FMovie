import Foundation

struct MovieRelatedImages: Codable {
    let aspect_ratio: Float
    let file_path: String
    let height: Int
    let iso_639_1: String?
    let vote_average: Float
    let vote_count: Int
    let width: Int
}

struct Pictures: Codable {
    let id: Int
    let backdrops: [MovieRelatedImages]
    let posters: [MovieRelatedImages]
}
