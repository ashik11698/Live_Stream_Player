//
//  AVPlayerManager.swift
//  AVPlayerDemo
//
//  Created by Mac on 5/6/23.
//

import UIKit
import AVKit

class AVPlayerManager {
    var playerLayer = AVPlayerLayer()
    var avPlayer = AVPlayer()
    
    static let shared = AVPlayerManager()
    
    // Check if the video is playable or not
    func getVideoPlayerOnline(url: URL?) async -> AVPlayer? {
        guard let url = url else {
            print("url not found")
            return nil
        }
        //test if video is playable
        let (isPlayable, _) = try! await AVAsset(url: url).load(.isPlayable, .isExportable)
        
        if isPlayable {
            let player = AVPlayer(url: url)
            return player
        } else {
            return nil
        }
    }
    
    // MARK: - Skip Video In Forward
    func skipTimeForward(seconds: Int64, avPlayer: AVPlayer) {
        let currentTime = Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer)
        let targetTime: CMTime = CMTimeMake(value: Int64(currentTime) + seconds, timescale: 1)
        avPlayer.seek(to: targetTime) // Skip video according to targetTime
    }
    
    // MARK: - Skip Video In Backward
    func skipTimeBackward(seconds: Int64, avPlayer: AVPlayer) {
        let currentTime = Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer)
        let targetTime: CMTime = CMTimeMake(value: Int64(currentTime) - seconds, timescale: 1)
        avPlayer.seek(to: targetTime) // Skip video according to targetTime
    }
    
    // MARK: - Configure Mini Player
    func configureMiniPlayer(view: UIView, playerView: UIView, playerLayer: AVPlayerLayer, crossButton: UIButton, playAndPauseButtonForMiniPlayer: UIButton, minimizedOrigin: CGPoint?, playAndPauseButtonOutlet: UIButton) -> (UIButton, UIButton) {
//        self.hidePlayerControllers()
//        self.unhideMiniPlayerButtons()
        view.backgroundColor = UIColor.lightGray
        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 100)
        
        //self.startButtonOutlet.isHidden = true
        view.frame.origin = minimizedOrigin!
        
        playerView.translatesAutoresizingMaskIntoConstraints = true
        
        playerView.frame = CGRect(x: 5, y: 0, width: view.bounds.width/2, height: view.bounds.height)
        playerLayer.frame = playerView.bounds
        
        let x = (Int(view.bounds.width - playerView.bounds.width) - Int(playAndPauseButtonOutlet.bounds.width)) / 2 + Int(playerView.bounds.width)
        
        crossButton.frame = CGRect(
            x: x,
            y: Int(view.bounds.height - playAndPauseButtonOutlet.bounds.height) / 2,
            width: Int(playAndPauseButtonOutlet.frame.width),
            height: Int(playAndPauseButtonOutlet.frame.height)
        )
        
        playAndPauseButtonForMiniPlayer.frame = CGRect(
            x: x + 30,
            y: Int(view.bounds.height - playAndPauseButtonOutlet.bounds.height) / 2,
            width: Int(playAndPauseButtonOutlet.frame.width),
            height: Int(playAndPauseButtonOutlet.frame.height)
        )
        
        view.addSubview(crossButton)
        //crossButton.addTarget(self, action:#selector(self.closeMiniPlayer), for: .touchUpInside)
        
        view.addSubview(playAndPauseButtonForMiniPlayer)
        //playAndPauseButtonForMiniPlayer.addTarget(self, action:#selector(pauseMiniPlayer), for: .touchUpInside)
        
        //self.isMinimize = true
        
        return (crossButton, playAndPauseButtonForMiniPlayer)
    }
}
