import Foundation

enum QRCornerStyle: String, CaseIterable, Codable {
    case square = "Square"
    case rounded = "Rounded"
    case extraRounded = "Extra Rounded"
}

enum QRPixelStyle: String, CaseIterable, Codable {
    case square = "Square"
    case circle = "Circle"
    case roundedPath = "Rounded Path"
    case curvePixel = "Curve"
    case flower = "Flower"
    case heart = "Heart"
    case star = "Star"
    case horizontal = "Horizontal"
    case vertical = "Vertical"
    case wave = "Wave"
}

enum QREyeShape: String, CaseIterable, Codable {
    case square = "Square"
    case circle = "Circle"
    case roundedRect = "Rounded"
    case leaf = "Leaf"
    case shield = "Shield"
    case fireball = "Fireball"
    case eye = "Eye"
} 