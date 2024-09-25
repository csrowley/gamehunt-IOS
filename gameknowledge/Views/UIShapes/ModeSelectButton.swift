import SwiftUI

struct ModeSelectButton: View {
    let usrPrompt: String
    @Binding var toggleView: Bool
    
    var body: some View {
        Button(action: {
            toggleView.toggle()
        }) {
            Text(usrPrompt)
                .font(Font.custom("Jersey10-Regular", size: 50))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
        }
        .frame(width: 320, height: 100)
        .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    VStack {
        ModeSelectButton(usrPrompt: "Classic", toggleView: .constant(false))
        ModeSelectButton(usrPrompt: "A Longer Text", toggleView: .constant(false))
        ModeSelectButton(usrPrompt: "Short", toggleView: .constant(false))
    }
}
