import Foundation

struct WifiNetwork: Codable, Equatable {
    enum SecurityType: String, Codable, CaseIterable {
        case wpa = "WPA"
        case wep = "WEP"
        case noPassword = "nopass"
    }
    
    var ssid: String
    var password: String
    var isHidden: Bool
    var securityType: SecurityType
    
    func generateQRString() -> String {
        var components = ["WIFI:"]
        components.append("S:\(ssid)")
        components.append("T:\(securityType.rawValue)")
        if !password.isEmpty {
            components.append("P:\(password)")
        }
        if isHidden {
            components.append("H:true")
        }
        components.append(";")
        return components.joined(separator: ";")
    }
} 