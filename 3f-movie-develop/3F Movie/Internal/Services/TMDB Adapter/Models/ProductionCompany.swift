import Foundation

struct ProductionCompany: Codable, Equatable {
    let name: String
    let id: Int
    let logo_path: String?
    let origin_country: String
}
