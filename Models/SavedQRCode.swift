import SwiftUI

struct SavedQRCode: Identifiable, Codable {
    let id: UUID
    let url: String
    let name: String
    let createdAt: Date
    let style: QRCodeStyle
    let contentType: QRContentType
    
    init(url: String, name: String = "", style: QRCodeStyle, contentType: QRContentType) {
        self.id = UUID()
        self.url = url
        self.name = name.isEmpty ? url : name
        self.createdAt = Date()
        self.style = style
        self.contentType = contentType
    }
}

struct QRCodeStyle: Codable {
    let backgroundColor: CodableColor
    let cornerStyle: QRCornerStyle
    let pixelStyle: QRPixelStyle
    let eyeShape: QREyeShape
    let logoData: Data?
    
    init(backgroundColor: CodableColor, cornerStyle: QRCornerStyle, pixelStyle: QRPixelStyle, eyeShape: QREyeShape, logoData: Data? = nil) {
        self.backgroundColor = backgroundColor
        self.cornerStyle = cornerStyle
        self.pixelStyle = pixelStyle
        self.eyeShape = eyeShape
        self.logoData = logoData
    }
}

// Helper struct to make Color codable
struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        red = Double(components[0])
        green = Double(components[1])
        blue = Double(components[2])
        alpha = Double(components[3])
    }
    
    var color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
} 