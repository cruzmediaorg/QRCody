import SwiftUI

class QRCodeViewModel: ObservableObject {
    @Published var savedQRCodes: [SavedQRCode] = []
    private let storageManager = StorageManager.shared
    
    init() {
        loadSavedQRCodes()
    }
    
    func loadSavedQRCodes() {
        savedQRCodes = storageManager.getAllQRCodes()
    }
    
    func saveCurrentQRCode(url: String, style: QRCodeStyle, contentType: QRContentType) {
        let qrCode = SavedQRCode(url: url, style: style, contentType: contentType)
        storageManager.saveQRCode(qrCode)
        loadSavedQRCodes()
    }
    
    func deleteQRCode(_ qrCode: SavedQRCode) {
        storageManager.deleteQRCode(withId: qrCode.id)
        loadSavedQRCodes()
    }
} 