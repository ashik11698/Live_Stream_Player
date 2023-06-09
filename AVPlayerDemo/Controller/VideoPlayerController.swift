//
//  VideoPlayerController.swift
//  AVPlayerDemo
//
//  Created by Mac on 1/6/23.
//

import UIKit
import AVKit

class VideoPlayerController: UIViewController {
    
    /// This is the outlet of UIView, where the video shows. The helps to set the position of PlayerLayer
    @IBOutlet weak var playerView: UIView!
    /// This is a button outlet, which can control exit/enter in full screen mode
    @IBOutlet weak var fullScreenButtonOutlet: UIButton!
    /// This is a button outlet, which can start the video from the begenning each time we clicked
    @IBOutlet weak var startButtonOutlet: UIButton!
    /// This is a button outlet, which can control play and pause both
    @IBOutlet weak var playAndPauseButtonOutlet: UIButton!
    /// This is the array of speed buttons. E.g., 0.75x, 1x, 1.5x, 2x, etc
    @IBOutlet var speedsButtonOutlet: [UIButton]!
    /// Speed StackView. All the speed buttons are inside it
    @IBOutlet weak var speedStackView: UIStackView!
    /// Slider to slide the video
    @IBOutlet weak var slider: UISlider!
    /// Activity Indicator to show buffer
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Tracks whether the video in rotated or not
    var isRotate = false
    /// Tracks whether the video is paused or playing, because a single button is working for both pause and play
    var isPause = false

