//
//  ResultView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import SwiftUI

struct ResultView: View {
    var body: some View {
        ScrollView{
            VStack {
                HStack{
                    VStack(alignment: .leading){
                        Text("This is my first time to present product") //title
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 30, weight: .semibold))
                            .padding(.top, 40)
                        
                        
                        HStack{
                            Text("12 March 2024") //date
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 20))
                            
                            Circle()
                                .foregroundStyle(Color.lightGrey)
                                .frame(width: 5, height: 5)
                            
                            Text("Product") //tag
                                .font(.system(size: 20))
                        }
                        
                    }
                    
                    
                    Spacer()
                    
                    Button{
                        
                    } label: {
                        Text("Back to home")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 20))
                    }
                    .padding()
                    .background(Color.redButton)
                    .cornerRadius(30)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 50)
                }
                .padding([.leading, .trailing], 40)
                .padding(.bottom, 20)
                
                HStack {
                    Rectangle()
//                    SpeechView() //recording&teleprompter temp
                    FluencyScore() //score and emotion
                }
                .padding([.leading, .trailing], 40)
                .background(Color.lightBlue)
                .cornerRadius(20)
                .frame(width: 400, height: 500)
            }
        }
    }
}

#Preview {
    ResultView()
}

