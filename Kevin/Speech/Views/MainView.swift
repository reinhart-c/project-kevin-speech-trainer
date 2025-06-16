//
//  MainView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Product deserves the spotlight") //category.title
                    .font(.system(size: 30, weight: .semibold))
                    .padding(.leading, 40)
                
                Spacer()
                
                Button{
                    //end session
                } label:{
                    Image(systemName: "arrow.trianglehead.clockwise")
                        .font(.system(size: 30))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button{
                    //RetrySession
                    
                } label:{
                    Text("End Session")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }
                .padding()
                .background(Color.redButton)
                .cornerRadius(30)
                .buttonStyle(PlainButtonStyle())

                ProgressBar()
                    .padding(.trailing, 40)
            }
            
            HStack {
                SpeechView()
            }
        }
        .padding()
    }
}

#Preview {
    MainView()
}
