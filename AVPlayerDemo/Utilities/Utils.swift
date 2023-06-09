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
                deviceOrientation = "Portrait"
                print("Portrait")
            case 2:
                deviceOrientation = "Upside Down"
                print("Upside Down")
            case 3:
                deviceOrientation = "Landscape Right"
                print("Landscape Right")
            case 4:
                deviceOrientation = "Landscape Left"
                print("Landscape Left")
            case 5:
                deviceOrientation = "Camera Facing Down"
                print("Camera Facing Down")
            case 6:
                deviceOrientation = "Camera Facing Up"
                print("Camera Facing Up")
            default:
                deviceOrientation = "Unknown"
                print("Unknown")
            }
            return deviceOrientation
        } else {
            return nil
        }
    }
}

