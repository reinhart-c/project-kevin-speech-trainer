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
                    VStack{
                        Text("This is my first time to present product") //title
                        HStack{
                            Text("12 March 2024") //date
                            Text("Product") //tag
                        }
                    }
                    Button{
                        
                    } label: {
                        
                    }
                }
                HStack {
                    Rectangle() //recording&teleprompter
                    Rectangle() //score and emotion
                }
            }
        }
    }
}

#Preview {
    ResultView()
}

