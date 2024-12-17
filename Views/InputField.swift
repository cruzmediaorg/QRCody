import SwiftUI

struct InputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    let backgroundColor: Color
    
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
                
                if isSecure {
                    SecureField("", text: $text)
                        .textFieldStyle(.plain)
                        .foregroundStyle(textColor)
                } else {
                    TextField("", text: $text)
                        .textFieldStyle(.plain)
                        .foregroundStyle(textColor)
                }
            }
            .padding()
            .background(backgroundColor.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
} 