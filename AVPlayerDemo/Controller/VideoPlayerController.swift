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
    /// To skip the video in forward
    @IBOutlet weak var forwardSkipButtonOutlet: UIButton!
    /// To skip the video in backward
    @IBOutlet weak var backwardSkipButtonOutlet: UIButton!
    /// Mini Player Button Outlet
    @IBOutlet weak var miniPlayerButtonOutlet: UIButton!
    
    /// Tracks whether the video in rotated or not
    var isRotate = false
    /// Tracks whether the video is paused or playing, because a single button is working for both pause and play
    var isPause = false
    /// Tracks whether mini player starts or not
    var isMinimize = false
    /// Origin of the mini player
    var minimizedOrigin: CGPoint?
    
    var crossButton = UIButton()
    var playAndPauseButtonForMiniPlayer = UIButton()

    var playerLayer = AVPlayerLayer()
    var avPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Play And Pause Button For MiniPlayer
        self.playAndPauseButtonForMiniPlayer = UIButton().createButton(
            tintColor: UIColor.black,
            title: "",
            imageName: "pause")
        
        // Create Cross Button For MiniPlayer
        self.crossButton = UIButton().createButton(
            tintColor: UIColor.black,
            title: "",
            imageName: "xmark")
        
        hidePlayerControllers()
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
            if orientation == Keys.orientation.portrait.rawValue {
                self.showVideoInPortrait()
                self.isRotate = false
                self.miniPlayerButtonOutlet.isHidden = false
                self.hideMiniPlayerButtons()
            }
            if orientation == Keys.orientation.landscapeRight.rawValue || orientation == Keys.orientation.landscapeLeft.rawValue {
                self.showVideoInLandscape()
                self.isRotate = true
                self.miniPlayerButtonOutlet.isHidden = true
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
                        
                        if self?.isMinimize == false {
                            self?.unhidePlayerControllers()
                        }
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

        let url = Urls.m3u8video2
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
        
        // Set the forwardSkipButtonOutlet to playerView
        self.playerView.addSubview(forwardSkipButtonOutlet)
        
        // Set the backwardSkipButtonOutlet to playerView
        self.playerView.addSubview(backwardSkipButtonOutlet)
        
        // Set the mini player outlet to playerView
        self.playerView.addSubview(miniPlayerButtonOutlet)
        
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
            self.miniPlayerButtonOutlet.isHidden = true
            self.hideMiniPlayerButtons()
            print("enterFullScreen")
        }
        else {
            ExitFullScreen()
            self.miniPlayerButtonOutlet.isHidden = false
            print("ExitFullScreen")
        }
    }
    
    // MARK: - Set icons of playAndPauseBtnOutlet
    /// This is a button to pause and play video. This can toggle from pause to play and vice versa
    @IBAction func playAndPauseVideo(_ sender: Any) {
        togglePauseAndPlay(button: playAndPauseButtonOutlet)
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
    
    // MARK: - Forward Skip
    @IBAction func skipVideoInForward(_ sender: Any) {
        //skipTimeForward(seconds: 10)
        AVPlayerManager.shared.skipTimeForward(seconds: 10, avPlayer: avPlayer)
    }
    
    // MARK: - Backward Skip
    @IBAction func skipVideoInBackward(_ sender: Any) {
        //skipTimeBackward(seconds: 10)
        AVPlayerManager.shared.skipTimeBackward(seconds: 10, avPlayer: avPlayer)
    }
    
    // MARK: - Mini Player Button
    @IBAction func startMiniPlayer(_ sender: Any) {
        UIView.animate(withDuration: 0.3 , animations: {
            if self.isMinimize == false {
                self.hidePlayerControllers()
                self.unhideMiniPlayerButtons()
                self.startButtonOutlet.isHidden = true
                
                (self.crossButton, self.playAndPauseButtonForMiniPlayer) = AVPlayerManager.shared.configureMiniPlayer(
                    view: self.view,
                    playerView: self.playerView,
                    playerLayer: self.playerLayer,
                    crossButton: self.crossButton,
                    playAndPauseButtonForMiniPlayer: self.playAndPauseButtonForMiniPlayer,
                    minimizedOrigin: self.minimizedOrigin,
                    playAndPauseButtonOutlet: self.playAndPauseButtonOutlet
                )
                
                self.crossButton.addTarget(self, action:#selector(self.closeMiniPlayer), for: .touchUpInside)
                
                self.playAndPauseButtonForMiniPlayer.addTarget(self, action:#selector(self.pauseMiniPlayer), for: .touchUpInside)
                
                self.isMinimize = true
            }
        })
    }
    
    @objc func closeMiniPlayer() {
        print("Button closeMiniPlayer")
        UIView.animate(withDuration: 0.3, animations: {
            self.playerLayer.player?.pause()
            self.view.frame.origin.x = -self.view.bounds.width - 20
        })
    }
    
    @objc func pauseMiniPlayer() {
        togglePauseAndPlay(button: playAndPauseButtonForMiniPlayer)
    }
    
    // MARK: - Player View Action
    @IBAction func expandMiniPlayerToNormalSize(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            if self.isMinimize {
                self.view.backgroundColor = UIColor.white
                self.unhidePlayerControllers()
                self.hideMiniPlayerButtons()
                self.view.bounds = UIScreen.main.bounds
                self.view.frame.origin = CGPoint.init(x: 0, y: 0)
                self.showVideoInPortrait()
                self.isMinimize = false
            }
        })
    }
    
    // MARK: - Function to show the video in portrait mode
    /// This functions calls, when we need to show the video in portrait mode. This function rotates playerLayer and playAndPauseBtnOutlet 360 degree to set the video straight.
    func showVideoInPortrait() {
        if isRotate {
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
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
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
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
        playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(90))
        
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
            guard let avPlayer = self?.avPlayer else {return}
            let currentTime = Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer)
            
            self?.slider.setValue(Float(currentTime), animated: true)
        }
        
        if Float64(slider.maximumValue) == Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer) {
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
    
    /// Hides the buttons, stackView, slilder and activity Indicator of player
    func hidePlayerControllers() {
        activityIndicator.isHidden = true
        playAndPauseButtonOutlet.isHidden = true
        fullScreenButtonOutlet.isHidden = true
        speedStackView.isHidden = true
        slider.isHidden = true
        forwardSkipButtonOutlet.isHidden = true
        backwardSkipButtonOutlet.isHidden = true
        miniPlayerButtonOutlet.isHidden = true
    }
    
    /// Unhide the buttons, stackView, slilder and activity Indicator of player
    func unhidePlayerControllers() {
        //activityIndicator.isHidden = false
        playAndPauseButtonOutlet.isHidden = false
        fullScreenButtonOutlet.isHidden = false
        speedStackView.isHidden = false
        slider.isHidden = false
        forwardSkipButtonOutlet.isHidden = false
        backwardSkipButtonOutlet.isHidden = false
        miniPlayerButtonOutlet.isHidden = false
    }
    
    /// Hides the buttons of mini player
    func hideMiniPlayerButtons() {
        self.playAndPauseButtonForMiniPlayer.isHidden = true
        self.crossButton.isHidden = true
    }
    
    func unhideMiniPlayerButtons() {
        self.playAndPauseButtonForMiniPlayer.isHidden = false
        self.crossButton.isHidden = false
    }
    
    /// Convert play button to pause button and vice versa
    func togglePauseAndPlay(button: UIButton) {
        if !isPause {
            avPlayer.pause()
            button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else {
            avPlayer.play()
            button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        isPause = !isPause
    }
}
