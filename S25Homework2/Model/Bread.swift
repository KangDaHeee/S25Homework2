import Foundation

struct Bread: Identifiable, Decodable, Encodable, Hashable {
    let id: UUID
    let name: String
    let calories: Int
    let rating: Int
    let description: String?
}
