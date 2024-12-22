import Foundation
import Contacts

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