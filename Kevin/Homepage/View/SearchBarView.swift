//
//  SearchBarView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black)
                .clipShape(Circle())

            TextField("Search recordings...", text: $searchText)
                .font(.system(size: 18))
                .foregroundColor(.black) 
                .accentColor(.blue) 
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 10)
            
            // Add clear button when there's text
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
                .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 6)
        .background(
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 30))
        )
        .overlay( // Add stroke on top
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray.opacity(0.2))
        )
        .frame(width: 230)
        .padding(.horizontal)
    }
}

#Preview {
    @State var searchText = "test"
    return SearchBarView(searchText: $searchText)
        .background(Color.gray.opacity(0.2)) 
}
