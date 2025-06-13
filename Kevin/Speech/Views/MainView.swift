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
                Button{
                    
                } label:{
                    Image(systemName: "arrow.trianglehead.clockwise")
                        
                }
                .buttonStyle(PlainButtonStyle())
                
                Button{
                    
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
            }
            
            HStack {
                //SpeechView()
                Rectangle() //teleprompter
            }
        }
        .padding()
    }
}

#Preview {
    MainView()
}
