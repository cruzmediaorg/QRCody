import Foundation
import Contacts

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

struct WifiNetwork: Equatable, Codable {
    var ssid: String
    var password: String
    var isHidden: Bool
    var securityType: SecurityType
    
    enum SecurityType: String, CaseIterable, Codable, Equatable {
        case wpa = "WPA/WPA2"
        case wep = "WEP"
        case noPassword = "None"
        
        var mecard: String {
            switch self {
            case .wpa: return "WPA"
            case .wep: return "WEP"
            case .noPassword: return "nopass"
            }
        }
    }
    
    func generateQRString() -> String {
        var components = ["WIFI:"]
        components.append("S:\(ssid)")
        
        if securityType != .noPassword {
            components.append("T:\(securityType.mecard)")
            components.append("P:\(password)")
        }
        
        if isHidden {
            components.append("H:true")
        }
        
        components.append(";")
        return components.joined(separator: ";")
    }
}

struct ContactInfo: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    
    init(contact: CNContact) {
        self.firstName = contact.givenName
        self.lastName = contact.familyName
        self.email = contact.emailAddresses.first?.value as? String ?? ""
        self.phone = contact.phoneNumbers.first?.value.stringValue ?? ""
    }
    
    func generateQRString() -> String {
        var components = ["BEGIN:VCARD", "VERSION:3.0"]
        
        // Name
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        components.append("FN:\(fullName)")
        
        // Phone
        if !phone.isEmpty {
            components.append("TEL:\(phone)")
        }
        
        // Email
        if !email.isEmpty {
            components.append("EMAIL:\(email)")
        }
        
        components.append("END:VCARD")
        return components.joined(separator: "\n")
    }
} 