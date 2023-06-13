//
//  Utils.swift
//  AVPlayerDemo
//
//  Created by Mac on 9/6/23.
//

import UIKit
import AVKit

class Utils {
    
    static let shared = Utils()
    
    func generateImagesFromVideo(avPlayer: AVPlayer, completion: @escaping ([ Double : UIImage ]) -> ()) {
        var images: [ Double : UIImage ] = [:]
        guard let asset = avPlayer.currentItem?.asset else {
            return
        }
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.maximumSize = CGSize(width: 150, height: 80)
        let seconds = asset.duration.seconds
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: Array(1...99).map{ NSValue(time:CMTimeMake(value: $0 * Int64(seconds), timescale: 100))  }) { (requestedTime, cgImage, actualTime, result, error) in
            guard let image = cgImage else {
                return
            }
            images[actualTime.seconds] = UIImage(cgImage: image)
            completion(images)
        }
    }
    
    // MARK: - Checks the orientation of device
    /// This function is to check the orientation of the ios device
    /// - Returns: Return the orientation status of device as String
    func deviceOrientation() -> String! {
        let device = UIDevice.current
        if device.isGeneratingDeviceOrientationNotifications {
            device.beginGeneratingDeviceOrientationNotifications()
            var deviceOrientation: String
            let deviceOrientationRaw = device.orientation.rawValue
            switch deviceOrientationRaw {
            case 1:
                deviceOrientation = Keys.orientation.portrait.rawValue
                print("Portrait")
            case 2:
                deviceOrientation = Keys.orientation.upsideDown.rawValue
                print("Upside Down")
            case 3:
                deviceOrientation = Keys.orientation.landscapeRight.rawValue
                print("Landscape Right")
            case 4:
                deviceOrientation = Keys.orientation.landscapeLeft.rawValue
                print("Landscape Left")
            case 5:
                deviceOrientation = Keys.orientation.cameraFacingDown.rawValue
                print("Camera Facing Down")
            case 6:
                deviceOrientation = Keys.orientation.cameraFacingUp.rawValue
                print("Camera Facing Up")
            default:
                deviceOrientation = Keys.orientation.unknown.rawValue
                print("Unknown")
            }
            return deviceOrientation
        } else {
            return nil
        }
    }
    
    // MARK: - Function to convert degree to radian
    /// This function to convert degree to radian
    /// - Parameter x: Takes degree as CGFloat
    /// - Returns: Returns radian value as CGFloat of given degree
    func degreeToRadian(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
    
    // MARK: - Function to center any button inside any UIView
    /// This function is to set any button in the middle of of any UIView.
    /// - Parameters:
    ///   - view: Takes UIView, where the button will be placed (in the middle)
    ///   - button: Takes button, which will be placed in middle of the given UIView
    func setButtonCenter(view: UIView, button: UIButton) {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.frame = CGRect(
            x: (view.bounds.width - button.bounds.width) / 2,
            y: (view.bounds.height - button.bounds.height) / 2,
            width: button.bounds.width,
            height: button.bounds.height
        )
    }
    
    // MARK: - getCurrentTimeOfVideo
    /// This function get the current time and return
    /// - Returns: returns the current time of video
    func getCurrentTimeOfVideo(avPlayer: AVPlayer) -> Float64 {
        let currentTime = avPlayer.currentItem?.currentTime()
        guard let currentTime = currentTime else {
            return 0.0
        }
        let currentTimeInSeconds : Float64 = CMTimeGetSeconds(currentTime)
        return currentTimeInSeconds
    }
}
