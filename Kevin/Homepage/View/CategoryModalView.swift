//
//  CategoryModalView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 16/06/25.
//

import SwiftUI

struct CategoryModalView: View {
    var category: Category
    var onReady: (String) -> Void // Changed to pass the title

    @State private var title: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Before you begin…")
                .font(.title.bold())
                .foregroundStyle(Color.black)
                .padding(.top, 10)

            Text("Name your speech practice first!")
                .foregroundColor(.gray)
                .padding(.bottom, 10)

            TextField("Practice Title", text: $title)
                .padding()
                .textFieldStyle(PlainTextFieldStyle())
                .background(
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray.opacity(0.3))
                )
                .frame(width: 500)
                .foregroundStyle(Color.black)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 999).stroke(Color.lightGrey))
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 180)
                }.buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    onReady(title.isEmpty ? "Untitled Practice" : title) // Pass the title
                    dismiss()
                } label: {
                    if title == ""{
                        //disabled
                        Text("I'm Ready")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 180)
                            .cornerRadius(999)
                    }else{
                        //enabled
                        Text("I'm Ready")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 180)
                            .cornerRadius(999)
                    }
                }.buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    CategoryModalView(
        category: Category(
            title: "Product deserves the spotlight",
            subtitle: "Deliver product pitches that build trust and interest",
            tag: "Product",
            backgroundColor: Color.lightBlue,
            icon: "lightbulb.max"
        ),
        onReady: { title in
            print("Ready with title: \(title)")
        }
    )
}
