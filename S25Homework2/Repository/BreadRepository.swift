protocol BreadRepository: Sendable {
    func fetchBreads() async throws -> [Bread]
    
    func saveBread(_ bread: Bread) async throws
    
    func deleteBread(_ id: String) async throws
}

