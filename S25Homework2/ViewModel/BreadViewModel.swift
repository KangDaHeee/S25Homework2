import SwiftUI

@MainActor
@Observable
final class BreadViewModel {
    private let repository: BreadRepository
        
    init(repository: BreadRepository = SupabaseBreadRepository()) {
        self.repository = repository
    }

    private var _breads: [Bread] = []
    var breads: [Bread] { _breads }
    
    var path = NavigationPath()
    
    func loadBreads() async {
        _breads = try! await repository.fetchBreads()
    }
    
    func addBread(_ bread: Bread) async {
            do {
                try await repository.saveBread(bread)
                _breads.append(bread)
            }
            catch {
                debugPrint("에러 발생: \(error)")
            }
        }
    
    func deleteBread(_ bread: Bread) async {
            do {
                try await repository.deleteBread(bread.id.uuidString)
                if let index = _breads.firstIndex(where: { $0.id == bread.id }) {
                    _breads.remove(at: index)
                }
            }
            catch {
                debugPrint("에러 발생: \(error)")
            }
        }
}
