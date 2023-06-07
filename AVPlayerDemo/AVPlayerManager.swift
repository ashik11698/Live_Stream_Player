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
}
