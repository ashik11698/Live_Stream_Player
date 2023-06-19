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
    /// - Returns: returns UIAlertController to show sheet in viewController where the functions called
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
        speedAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        return speedAlert
    }
    
    
    /// This function sets quality of AVPlayer through action sheet
    /// - Parameters:
    ///   - avPlayer: change the quality of this player
    /// - Returns: returns UIAlertController to show sheet in viewController where the functions called
    func qualityActionSheet(avPlayer: AVPlayer) -> UIAlertController {
        
        let speedAlert = UIAlertController(title: "Quality", message: "Select any", preferredStyle: .actionSheet)
        
        speedAlert.addAction(UIAlertAction(title: "1080p", style: .default , handler:{ (UIAlertAction)in
            
        }))
        
        speedAlert.addAction(UIAlertAction(title: "720p", style: .default , handler:{ (UIAlertAction)in
            
        }))

        speedAlert.addAction(UIAlertAction(title: "480p", style: .default , handler:{ (UIAlertAction)in
            
        }))
        
        speedAlert.addAction(UIAlertAction(title: "360p", style: .default, handler:{ (UIAlertAction)in
            
        }))
        
        speedAlert.addAction(UIAlertAction(title: "240p", style: .default, handler:{ (UIAlertAction)in
            
        }))
        speedAlert.addAction(UIAlertAction(title: "144p", style: .default, handler:{ (UIAlertAction)in
            
        }))
        speedAlert.addAction(UIAlertAction(title: "Auto", style: .default, handler:{ (UIAlertAction)in
            
        }))
        speedAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        return speedAlert
    }
    
}
