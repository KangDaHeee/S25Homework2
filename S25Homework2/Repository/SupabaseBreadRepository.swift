import Foundation

final class SupabaseBreadRepository: BreadRepository {
    func fetchBreads() async throws -> [Bread] {
        let requestURL = URL(string: BreadApiConfig.serverURL)!
        let (data, _) = try! await URLSession.shared.data(from: requestURL)
        let decoder = JSONDecoder()
        return try! decoder.decode([Bread].self, from: data)
    }
    
    func saveBread(_ bread: Bread) async throws {
            let requestURL = URL(string: BreadApiConfig.serverURL)!
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(bread)
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response
                    as? HTTPURLResponse,
                    httpResponse.statusCode == 201
            else {
                throw URLError(.badServerResponse)
            }
        }
    
    func deleteBread(_ id: String) async throws {
            let urlString = "\(BreadApiConfig.projectURL)/rest/v1/bakery?id=eq.\(id)&apikey=\(BreadApiConfig.apiKey)"
            let requestURL = URL(string: urlString)!
            var request = URLRequest(url: requestURL)
            request.httpMethod = "DELETE"
            
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response
                    as? HTTPURLResponse,
                    httpResponse.statusCode == 204
            else {
                throw URLError(.badServerResponse)
            }
        }
    
}

