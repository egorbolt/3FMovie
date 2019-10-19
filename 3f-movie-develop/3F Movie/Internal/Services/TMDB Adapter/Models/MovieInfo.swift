import Foundation

struct MovieInfo: Codable, Equatable {
    let adult: Bool
    let backdrop_path: String?
    let belongs_to_collection: MoviesCollection?
    let budget: Int
    let genres: [Genre]
    let homepage: String?
    let id: Int
    let imdb_id: String?
    let original_language: String
    let original_title: String
    let overview: String?
    let popularity: Float
    let poster_path: String?
    let production_companies: [ProductionCompany]
    let production_countries: [ProductionCountry]
    let release_date: String
    let revenue: Int
    let runtime: Int?
    let spoken_languages: [SpokenLanguage]
    let status: String
    let tagline: String?
    let title: String
    let video: Bool
    let vote_average: Float
    let vote_count: Int
}
