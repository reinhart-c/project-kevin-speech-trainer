//
//  PrompterView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import SwiftUI

struct PrompterView: View {
    @ObservedObject var viewModel: PrompterViewModel 

    var body: some View {
        VStack(alignment: .leading) {
            Text("Teleprompter")
                .font(.headline)
                .padding(.bottom, 5)
            ScrollView {
                viewModel.words.enumerated().reduce(Text("")) { (accumulatedText, pair) in
                    let (index, word) = pair
                    return accumulatedText +
                           Text(word + " ") 
                               .font(.title3)
                               .foregroundColor(index == viewModel.currentWordIndex ? Color.accentColor : Color.primary) // Highlight current word
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading) 
            }
            .frame(height: 380) 
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .frame(width: 300) 
    }
}

struct PrompterView_Previews: PreviewProvider {
    static var previews: some View {
        PrompterView(viewModel: PrompterViewModel(script: "Preview script with a few words to see highlighting."))
    }
}
