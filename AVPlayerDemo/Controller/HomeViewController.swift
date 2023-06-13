//
//  HomeViewController.swift
//  AVPlayerDemo
//
//  Created by Mac on 13/6/23.
//

import UIKit

class HomeViewController: UIViewController {

    var videoPlayerController: VideoPlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToVideoPlayerController(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.videoPlayerController = storyboard.instantiateViewController(withIdentifier: "VideoPlayerVC") as? VideoPlayerController
        self.videoPlayerController?.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(self.videoPlayerController!.view)
        self.addChild(self.videoPlayerController!)
        
        self.videoPlayerController?.minimizedOrigin = {
            let x = 0.0
            let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 25)
            let coordinate = CGPoint.init(x: x, y: y)
            return coordinate
        }()
    }
}
