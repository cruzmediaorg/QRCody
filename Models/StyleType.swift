import Foundation

enum StyleType {
    case corner, pixel, eye
    
    var title: String {
        switch self {
        case .corner: return "Corner Style"
        case .pixel: return "Pixel Style"
        case .eye: return "Eye Style"
        }
    }
} 