import SwiftUI
import ContactsUI

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
            
            Button {
                showingContactPicker = true
            } label: {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .foregroundStyle(textColor.opacity(0.7))
                    
                    if let contact = selectedContact {
                        Text("\(contact.givenName) \(contact.familyName)")
                            .foregroundStyle(textColor)
                    } else {
                        Text("Select Contact")
                            .foregroundStyle(textColor.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(textColor.opacity(0.7))
                }
                .padding()
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPicker(selectedContact: $selectedContact)
        }
    }
}

struct ContactPicker: UIViewControllerRepresentable {
    @Binding var selectedContact: CNContact?
    
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
        let parent: ContactPicker
        
        init(_ parent: ContactPicker) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.selectedContact = contact
        }
    }
}

#Preview {
    ContactPickerView(
        selectedContact: .constant(nil),
        showingContactPicker: .constant(false),
        backgroundColor: .blue
    )
    .padding()
    .background(Color.gray.opacity(0.1))
} 