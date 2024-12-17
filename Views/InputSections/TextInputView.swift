import SwiftUI

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
                .frame(height: 100)
                .padding()
                .foregroundStyle(textColor)
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    TextInputView(
        text: .constant("Sample text content"),
        backgroundColor: .blue
    )
    .padding()
    .background(Color.gray.opacity(0.1))
} 