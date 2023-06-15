//
//  ActionSheet.swift
//  AVPlayerDemo
//
//  Created by Mac on 15/6/23.
//

import UIKit
import AVKit

class ActionSheet {
    
    static let shared = ActionSheet()
    
    /// This function sets rate of AVPlayer through action sheet
    /// - Parameters:
    ///   - avPlayer: change the rate of this player
    ///   - viewController: This is the controller where the action sheet will display
    func speedActionSheet(avPlayer: AVPlayer) -> UIAlertController {
        
        let speedAlert = UIAlertController(title: "Video Speed", message: "Select any", preferredStyle: .actionSheet)
        
        speedAlert.addAction(UIAlertAction(title: "6x", style: .default , handler:{ (UIAlertAction)in
            AVPlayerManager.shared.setSpeedToAVPlayer(rate: 6.0, avPlayer: avPlayer)
        }))
        
        speedAlert.addAction(UIAlertAction(title: "4x", style: .default , handler:{ (UIAlertAction)in
            AVPlayerManager.shared.setSpeedToAVPlayer(rate: 4.0, avPlayer: avPlayer)
        }))

        speedAlert.addAction(UIAlertAction(title: "2x", style: .default , handler:{ (UIAlertAction)in
            AVPlayerManager.shared.setSpeedToAVPlayer(rate: 2.0, avPlayer: avPlayer)
        }))
        
        speedAlert.addAction(UIAlertAction(title: "Normal", style: .default, handler:{ (UIAlertAction)in
            AVPlayerManager.shared.setSpeedToAVPlayer(rate: 1.0, avPlayer: avPlayer)
        }))
        
        speedAlert.addAction(UIAlertAction(title: "0.1x", style: .default, handler:{ (UIAlertAction)in
            AVPlayerManager.shared.setSpeedToAVPlayer(rate: 0.1, avPlayer: avPlayer)
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        return speedAlert
    }
    
}
