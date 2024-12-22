import SwiftUI

struct InputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    let backgroundColor: Color
    @State private var isTextVisible = false
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(textColor.opacity(0.7))
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(textColor.opacity(0.7))
                
                if isSecure && !isTextVisible {
                    SecureField("Enter \(title.lowercased())", text: $text)
                        .textFieldStyle(.plain)
                        .foregroundStyle(textColor)
                } else {
                    TextField("Enter \(title.lowercased())", text: $text)
                        .textFieldStyle(.plain)
                        .foregroundStyle(textColor)
                }
                
                if isSecure {
                    Button {
                        isTextVisible.toggle()
                    } label: {
                        Image(systemName: isTextVisible ? "eye.slash" : "eye")
                            .foregroundStyle(textColor.opacity(0.7))
                    }
                }
                
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(textColor.opacity(0.7))
                    }
                }
            }
        }
    }
}

#Preview {
    InputField(
        title: "Test Field",
        text: .constant(""),
        icon: "textfield",
        backgroundColor: .blue
    )
    .padding()
} 