//
//  SearchBarView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black)
                .clipShape(Circle())

            TextField("Search", text: $searchText)
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 10)
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
    SearchBarView()
}
