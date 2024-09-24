import SwiftUI
import SwiftData

struct ContentView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack{
                Color(darkGrey)
                    .ignoresSafeArea()
                VStack{
                    Image(.amachine)
                    VStack {
                        ModeSelectButton(usrPrompt: "Daily Guess")
                            .padding(10)
                        ModeSelectButton(usrPrompt: "Marathon")
                            .padding(10)

                        ModeSelectButton(usrPrompt: "Special Mode")
                            .padding(10)

                        
                    }
                    .padding(100)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("GameHunt")
                        .font(Font.custom("Jersey10-Regular", size: 50))
                        .foregroundStyle(Color.white)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
