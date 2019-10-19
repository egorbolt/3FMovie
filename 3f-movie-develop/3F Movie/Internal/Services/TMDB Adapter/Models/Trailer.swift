import Foundation

struct Trailer: Codable {
    let id: Int
    let results: [TrailerInfo]
}