    var playerLayer = AVPlayerLayer()
    var avPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        playAndPauseButtonOutlet.isHidden = true
        fullScreenButtonOutlet.isHidden = true
        speedStackView.isHidden = true
        slider.isHidden = true
    }
    
    // MARK: - Executes when phone orientation changes
    /// This is to observe the phone orientation
    /// - Parameters:
    ///   - size: This parameter represents the new size that the view will have after the transition. It provides the dimensions of the view's bounds in the new orientation or size
    ///   - coordinator: It provides methods and properties to coordinate animations and additional actions during the transition.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }

            // Perform any animations or layout-related operations during the transition
            let orientation = Utils.shared.deviceOrientation()
            if orientation == "Portrait" {
                self.showVideoInPortrait()
                self.isRotate = false
            }
            if orientation == "Landscape Right" {
                self.showVideoInLandscape()
                self.isRotate = true
            }
            if orientation == "Landscape Left" {
                self.showVideoInLandscape()
            }
        }, completion: nil)
    }
    
    // MARK: - Observe Buffering
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.activityIndicator.stopAnimating()
                        self?.activityIndicator.isHidden = true
                        
                        self?.playAndPauseButtonOutlet.isHidden = false
                        self?.fullScreenButtonOutlet.isHidden = false
                        self?.speedStackView.isHidden = false
                        self?.slider.isHidden = false
                    } else {
                        self?.activityIndicator.startAnimating()
                        self?.activityIndicator.isHidden = false
                    }
                }
            }
        }
    }

    // MARK: - Starts the video from beginning
    /// This is a button to start a video. Here configures the player and set the frame of playerLayer to an UIView (playerView)
    @IBAction func startVideo(_ sender: Any) {
        // Remove playerLayer from its parent layer
        playerLayer.removeFromSuperlayer()
        playerLayer.player = nil
        
        // Initially the Pause button will be Visisble
        playAndPauseButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        //let url = Bundle.main.url(forResource: "Sample3", withExtension: "mp4")
        //let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        let url = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2023/10187/5/1D820D6D-4F01-48EB-8F22-901F4A4B69FE/cmaf.m3u8")
        
        guard let url = url else {
            print("Video doesn't exist or format issue. Please make sure the correct name of the video and format.")
            return
        }
        
        avPlayer = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: avPlayer)
        
        // Buffer
        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        configureSlider()
        
        self.playerView.layer.addSublayer(playerLayer)
        
        // Set the frame of the player Layer according to the playerView bound
        playerLayer.frame = self.playerView.layer.bounds
        
        // Set the full Screen Button to playerView
        self.playerView.addSubview(fullScreenButtonOutlet)
        
        // Set the play Button to playerView
        self.playerView.addSubview(playAndPauseButtonOutlet)
        
        // Set the speed stackView to playerView
        self.playerView.addSubview(speedStackView)
        
        // Set the slider to playerView
        self.playerView.addSubview(slider)
        
        // Set the activity indicator to playerView
        self.playerView.addSubview(activityIndicator)
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        // Play the video
        avPlayer.play()
    }
    
    // MARK: - Take the video in full screen mode
    /// This is a button and used to enter and exit full screen mode
    @IBAction func makeVideoFullScreen(_ sender: Any) {
        print("makeVideoFullScreen")
        
        if self.isRotate == false {
            enterFullScreen()
            print("enterFullScreen")
        }
        else {
            ExitFullScreen()
            print("ExitFullScreen")
        }
    }
    
    // MARK: - Set icons of playAndPauseBtnOutlet
    /// This is a button to pause and play video. This can toggle from pause to play and vice versa
    @IBAction func playAndPauseVideo(_ sender: Any) {
        if !isPause {
            avPlayer.pause()
            playAndPauseButtonOutlet.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else {
            avPlayer.play()
            playAndPauseButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isPause = !isPause
    }
    
    // MARK: - Speed Button
    /// By clicking it, all the speed option will be visible and invisible
    @IBAction func selectSpeed(_ sender: Any) {
        
        speedsButtonOutlet.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Speed 0.1x
    @IBAction func setSpeed0Point1x(_ sender: Any) {
        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
        avPlayer.play()
        avPlayer.rate = 0.1
        hideSpeedButton()
    }
    
    // MARK: - Speed Normal (1.0x)
    @IBAction func setSpeedNormal(_ sender: Any) {
        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
        avPlayer.play()
        avPlayer.rate = 1.0
        hideSpeedButton()
    }
    
    // MARK: - Speed 2x
    @IBAction func setSpeed2x(_ sender: Any) {
        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
        avPlayer.play()
        avPlayer.rate = 2.0
        hideSpeedButton()
    }
    
    // MARK: - Speed 4x
    @IBAction func setSpeed4x(_ sender: Any) {
        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
        avPlayer.play()
        avPlayer.rate = 4.0
        hideSpeedButton()
    }
    
    // MARK: - Speed 6x
    @IBAction func setSpeed6x(_ sender: Any) {
        avPlayer.currentItem?.audioTimePitchAlgorithm = .timeDomain
        avPlayer.play()
        avPlayer.rate = 6.0
        hideSpeedButton()
    }
    
    // MARK: - Function to convert degree to radian
    /// This function to convert degree to radian
    /// - Parameter x: Takes degree as CGFloat
    /// - Returns: Returns radian value as CGFloat of given degree
    func degreeToRadian(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
    
    // MARK: - Function to show the video in portrait mode
    /// This functions calls, when we need to show the video in portrait mode. This function rotates playerLayer and playAndPauseBtnOutlet 360 degree to set the video straight.
    func showVideoInPortrait() {
        if isRotate {
            let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(360))
            playerLayer.setAffineTransform(affineTransform)

            playAndPauseButtonOutlet.transform = CGAffineTransform(rotationAngle: degreeToRadian(360))
            
            playerView.transform = CGAffineTransform(rotationAngle: degreeToRadian(360))
        }
        
        playerView.isHidden = false
        startButtonOutlet.isHidden = false

        let width = view.bounds.width - 10
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        playerView.frame = CGRect(x: 5, y: 60, width: width, height: 200)
        playerLayer.frame = playerView.bounds
    }
    
    // MARK: - Function to show the video in landscape mode
    /// This function calls when the device is in landscape mode. It hides all the button and UIView and set the playerViewframe to the main view (To cover entire screen).
    func showVideoInLandscape() {
        if isRotate {
            let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(360))
            playerLayer.setAffineTransform(affineTransform)
            
            playAndPauseButtonOutlet.transform = CGAffineTransform(rotationAngle: degreeToRadian(360))
            
            playerView.transform = CGAffineTransform(rotationAngle: degreeToRadian(360))
        }

        startButtonOutlet.isHidden = true
        
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        self.playerView.frame = self.view.bounds
        self.playerLayer.frame = self.playerView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }
    
    /// This function works when we click the full screen button to enter in full screen mode. It rotates playerView and set the playerView frame to the main view.
    func enterFullScreen() {
        //Rotate the playerView to 90 Degree
        playerView.transform = CGAffineTransform(rotationAngle: degreeToRadian(90))
        
        startButtonOutlet.isHidden = true
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        self.playerView.frame = self.view.bounds
        self.playerLayer.frame = self.playerView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        self.isRotate = true
    }
    
    /// This function calls when we are in portrait mode.
    func ExitFullScreen() {
        showVideoInPortrait()
        self.isRotate = false
    }
    
    /// This function hides the speed options when we tap any one of them
    func hideSpeedButton() {
        speedsButtonOutlet.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Configure the Slider
    /// Did all the tasks of slider here
    func configureSlider() {
        slider.minimumValue = 0
        let duration = self.avPlayer.currentItem?.asset.duration
        
        guard let duration = duration else {
            return
        }
        
        let seconds : Float64 = CMTimeGetSeconds(duration)
     
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        slider.tintColor = UIColor.red
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            let currentTime = self?.getCurrentTimeOfVideo()
            self?.slider.setValue(Float(currentTime ?? 0.0), animated: true)
        }
        
        if Float64(slider.maximumValue) == getCurrentTimeOfVideo() {
            timer.invalidate()
            print("timer.invalidate()")
        }
        
        slider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        let seconds: Int64 = Int64(playbackSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        avPlayer.seek(to: targetTime)
    }
    
    // MARK: - getCurrentTimeOfVideo
    /// This function get the current time and return
    /// - Returns: returns the current time of video
    func getCurrentTimeOfVideo() -> Float64 {
        let currentTime = avPlayer.currentItem?.currentTime()
        guard let currentTime = currentTime else {
            return 0.0
        }
        let currentTimeInSeconds : Float64 = CMTimeGetSeconds(currentTime)
        return currentTimeInSeconds
    }
}
