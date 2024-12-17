import Foundation

class StorageManager {
    static let shared = StorageManager()
    private let userDefaults = UserDefaults.standard
    private let qrCodesKey = "saved_qr_codes"
    
    private init() {}
    
    func saveQRCode(_ qrCode: SavedQRCode) {
        var savedCodes = getAllQRCodes()
        savedCodes.append(qrCode)
        save(qrCodes: savedCodes)
    }
    
    func getAllQRCodes() -> [SavedQRCode] {
        guard let data = userDefaults.data(forKey: qrCodesKey),
              let qrCodes = try? JSONDecoder().decode([SavedQRCode].self, from: data) else {
            return []
        }
        return qrCodes
    }
    
    func deleteQRCode(withId id: UUID) {
        var savedCodes = getAllQRCodes()
        savedCodes.removeAll { $0.id == id }
        save(qrCodes: savedCodes)
    }
    
    private func save(qrCodes: [SavedQRCode]) {
        guard let data = try? JSONEncoder().encode(qrCodes) else { return }
        userDefaults.set(data, forKey: qrCodesKey)
    }
} 