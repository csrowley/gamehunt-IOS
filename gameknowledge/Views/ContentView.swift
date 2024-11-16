import SwiftUI
import SwiftData

struct ContentView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)
    @State var showDailyView = false
    @State var showMarathonView = false
    @State var showSpecialModeView = false // change name in future corresponding to new mode
    @State var showInfiniteView = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(darkGrey)
                    .ignoresSafeArea()
                VStack {
                    Image(.amachine)
                    VStack {
                        NavigationLink(destination: GuessingView(), isActive: $showDailyView) {
                            EmptyView()
                        }
                        ModeSelectButton(usrPrompt: "Daily Guess", toggleView: $showDailyView)
                            .padding(.bottom, 50)
                        
                        NavigationLink(destination: InfiniteView(), isActive: $showInfiniteView) {
                            EmptyView()
                        }
                        ModeSelectButton(usrPrompt: "Infinite Mode", toggleView: $showInfiniteView)
                            .padding(.bottom, 10)
                        
                    }
                    .padding(100)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cover Quest")
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
