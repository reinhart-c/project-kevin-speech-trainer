//
//  CameraPreview.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 18/06/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer = previewLayer

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) -> Void {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session

            DispatchQueue.main.async {
                 if layer.frame != nsView.bounds {
                    layer.frame = nsView.bounds
                }
            }
        }
    }
}
