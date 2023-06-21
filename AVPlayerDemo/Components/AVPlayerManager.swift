//
//  AVPlayerManager.swift
//  AVPlayerDemo
//
//  Created by Mac on 5/6/23.
//

import UIKit
import AVKit

class AVPlayerManager {
    
    static let shared = AVPlayerManager()
    
    // MARK: - Check if the video is playable or not
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
    /// This function is to skip video in forward
    /// - Parameters:
    ///   - seconds: seconds to forward the video
    ///   - avPlayer: which avPlayer to forward
    func skipTimeForward(seconds: Int64, avPlayer: AVPlayer) {
        
        let currentTime = Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer)
        let targetTime: CMTime = CMTimeMake(value: Int64(currentTime) + seconds, timescale: 1)
        avPlayer.seek(to: targetTime) // Skip video according to targetTime
        
    }
    
    
    // MARK: - Skip Video In Backward
    /// This function is to skip video in backward
    /// - Parameters:
    ///   - seconds: seconds to backward the video
    ///   - avPlayer: which avPlayer to backward
    func skipTimeBackward(seconds: Int64, avPlayer: AVPlayer) {
        
        let currentTime = Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer)
        let targetTime: CMTime = CMTimeMake(value: Int64(currentTime) - seconds, timescale: 1)
        avPlayer.seek(to: targetTime) // Skip video according to targetTime
        
    }
    
    
//    // MARK: - Configure Mini Player
//    /// This function is to place the mini player and it's buttons to right place
//    /// - Parameters:
//    ///   - view: This is the main view where the plyerView is situated
//    ///   - playerView: This is the playerView where the plyerLayer is situated
//    ///   - playerLayer: This is the playerLayer of AVPlayer
//    ///   - crossButton: Cancel button of mini player
//    ///   - playAndPauseButtonForMiniPlayer: Pause/Play button of mini player
//    ///   - minimizedOrigin: This is the origin of the mini player
//    ///   - buttonWidth: button width of mini player
//    ///   - buttonHeight: button height of mini player
//    /// - Returns: returns a tuple of buttons (cancel button and pause/play button)
//    func configureMiniPlayer(view: UIView, playerView: UIView, playerLayer: AVPlayerLayer, crossButton: UIButton, playAndPauseButtonForMiniPlayer: UIButton, minimizedOrigin: CGPoint?, buttonWidth: Int, buttonHeight: Int) -> (UIButton, UIButton) {
//
//        view.backgroundColor = UIColor.lightGray
//        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 100)
//        view.frame.origin = minimizedOrigin!
//
//        playerView.translatesAutoresizingMaskIntoConstraints = true
//        playerView.frame = CGRect(x: 5, y: 0, width: view.bounds.width/2, height: view.bounds.height)
//
//        playerLayer.frame = playerView.bounds
//
//        let x = (Int(view.bounds.width - playerView.bounds.width) - Int(buttonWidth)) / 2 + Int(playerView.bounds.width)
//
//        playAndPauseButtonForMiniPlayer.frame = CGRect(
//            x: x - 20,
//            y: (Int(view.bounds.height) - buttonHeight) / 2,
//            width: Int(buttonWidth),
//            height: Int(buttonHeight)
//        )
//
//        crossButton.frame = CGRect(
//            x: x + 35,
//            y: (Int(view.bounds.height) - buttonHeight) / 2,
//            width: Int(buttonWidth),
//            height: Int(buttonHeight)
//        )
//
//        view.addSubview(playAndPauseButtonForMiniPlayer)
//        view.addSubview(crossButton)
//
//        return (crossButton, playAndPauseButtonForMiniPlayer)
//
//    }
//
//
//    // MARK: - Set Speed to AVPlayer
//    /// This functions sets the speed of avPlayer
//    /// - Parameter rate: In which speed the avPlayer should play
//    func setSpeedToAVPlayer(rate: Float, avPlayer: AVPlayer) {
//
//        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
//        avPlayer.play()
//        avPlayer.rate = rate // In this rate (speed) the video will play
//
//    }
    
    
    
    // MARK: - Configure Mini Player
    /// This function is to place the mini player and it's buttons to right place
    /// - Parameters:
    ///   - view: This is the main view where the plyerView is situated
    ///   - playerView: This is the playerView where the plyerLayer is situated
    ///   - playerLayer: This is the playerLayer of AVPlayer
    ///   - crossButton: Cancel button of mini player
    ///   - playAndPauseButtonForMiniPlayer: Pause/Play button of mini player
    ///   - minimizedOrigin: This is the origin of the mini player
    ///   - buttonWidth: button width of mini player
    ///   - buttonHeight: button height of mini player
    /// - Returns: returns a tuple of buttons (cancel button and pause/play button)
    func configureMiniPlayer(view: UIView, playerView: UIView, playerLayer: AVPlayerLayer, crossButton: UIButton, playAndPauseButtonForMiniPlayer: UIButton, minimizedOrigin: CGPoint?, buttonWidth: Int, buttonHeight: Int) -> (UIButton, UIButton) {
        
        view.addSubview(playerView)
        
        view.backgroundColor = UIColor.lightGray
//        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 100)
        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/7)
        view.frame.origin = minimizedOrigin!
        
        playerView.translatesAutoresizingMaskIntoConstraints = true
        playerView.frame = CGRect(x: 5, y: 0, width: view.bounds.width/2, height: view.bounds.height)
        
        playerLayer.frame = playerView.bounds
        
        let x = (Int(view.bounds.width - playerView.bounds.width) - Int(buttonWidth)) / 2 + Int(playerView.bounds.width)
        
        playAndPauseButtonForMiniPlayer.frame = CGRect(
            x: x - 20,
            y: (Int(view.bounds.height) - buttonHeight) / 2,
            width: Int(buttonWidth),
            height: Int(buttonHeight)
        )
        
        crossButton.frame = CGRect(
            x: x + 35,
            y: (Int(view.bounds.height) - buttonHeight) / 2,
            width: Int(buttonWidth),
            height: Int(buttonHeight)
        )
        
        view.addSubview(playAndPauseButtonForMiniPlayer)
        view.addSubview(crossButton)
        
        return (crossButton, playAndPauseButtonForMiniPlayer)
        
    }
    
    
    // MARK: - Set Speed to AVPlayer
    /// This functions sets the speed of avPlayer
    /// - Parameter rate: In which speed the avPlayer should play
    func setSpeedToAVPlayer(rate: Float, avPlayer: AVPlayer) {
        
        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
        avPlayer.play()
        avPlayer.rate = rate // In this rate (speed) the video will play
        
    }
    
    
}
