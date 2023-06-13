//
//  Urls.swift
//  AVPlayerDemo
//
//  Created by Mac on 12/6/23.
//

import Foundation

class Urls {
    // Video saved in the project
    static let sample3 = Bundle.main.url(
        forResource: "Sample3",
        withExtension: "mp4"
    )
    
    // Video From Online
    static let BigBuckBunny = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
    
    // Video of m3u8
    static let m3u8video1 = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2023/10187/5/1D820D6D-4F01-48EB-8F22-901F4A4B69FE/cmaf.m3u8")
    
    // Video of m3u8
    static let m3u8video2 = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2023/10078/5/A2493B0B-6540-4634-B38C-E2FEFC0F8DAC/cmaf/hvc/2160p_11600/hvc_2160p_11600.m3u8")
}
