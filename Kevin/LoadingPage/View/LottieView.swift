//
//  LottieView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 14/06/25.
//

import SwiftUI
import Lottie

struct LottieView: NSViewRepresentable {

    var filename: String

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

        let animationView = LottieAnimationView(name: filename)
        animationView.frame = view.bounds
        animationView.autoresizingMask = [.width, .height]
        animationView.loopMode = .loop
        animationView.play()

        view.addSubview(animationView)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
