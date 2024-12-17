import SwiftUI

struct WifiInputView: View {
    @Binding var network: WifiNetwork
    let backgroundColor: Color
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WiFi Network")
                .font(.headline)
                .foregroundStyle(textColor)
            
            VStack(spacing: 12) {
                // Network Name
                InputField(
                    title: "Network Name",
                    text: $network.ssid,
                    icon: "wifi",
                    backgroundColor: backgroundColor
                )
                
                // Password
                InputField(
                    title: "Password",
                    text: $network.password,
                    icon: "lock",
                    isSecure: true,
                    backgroundColor: backgroundColor
                )
                
                // Security Type
                Picker("Security", selection: $network.securityType) {
                    ForEach(WifiNetwork.SecurityType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                // Hidden Network Toggle
                Toggle(isOn: $network.isHidden) {
                    Text("Hidden Network")
                        .foregroundStyle(textColor)
                }
                .tint(backgroundColor)
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
    }
}

private struct InputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    let backgroundColor: Color
    @State private var isShowingPassword = false
    
    private var textColor: Color {
        backgroundColor.isLight ? .black : .white
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(textColor.opacity(0.7))
            
            if isSecure && !isShowingPassword {
                SecureField(title, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundStyle(textColor)
            } else {
                TextField(title, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundStyle(textColor)
            }
            
            if isSecure {
                Button {
                    isShowingPassword.toggle()
                } label: {
                    Image(systemName: isShowingPassword ? "eye.slash" : "eye")
                        .foregroundStyle(textColor.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    WifiInputView(
        network: .constant(WifiNetwork(
            ssid: "My Network",
            password: "password123",
            isHidden: false,
            securityType: .wpa
        )),
        backgroundColor: .blue
    )
    .padding()
    .background(Color.gray.opacity(0.1))
} 