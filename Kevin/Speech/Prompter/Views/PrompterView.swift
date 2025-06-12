//
//  PrompterView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import SwiftUI

struct PrompterView: View {
    @StateObject private var viewModel = PrompterViewModel()

    var body: some View {
        VStack(alignment: .leading){
            Text("Teleprompter")
                .font(.headline)
                .padding(.bottom, 5)
            ScrollView{
                Text(viewModel.prompter.script)
                    .font(.title3)
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

#Preview {
    PrompterView()
}
