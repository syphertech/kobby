//
//  VideoPlayerView.swift
//  kobby
//
//  Created by Maxwell Anane on 8/31/24.
//
import SwiftUI
import AVKit


struct VideoPlayerView: UIViewRepresentable {
    var videoName: String
    var videoType: String

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: .zero, videoName: videoName, videoType: videoType)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    init(frame: CGRect, videoName: String, videoType: String) {
        super.init(frame: frame)

        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else {
            return
        }

        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        layer.addSublayer(playerLayer)

        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
