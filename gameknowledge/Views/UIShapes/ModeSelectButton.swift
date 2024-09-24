import SwiftUI

struct ModeSelectButton: View {
    let usrPrompt: String
    
    var body: some View {
        Button(action: {
            // Button action
        }) {
            Text(usrPrompt)
                .font(Font.custom("Jersey10-Regular", size: 50))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(width: 300, height: 80)
        }
        .frame(width: 320, height: 100) // Fixed outer frame
        .foregroundColor(.white)
        .background(Color.orange)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    VStack {
        ModeSelectButton(usrPrompt: "Classic")
        ModeSelectButton(usrPrompt: "A Longer Text")
        ModeSelectButton(usrPrompt: "Short")
    }
}
