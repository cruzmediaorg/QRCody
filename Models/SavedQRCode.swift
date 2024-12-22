import SwiftUI
import QRCode
import UIKit

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
    let cornerStyle: QRCodeCornerStyle
    let pixelStyle: QRCodePixelStyle
    let eyeShape: QRCodeEyeShape
    let logoData: Data?
    
    init(backgroundColor: CodableColor, cornerStyle: QRCodeCornerStyle, pixelStyle: QRCodePixelStyle, eyeShape: QRCodeEyeShape, logoData: Data? = nil) {
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
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
} 