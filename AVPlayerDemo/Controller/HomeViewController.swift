//
//  HomeViewController.swift
//  AVPlayerDemo
//
//  Created by Mac on 13/6/23.
//

import UIKit

class HomeViewController: UIViewController {

    var videoPlayerController: VideoPlayerController?
    var isLive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       if (segue.identifier == "segueID") {
           
           let secondView = segue.destination as! VideoPlayerController
           secondView.isLiveStream = isLive
           
       }
    }
    
    
    @IBAction func liveStream(_ sender: Any) {
        
        isLive = true
        self.performSegue(withIdentifier: "segueID", sender: sender)
        
    }
    
    
    @IBAction func playVideo(_ sender: Any) {
        
        isLive = false
        self.performSegue(withIdentifier: "segueID", sender: sender)
        
    }

    
/// This fuinction can be used to navigate to another viewController as a child of this viewController. That's why I am commenting out, so that I can use it in future based on necessity.
/*
    func navigateVideoPlayerController() {

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
*/
    
}
