import Foundation

enum QRContentType: String, Identifiable, CaseIterable, Codable {
    case url
    case wifi
    case text
    case contact
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .url: return "URL"
        case .wifi: return "Wi-Fi"
        case .text: return "Text"
        case .contact: return "Contact"
        }
    }
    
    var icon: String {
        switch self {
        case .url: return "link"
        case .wifi: return "wifi"
        case .text: return "text.alignleft"
        case .contact: return "person.crop.circle"
        }
    }
} 