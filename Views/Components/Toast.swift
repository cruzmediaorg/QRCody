import SwiftUI

struct Toast: View {
    let message: String
    let icon: String
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
            Text(message)
        }
        .font(.subheadline.bold())
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.8))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    Toast(message: "QR Code saved!", icon: "checkmark.circle.fill", isPresented: .constant(true))
} 