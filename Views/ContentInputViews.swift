import SwiftUI
import ContactsUI

struct WifiInputView: View {
    @Binding var network: WifiNetwork
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wi-Fi Network")
                .font(.headline)
                .foregroundStyle(textColor)
            
            VStack(spacing: 12) {
                InputField(
                    title: "Network Name",
                    text: Binding(
                        get: { network.ssid },
                        set: { network.ssid = $0 }
                    ),
                    icon: "wifi",
                    backgroundColor: backgroundColor
                )
                
                InputField(
                    title: "Password",
                    text: Binding(
                        get: { network.password },
                        set: { network.password = $0 }
                    ),
                    icon: "lock",
                    isSecure: true,
                    backgroundColor: backgroundColor
                )
                
                Picker("Security", selection: Binding(
                    get: { network.securityType },
                    set: { network.securityType = $0 }
                )) {
                    ForEach(WifiNetwork.SecurityType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Hidden Network", isOn: Binding(
                    get: { network.isHidden },
                    set: { network.isHidden = $0 }
                ))
                .foregroundStyle(textColor)
            }
            .padding()
            .background(Color(backgroundColor).opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .padding()
    }
}

struct TextInputView: View {
    @Binding var text: String
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text")
                .font(.headline)
                .foregroundStyle(textColor)
            
            TextEditor(text: $text)
                .frame(height: 150)
                .padding()
                .foregroundStyle(textColor)
                .scrollContentBackground(.hidden)
                .background(Color(backgroundColor).opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .padding()
    }
}

struct ContactPickerView: View {
    @Binding var selectedContact: CNContact?
    @Binding var showingContactPicker: Bool
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact")
                .font(.headline)
                .foregroundStyle(textColor)
            
            if let contact = selectedContact {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "")
                                .font(.headline)
                                .foregroundStyle(textColor)
                            
                            if let email = contact.emailAddresses.first?.value as String? {
                                Label(email, systemImage: "envelope")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(textColor).opacity(0.7))
                            }
                            
                            if let phone = contact.phoneNumbers.first?.value.stringValue {
                                Label(phone, systemImage: "phone")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(textColor).opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            selectedContact = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color(textColor).opacity(0.7))
                        }
                    }
                }
                .padding()
                .background(Color(backgroundColor).opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            
            Button {
                showingContactPicker = true
            } label: {
                HStack {
                    Label(
                        selectedContact == nil ? "Select Contact" : "Change Contact",
                        systemImage: "person.crop.circle.badge.plus"
                    )
                    .font(.body)
                    .foregroundStyle(textColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(textColor).opacity(0.7))
                }
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerViewController(contact: $selectedContact)
            }
        }
        .padding()
    }
}

struct ContactPickerViewController: UIViewControllerRepresentable {
    @Binding var contact: CNContact?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerViewController
        
        init(_ parent: ContactPickerViewController) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.contact = contact
        }
    }
} 
