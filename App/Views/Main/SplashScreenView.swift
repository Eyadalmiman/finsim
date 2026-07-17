import SwiftUI
import AVFoundation

/// Full-screen launch animation: plays the bundled logo video once, then
/// fades away. The video was exported with a fake status bar and Dynamic
/// Island baked into its top strip, so the player is scaled and offset to
/// crop that strip off — only clean artwork reaches the screen.
struct SplashScreenView: View {
    var onFinished: () -> Void = {}

    // Source video geometry: 402×874 with status-bar pixels in the top 56.
    private static let videoSize = CGSize(width: 402, height: 874)
    private static let croppedTop: CGFloat = 56

    @State private var player: AVPlayer?

    var body: some View {
        GeometryReader { geo in
            // Scale so the region below the cropped strip covers the screen.
            let visibleHeight = Self.videoSize.height - Self.croppedTop
            let scale = max(geo.size.width / Self.videoSize.width,
                            geo.size.height / visibleHeight)
            let videoWidth = Self.videoSize.width * scale
            let videoHeight = Self.videoSize.height * scale

            ZStack(alignment: .topLeading) {
                Color.finSimGreen

                if let player {
                    VideoLayerView(player: player)
                        .frame(width: videoWidth, height: videoHeight)
                        .offset(x: (geo.size.width - videoWidth) / 2,
                                y: -Self.croppedTop * scale)
                }
            }
            .clipped()
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .onAppear(perform: startPlayback)
    }

    private func startPlayback() {
        guard player == nil else { return }

        guard let url = Bundle.main.url(forResource: "LoadingSplash", withExtension: "mp4") else {
            onFinished()      // never trap the user on a blank screen
            return
        }

        let item = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: item)
        avPlayer.isMuted = true
        player = avPlayer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            onFinished()
        }

        avPlayer.play()

        // Failsafe: if playback stalls for any reason, move on anyway.
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            onFinished()
        }
    }
}

/// AVPlayerLayer host — SwiftUI's VideoPlayer ships playback controls, so
/// the raw layer is used instead for a chrome-free splash.
private struct VideoLayerView: UIViewRepresentable {
    let player: AVPlayer

    final class PlayerContainerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
    }
}
