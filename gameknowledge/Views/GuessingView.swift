//
//  GuessingView.swift
//  gameknowledge
//
//  Created by Chris Rowley on 9/23/24.
//

import SwiftUI

struct GuessingView: View {
    let darkGrey = UIColor(red: (59/225), green: (54/225), blue: (54/225), alpha: 1)

    var body: some View {
        ZStack{
            Color(darkGrey)
                .ignoresSafeArea()
            
            VStack{
                Text("Daily Guess") //Can change this to allow for modularity: different game modes
                    .font(Font.custom("Jersey10-Regular", size:50))
                    .foregroundStyle(.white)
                    .padding(.bottom, 75)
                Spacer()
                VStack{
                    //Placeholder image: will be game cover, etc
                    
                    Image(._400K)
                        .resizable()
                        .frame(width: 350, height:350)
                        .blur(radius: 10) // blur amount change by 5 each guess ?
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    GuessingView()
}
	
