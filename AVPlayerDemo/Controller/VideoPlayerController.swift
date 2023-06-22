//
//  VideoPlayerController.swift
//  AVPlayerDemo
//
//  Created by Mac on 1/6/23.
//

import UIKit
import AVKit

class VideoPlayerController: UIViewController {
    
    /// This is a UIView, where the video shows. The helps to set the position of PlayerLayer
    var playerView = UIView()
    
    /// This is a button, which can control exit/enter in full screen mode
    var fullScreenButton = UIButton()
    
    /// This is a button, which can control play and pause both
    var playAndPauseButton = UIButton()
    
    /// Slider to slide the video
    var slider = UISlider()
    
    /// Activity Indicator to show buffer
    var activityIndicator = UIActivityIndicatorView()
    
    /// To skip the video in forward
    var forwardSkipButton = UIButton()
    
    /// To skip the video in backward
    var backwardSkipButton = UIButton()
    
    /// Mini Player Button Outlet
    var miniPlayerButton = UIButton()
    
    /// Player Time/Duration Outlet
    var playerTime = UILabel()
    
    /// Player settings Outlet
    var settingButton = UIButton()
    
    /// Shows the total duration/time of the video
    var playerTotalDuration = UILabel()
    
    /// ProgressView for live
    var progressView = UIProgressView()
    
    /// Image of live red Circle
    var liveRedCircleImage = UIImageView()
    
    /// Label for live
    var liveLabel = UILabel()
    
    /// Stack of live label and red circle image
    var liveStack = UIStackView()
    
    
    /// Tracks whether the video in rotated or not
    var isRotate = false
    
    /// Tracks the orientation of device
    var isLandscape = false
    
    /// Tracks whether the video is paused or playing, because a single button is working for both pause and play
    var isPause = false
    
    /// Tracks whether mini player starts or not
    var isMinimize = false
    
    /// Tracks the buffer
    var isBuffering = false
    
    /// Origin of the mini player
    var minimizedOrigin: CGPoint {
        let x = 0.0
        let y = (UIScreen.main.bounds.height - (UIScreen.main.bounds.height/7 + 10))
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }
    
    /// Mini Player Buttons and UIView
    var crossButton = UIButton()
    var playAndPauseButtonForMiniPlayer = UIButton()
    var miniPlayerUIView = UIView()
    
    var playerLayer = AVPlayerLayer()
    var avPlayer: AVPlayer?
    
    var preview = SeekPreview()
    var images: [ Double : UIImage ] = [:]
    
    /// For hiding button after a certain time (5 seconds)
    var workItem: DispatchWorkItem?
    
    /// Timer for slider to move continuously
    var timer = Timer()
    
    /// Tracks whether live stream is on or off
    var isLiveStream = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Position of Components
        allComponentsOfPlayerView()
        
        // If app runs first time with landscape mode
        let orientation = Utils.shared.deviceOrientation()
        if orientation == Orientation.landscapeRight.rawValue || orientation == Orientation.landscapeLeft.rawValue {
            self.showVideoInLandscape()
            self.isRotate = true
            self.isLandscape = true
            self.miniPlayerButton.isHidden = true
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        
        // Hide the buttons of playerView
        hidePlayerControllers()
        
        // Create UiView
        miniPlayerUIView = Utils.shared.createUIView(view: self.view)
        
        // Create Play And Pause Button For MiniPlayer
        self.playAndPauseButtonForMiniPlayer = Utils.shared.createButton(
            tintColor: UIColor.black,
            title: "",
            imageName: "pause")
        
        // Create Cross Button For MiniPlayer
        self.crossButton = Utils.shared.createButton(
            tintColor: UIColor.black,
            title: "",
            imageName: "xmark")
        
        hidePlayerControllers()
        
        // Preview
        preview.delegate = self
        preview.borderColor = UIColor.black
        preview.borderWidth = 1
        preview.cornerRadius = 5
        
        // Touch Gesture
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.playerViewTouchGesture (_:)))
        playerView.addGestureRecognizer(gesture)
        
        // When app become active from background
        NotificationCenter.default.addObserver(self, selector: #selector(self.activeFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Observe if video is finished or not
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        
        // Play Video
        hidePlayerControllers()
        let url = Urls.m3u8Video1
        playVideo(url: url)
        
        // Navigation Controller Delegate
        navigationController?.delegate = self
        
    }
    
    
    /// Stop player while disappearing the viewController
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopPlayerAndPlayerObserver()
    }
    
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        
        avPlayer?.pause()
        avPlayer?.replaceCurrentItem(with: nil)
        timer.invalidate()
        avPlayer = nil
        
        let url = Urls.m3u8Video3
        playVideo(url: url)
        
    }
    
    
    /// Executes this function when app comes from background to foreground
    @objc func activeFromBackground() {
        
        playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        playAndPauseButtonForMiniPlayer.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        isPause = !isPause
        
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
            if orientation == Orientation.portrait.rawValue {
                self.showVideoInPortrait()
                self.isRotate = false
                self.isLandscape = false
                self.hideMiniPlayerButtons()
                self.hidePlayerControllers()
                self.miniPlayerUIView.isHidden = true
                self.navigationItem.setHidesBackButton(false, animated: false)
            }
            if orientation == Orientation.landscapeRight.rawValue || orientation == Orientation.landscapeLeft.rawValue {
                self.showVideoInLandscape()
                self.isRotate = true
                self.isLandscape = true
                self.miniPlayerButton.isHidden = true
                self.navigationItem.setHidesBackButton(true, animated: false)
            }
            
            if orientation == Orientation.upsideDown.rawValue {
                self.changeDeviceOrientation(to: .portrait)
                self.showVideoInPortrait()
                self.navigationItem.setHidesBackButton(false, animated: false)
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
                            self?.hideButtonsAfterCertainTime(seconds: 5)
                        }
                        self?.isBuffering = false
                    }
                    else {
                        self?.activityIndicator.startAnimating()
                        self?.activityIndicator.isHidden = false
                        self?.isBuffering = true
                    }
                }
            }
        }
    }
    
    
    @objc func closeMiniPlayer() {
        
        UIView.animate(withDuration: 0.3) {
            self.playerLayer.player?.pause()
            self.miniPlayerUIView.frame.origin.x = -self.view.bounds.width - 20
        } completion: { _ in
            self.miniPlayerUIView.isHidden = true
            self.avPlayer?.pause()
            self.playerLayer.removeFromSuperlayer()
            self.playerLayer.player = nil
        }
        
    }
    
    
    /// Touch Gesture Action
    @objc func playerViewTouchGesture(_ sender:UITapGestureRecognizer){
        
        // Expand Mini Player to actual player size
        UIView.animate(withDuration: 0.3, animations: {
            if self.isMinimize {
                self.view.backgroundColor = UIColor.white
                self.unhidePlayerControllers()
                self.hideMiniPlayerButtons()
                self.view.bounds = UIScreen.main.bounds
                self.view.frame.origin = CGPoint.init(x: 0, y: 0)
                self.showVideoInPortrait()
                self.miniPlayerUIView.isHidden = true
                self.isMinimize = false
            }
        })
        
        // Touch gesture to invisible the buttons after 5 seconds and visible when it touched
        unhidePlayerControllers() // Unhide buttons when playerView touched
        
        changeOpacityOfPlayerLayer(opacity: 0.5) // change opacity of payerLayer
        
        hideButtonsAfterCertainTime(seconds: 5) // Hide buttons after 5 seconds
        
    }
    
    
    @objc func pauseAndPlayMiniPlayerAction() {
        
        togglePauseAndPlay()
        
    }
    
    
    // MARK: - Plays the video from beginning
    /// This is a function to start a video for a specific url. Here configures the player and set the frame of playerLayer to an UIView (playerView)
    func playVideo(url: URL?) {
        
        // Remove playerLayer from its parent layer
        playerLayer.removeFromSuperlayer()
        playerLayer.player = nil
        
        // Initially the Pause button will be Visisble
        playAndPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        
        let url = url
        guard let url = url else {
            debugPrint("Video doesn't exist or format issue. Please make sure the correct name of the video and format.")
            return
        }
        
        avPlayer = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: avPlayer ?? AVPlayer())
        
        // Buffer
        avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        configureSlider(color: UIColor.red)
        //self.setupVideoTimeSlider()
        
        self.playerView.layer.addSublayer(playerLayer)
        
        // Set the frame of the player Layer according to the playerView bound
        playerLayer.frame = self.playerView.layer.bounds
        
        // Set the full Screen Button to playerView
        self.playerView.addSubview(fullScreenButton)
        
        // Set the play Button to playerView
        self.playerView.addSubview(playAndPauseButton)
        
        // Set the slider to playerView
        self.playerView.addSubview(slider)
        
        // Set the activity indicator to playerView
        self.playerView.addSubview(activityIndicator)
        
        // Set the forwardSkipButtonOutlet to playerView
        self.playerView.addSubview(forwardSkipButton)
        
        // Set the backwardSkipButtonOutlet to playerView
        self.playerView.addSubview(backwardSkipButton)
        
        // Set the mini player outlet to playerView
        self.playerView.addSubview(miniPlayerButton)
        
        // Set the preview to playerView
        self.playerView.addSubview(preview)
        
        // Set the player time to playerView
        self.playerView.addSubview(playerTime)
        
        // Set the player total time/duration to playerView
        self.playerView.addSubview(playerTotalDuration)
        
        // Set the settings to playerView
        self.playerView.addSubview(settingButton)
        
        // Set the live stack (live label and red circle image) to playerView
        self.playerView.addSubview(liveStack)
        
        // Set the progressView to playerView
        self.playerView.addSubview(progressView)
        
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.bottomAnchor.constraint(equalTo: self.slider.topAnchor).isActive = true
        preview.heightAnchor.constraint(equalToConstant: 40).isActive = true
        preview.attachToSlider(slider: slider)
        generateImages()
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        if isLandscape {
            showVideoInLandscape()
        }
        else {
            showVideoInPortrait()
        }
        
        // Play the video
        avPlayer?.play()
    }
    
    
    // MARK: - Function to show the video in portrait mode
    /// This functions calls, when we need to show the video in portrait mode. This function rotates playerLayer and playAndPauseBtnOutlet 360 degree to set the video straight.
    func showVideoInPortrait() {
        
        fullScreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        
        if isRotate {
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
        }
        
        playerView.isHidden = false
        setPositionPlayerView()
        
        playerLayer.frame = playerView.bounds
        
    }
    
    
    // MARK: - Function to show the video in landscape mode
    /// This function calls when the device is in landscape mode. It hides all the button and UIView and set the playerViewframe to the main view (To cover entire screen).
    func showVideoInLandscape() {
        
        fullScreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        
        if isRotate {
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
        }
        
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        self.playerView.frame = self.view.bounds
        self.playerLayer.frame = self.playerView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
    }
    
    
    // MARK: - Function for entering in full screen
    /// This function works when we click the full screen button to enter in full screen mode. It rotates playerView and set the playerView frame to the main view.
    func enterFullScreen() {
        
        changeDeviceOrientation(to: .landscapeLeft)
        showVideoInLandscape()
        self.isRotate = true
        
    }
    
    
    // MARK: - Function for exiting full screen
    /// This function calls when we are in portrait mode.
    func ExitFullScreen() {
        
        if isLandscape {
            changeDeviceOrientation(to: .portrait)
        }
        
        showVideoInPortrait()
        self.isRotate = false
        
    }
    
    
    // MARK: - Configure the Slider
    /// Did all the tasks of slider here
    func configureSlider(color: UIColor) {
        
        slider.tintColor = color
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let currentItem = self?.avPlayer?.currentItem else {return}
            if self?.avPlayer?.currentItem!.status == .readyToPlay {
                self?.slider.minimumValue = 0
                self?.slider.maximumValue = Float(currentItem.duration.seconds)
                
                if self?.isBuffering == false {
                    self?.slider.setValue(Float(time.seconds), animated: true)
                    self?.playerTime.text = time.durationText
                    self?.setPlayerTime()
                }
            }
        }
        
        slider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        
    }
    
    
    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        
        let seconds: Int64 = Int64(playbackSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer?.seek(to: targetTime)
        
        setPlayerTime()
        
    }
    
    
    // MARK: - Hide Player Controllers
    /// Hides the buttons, stackView, slilder and activity Indicator of player
    func hidePlayerControllers() {
        
        activityIndicator.isHidden = true
        playAndPauseButton.isHidden = true
        fullScreenButton.isHidden = true
        progressView.isHidden = true
        liveLabel.isHidden = true
        liveRedCircleImage.isHidden = true
        slider.isHidden = true
        forwardSkipButton.isHidden = true
        backwardSkipButton.isHidden = true
        miniPlayerButton.isHidden = true
        playerTime.isHidden = true
        playerTotalDuration.isHidden = true
        settingButton.isHidden = true
        preview.alpha = 0
        
        changeOpacityOfPlayerLayer(opacity: 1.0) // change opacitiy of player
        
    }
    
    
    // MARK: - Unhide Player Controllers
    /// Unhide the buttons, stackView, slilder and activity Indicator of player
    func unhidePlayerControllers() {
        
        playAndPauseButton.isHidden = false
        fullScreenButton.isHidden = false
        
        if isLiveStream {
            progressView.isHidden = false
            playerTotalDuration.isHidden = true
            playerTime.isHidden = true
            forwardSkipButton.isHidden = true
            backwardSkipButton.isHidden = true
            
            liveLabel.isHidden = false
            liveRedCircleImage.isHidden = false
            
            UIView.animate(withDuration: 0.7, delay: 0.7, options: [.repeat, .autoreverse]) {
                self.liveRedCircleImage.layer.opacity = 0.0
            }
            
            timer.invalidate()
        }
        else {
            slider.isHidden = false
            playerTime.isHidden = false
            playerTotalDuration.isHidden = false
            forwardSkipButton.isHidden = false
            backwardSkipButton.isHidden = false
            
            liveLabel.isHidden = true
            liveRedCircleImage.isHidden = true
        }
        
        if isLandscape || isRotate {
            miniPlayerButton.isHidden = true
        }
        else {
            miniPlayerButton.isHidden = false
        }
        
        settingButton.isHidden = false
        preview.alpha = 1
        
        changeOpacityOfPlayerLayer(opacity: 0.5) // change opacitiy of player
        
    }
    
    
    // MARK: - Hide mini player buttons
    /// Hides the buttons of mini player
    func hideMiniPlayerButtons() {
        
        self.playAndPauseButtonForMiniPlayer.isHidden = true
        self.crossButton.isHidden = true
        
    }
    
    
    // MARK: - Unhide mini player buttons
    /// Unhide Mini Player Buttons
    func unhideMiniPlayerButtons() {
        
        self.playAndPauseButtonForMiniPlayer.isHidden = false
        self.crossButton.isHidden = false
        
    }
    
    
    // MARK: - Toggle Pause and Play Button
    /// Convert play button to pause button and vice versa
    func togglePauseAndPlay() {
        
        if !isPause {
            avPlayer?.pause()
            
            playAndPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAndPauseButtonForMiniPlayer.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else {
            avPlayer?.play()
            
            playAndPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playAndPauseButtonForMiniPlayer.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        
        isPause = !isPause
        
    }
    
    
    /// Hide buttons after 5 seconds and visible those again after touching the playerView
    /// - Parameter seconds: task will axecute after this time (seconds)
    func hideButtonsAfterCertainTime(seconds: Int) {
        
        workItem?.cancel()
        
        workItem = DispatchWorkItem {
            self.hidePlayerControllers()
            self.changeOpacityOfPlayerLayer(opacity: 1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: workItem!)
        
    }
    
    
    /// This function change the current orientation of device
    /// - Parameter orientation: desired orientation
    func changeDeviceOrientation(to orientation: UIDeviceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    
    /// This function sets the duration of the video (slider value) to playerTime label
    func setPlayerTime() {
        let sliderValue = slider.value
        let time = Utils.shared.secondsToHoursMinutesSeconds(Int(sliderValue))
        
        // Player total duration
        let duration = self.avPlayer?.currentItem?.asset.duration
        
        guard let duration = duration else {
            return
        }
        
        let durationInSeconds : Float64 = CMTimeGetSeconds(duration)
        
        let playerTotalTimeInString = Utils.shared.secondsToHoursMinutesSeconds(Int(durationInSeconds))
        
        playerTime.text = time
        playerTotalDuration.text = " /  \(playerTotalTimeInString)"
        
    }
    
    func changeOpacityOfPlayerLayer(opacity: Float) {
        
        let desiredOpacity: Float = opacity
        
        playerLayer.opacity = desiredOpacity
    }
    
    
    /// This function needs to present the action sheet for iPad
    /// - Parameter sheet: Takes the sheet as parameter
    func iPadActionSheet(sheet: UIAlertController) {
        
        sheet.popoverPresentationController?.sourceView = self.view
        sheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        sheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
    }
    
    
    func stopPlayerAndPlayerObserver() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)

        avPlayer?.pause()
        avPlayer = nil
        avPlayer?.replaceCurrentItem(with: nil)

        playerLayer.removeFromSuperlayer()
        playerLayer.player = nil

        avPlayer?.currentItem?.cancelPendingSeeks()
        avPlayer?.currentItem?.asset.cancelLoading()
        
    }
    
}


extension VideoPlayerController: SeekPreviewDelegate {
    
    
    /// Function of SeekPreviewDelegate
    func getSeekPreview(value: Float) -> UIImage? {
        
        guard let asset = avPlayer?.currentItem?.asset else {return nil}

        let times = images.keys
        if times.count == 0 {
            return nil
        }
        
        let seconds = Double(value) * asset.duration.seconds
        let closest = times.enumerated().min( by: { abs($0.1 - seconds) < abs($1.1 - seconds) } )!
        let image = images[closest.element]
        
        return image
        
    }
    
    
    /// Generate images according to time
    func generateImages() {
        self.images = [:]
        guard let asset = avPlayer?.currentItem?.asset else {
            return
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.maximumSize = CGSize(width: 150, height: 80)
        let seconds = asset.duration.seconds
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: Array(1...99).map{ NSValue(time:CMTimeMake(value: $0 * Int64(seconds), timescale: 100))  }) { (requestedTime, cgImage, actualTime, result, error) in
            if let image = cgImage {
                DispatchQueue.main.async {
                    self.images[actualTime.seconds] = UIImage(cgImage: image)
                }
            }
        }
    }
    
    
    // MARK: - Configure the Slider
    /// Did all the tasks of slider here
    /// This function is a redeclaration of configureSlider. Here the task has been done with Timer.
/*
    func configureSlider(color: UIColor) {

        slider.tintColor = color
        slider.minimumValue = 0
        let duration = self.avPlayer.currentItem?.asset.duration

        guard let duration = duration else {
            return
        }

        let seconds : Float64 = CMTimeGetSeconds(duration)

        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        slider.isUserInteractionEnabled = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in

            guard let avPlayer = self?.avPlayer else {
                return
            }

            let currentTime = Utils.shared.getCurrentTimeOfVideo(avPlayer: avPlayer)

            if self?.isBuffering == false {

                // Sets the value of slider to playerTime label
                self?.setPlayerTime()

                self?.slider.setValue(Float(currentTime), animated: true)
            }
        }

        slider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)

    }
 
 */
    
 
/*
    // MARK: - Function for entering in full screen
    /// This function works when we click the full screen button to enter in full screen mode. It rotates playerView and set the playerView frame to the main view.
    func enterFullScreen() {
        
        if self.isLandscape == true {
            //Rotate the playerView to 360 Degree
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
        }
        else {
            //Rotate the playerView to 90 Degree
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(90))
        }

        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        self.playerView.frame = self.view.bounds
        self.playerLayer.frame = self.playerView.bounds

        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect

        self.isRotate = true
    }
*/
    
    
/*
    ///  Commented out this code for future if needed
     func showVideoInPortrait() {
     
     if isRotate {
     playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
     }
     
     playerView.isHidden = false
     
     let width = view.bounds.width - 20
     let height = playerViewHeight
     self.view.addSubview(self.playerView)
     
     playerView.translatesAutoresizingMaskIntoConstraints = false
     playerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
     
     playerView.bounds.size.height = height ?? 0.0
     playerView.bounds.size.width = width
     playerLayer.frame = playerView.bounds
     
     }
*/
    
}


//extension VideoPlayerController: UINavigationControllerDelegate {
//
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        if let previousViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
//           !navigationController.viewControllers.contains(previousViewController) {
//            // The previous view controller is not in the navigation stack anymore.
//            // You can perform any cleanup or deallocation tasks here.
//
//            avPlayer?.pause()
//            avPlayer?.replaceCurrentItem(with: nil)
//
//            // For example, you could call a deinitializer or release resources.
//            previousViewController.removeFromParent()
//            debugPrint("Go Back To Home")
//        }
//    }
//
//}


extension VideoPlayerController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let previousViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
           !navigationController.viewControllers.contains(previousViewController) {
            // The previous view controller is not in the navigation stack anymore.
            // You can perform any cleanup or deallocation tasks here.
            
            stopPlayerAndPlayerObserver()

            // For example, you could call a deinitializer or release resources.
            previousViewController.removeFromParent()
            debugPrint("Go Back To Home")
            
        }
    }
    
}


/// Extension for set the positions of components of playerView
extension VideoPlayerController {
    
    func setPositionPlayAndPauseButton() {
        
        playAndPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playAndPauseButton.tintColor = UIColor.white
        
        playAndPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        playAndPauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playAndPauseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerView.addSubview(playAndPauseButton)
        
        let centerXConstraint = playAndPauseButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor)
        let centerYConstraint = playAndPauseButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        
        playAndPauseButton.addTarget(self, action: #selector(playAndPauseVideo), for: .touchUpInside)
        
    }
    
    
    func setPositionForwardSkipButton() {
        
        forwardSkipButton.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        forwardSkipButton.tintColor = UIColor.white
        
        forwardSkipButton.translatesAutoresizingMaskIntoConstraints = false
        
        forwardSkipButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        forwardSkipButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerView.addSubview(forwardSkipButton)
        
        let centerYConstraint = forwardSkipButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        let leadingConstraint = forwardSkipButton.leadingAnchor.constraint(equalTo: playAndPauseButton.trailingAnchor, constant: 40)
        
        NSLayoutConstraint.activate([centerYConstraint, leadingConstraint])
        
        forwardSkipButton.addTarget(self, action: #selector(skipVideoInForward), for: .touchUpInside)
    }
    
    
    func setPositionBackwardSkipButton() {
        
        backwardSkipButton.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        backwardSkipButton.tintColor = UIColor.white
        
        backwardSkipButton.translatesAutoresizingMaskIntoConstraints = false
        
        backwardSkipButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backwardSkipButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerView.addSubview(backwardSkipButton)
        
        let centerYConstraint = backwardSkipButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        let trailingConstraint = backwardSkipButton.trailingAnchor.constraint(equalTo: playAndPauseButton.leadingAnchor, constant: -40)
        
        NSLayoutConstraint.activate([centerYConstraint, trailingConstraint])
        
        backwardSkipButton.addTarget(self, action: #selector(skipVideoInBackward), for: .touchUpInside)
    }
    
    
    func setPositionActivityIndicator(color: UIColor) {
        
        activityIndicator.color = color
        activityIndicator.style = .large
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.addSubview(activityIndicator)
        
        let centerXConstraint = activityIndicator.centerXAnchor.constraint(equalTo: playerView.centerXAnchor)
        let centerYConstraint = activityIndicator.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        
    }
    
    func setPositionMiniPlayerButtonOutlet() {
        
        miniPlayerButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        miniPlayerButton.tintColor = UIColor.white
        
        miniPlayerButton.translatesAutoresizingMaskIntoConstraints = false
        
        miniPlayerButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        miniPlayerButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerView.addSubview(miniPlayerButton)
        
        let topConstraint = miniPlayerButton.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 15)
        
        let leadingConstraint = miniPlayerButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 15)
        
        NSLayoutConstraint.activate([topConstraint, leadingConstraint])
        
        miniPlayerButton.addTarget(self, action: #selector(startMiniPlayer), for: .touchUpInside)
        
    }
    
    
    func setPositionSettingButtonOutlet() {
        
        settingButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        settingButton.tintColor = UIColor.white
        
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        
        settingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        settingButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerView.addSubview(settingButton)
        
        let topConstraint = settingButton.topAnchor.constraint(equalTo: playerView.topAnchor, constant: 15)
        
        let trailingConstraint = settingButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -15)
        
        NSLayoutConstraint.activate([topConstraint, trailingConstraint])
        
        settingButton.addTarget(self, action: #selector(settingsToShowActionSheet), for: .touchUpInside)
        
    }
    
    
    func setPositionFullScreenButtonOutlet() {
        
        fullScreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        
        fullScreenButton.tintColor = UIColor.red
        
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        
        fullScreenButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        fullScreenButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerView.addSubview(fullScreenButton)
        
        if isLiveStream {
            fullScreenButton.bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: -15).isActive = true
        }
        else {
            fullScreenButton.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -15).isActive = true
        }
        
        fullScreenButton.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -15).isActive = true
        
        fullScreenButton.addTarget(self, action: #selector(makeVideoFullScreen), for: .touchUpInside)
        
    }
    
    
    func setPositionSlider(minimumTrackTintColor: UIColor, maximumTrackTintColor: UIColor, thumbTintColor: UIColor) {
        
        slider.maximumTrackTintColor = maximumTrackTintColor
        slider.minimumTrackTintColor = minimumTrackTintColor
        slider.thumbTintColor = thumbTintColor
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.addSubview(slider)
        
        let bottomConstraint = slider.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -15)
        
        let trailingConstraint = slider.trailingAnchor.constraint(equalTo: fullScreenButton.leadingAnchor, constant: -10)
        
        let leadingConstraint = slider.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([bottomConstraint, trailingConstraint, leadingConstraint])
        
    }
    
    
    func setPositionPlayerTime() {
        
        playerTime.textColor = UIColor.white
        playerTime.font = UIFont.boldSystemFont(ofSize: 14)
        
        playerTime.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.addSubview(playerTime)
        
        let bottomConstraint = playerTime.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -4)
        
        //let trailingConstraint = playerTime.trailingAnchor.constraint(equalTo: fullScreenButtonOutlet.leadingAnchor, constant: 10)
        
        let leadingConstraint = playerTime.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([bottomConstraint, leadingConstraint])
        
    }
    
    
    func setPositionPlayerTotalDuration() {
        
        playerTotalDuration.textColor = UIColor.white
        playerTotalDuration.font = UIFont.boldSystemFont(ofSize: 14)
        
        playerTotalDuration.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.addSubview(playerTotalDuration)
        
        let bottomConstraint = playerTotalDuration.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -4)
        
        let leadingConstraint = playerTotalDuration.leadingAnchor.constraint(equalTo: playerTime.trailingAnchor, constant: 4)
        
        NSLayoutConstraint.activate([bottomConstraint, leadingConstraint])
        
    }
    
    
    func setPositionProgressView() {
        
        progressView.tintColor = UIColor.red
        
        progressView.progress = 1.0
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.addSubview(progressView)
        
        let bottomConstraint = progressView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor, constant: -15)
        
        let leadingConstraint = progressView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 0)
        
        let trailingConstraint = progressView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: 0)
        
        NSLayoutConstraint.activate([bottomConstraint, leadingConstraint, trailingConstraint])
        
    }
    
    
    func setPositionLiveStack() {
        
        liveLabel.text = "Live"
        liveLabel.textColor = UIColor.red
        
        liveRedCircleImage.image = UIImage(systemName: "circle.fill")
        liveRedCircleImage.tintColor = UIColor.red
        
        liveStack.addArrangedSubview(liveRedCircleImage)
        liveStack.addArrangedSubview(liveLabel)
        
        liveStack.translatesAutoresizingMaskIntoConstraints = false
        
        playerView.addSubview(liveStack)
        
        let bottomConstraint = liveStack.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -10)
        
        let leadingConstraint = liveStack.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 15)
        
        NSLayoutConstraint.activate([bottomConstraint, leadingConstraint])
        
    }
    
    
    func setPositionPlayerView() {
        
        playerView.backgroundColor = UIColor.black
        
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        
        if let topLayoutGuideHeight = navigationController?.navigationBar.frame.maxY {
            let y = topLayoutGuideHeight + 10
            playerView.frame = CGRect(x: 10, y: y, width: view.bounds.width - 20, height: view.bounds.height/3 - 20)
        }
        
    }
    
    
    // MARK: - Set icons of playAndPauseBtnOutlet
    /// This is a button to pause and play video. This can toggle from pause to play and vice versa
    @objc func playAndPauseVideo() {
        
        togglePauseAndPlay()
    }
    
    
    // MARK: - Forward Skip
    @objc func skipVideoInForward() {
        
        //skipTimeForward(seconds: 10)
        AVPlayerManager.shared.skipTimeForward(seconds: 10, avPlayer: avPlayer ?? AVPlayer())
        setPlayerTime()
        
    }
    
    
    // MARK: - Backward Skip
    @objc func skipVideoInBackward() {
        
        //skipTimeBackward(seconds: 10)
        AVPlayerManager.shared.skipTimeBackward(seconds: 10, avPlayer: avPlayer ?? AVPlayer())
        setPlayerTime()
        
    }
    
    
    // MARK: - Mini Player Button
    @objc func startMiniPlayer() {
        
        UIView.animate(withDuration: 0.3 , animations: {
            if self.isMinimize == false {
                self.hidePlayerControllers()
                self.unhideMiniPlayerButtons()
                self.miniPlayerUIView.isHidden = false
                
                (self.crossButton, self.playAndPauseButtonForMiniPlayer) = AVPlayerManager.shared.configureMiniPlayer(
                    view: self.miniPlayerUIView,
                    playerView: self.playerView,
                    playerLayer: self.playerLayer,
                    crossButton: self.crossButton,
                    playAndPauseButtonForMiniPlayer: self.playAndPauseButtonForMiniPlayer,
                    minimizedOrigin: self.minimizedOrigin,
                    buttonWidth: Int(self.playAndPauseButton.bounds.width),
                    buttonHeight: Int(self.playAndPauseButton.bounds.height)
                )
                
                self.crossButton.addTarget(self, action:#selector(self.closeMiniPlayer), for: .touchUpInside)
                
                self.playAndPauseButtonForMiniPlayer.addTarget(self, action:#selector(self.pauseAndPlayMiniPlayerAction), for: .touchUpInside)
                
                self.isMinimize = true
            }
        })
        
    }
    
    
    // MARK: - Settings button to open Action Sheet
    @objc func settingsToShowActionSheet() {
        
        let alert = UIAlertController(title: "Settings", message: "Select any", preferredStyle: .actionSheet)
        
        if !isLiveStream {
            alert.addAction(UIAlertAction(title: "Speed", style: .default , handler:{ _ in
                let speedAlert = ActionSheet.shared.speedActionSheet(avPlayer: self.avPlayer ?? AVPlayer())
                
                //for iPad Support
                self.iPadActionSheet(sheet: speedAlert)
                
                self.present(speedAlert, animated: true, completion: {
                    
                })
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Quality", style: .default , handler:{ (UIAlertAction)in
            
            let qualityAlert = ActionSheet.shared.qualityActionSheet(avPlayer: self.avPlayer ??  AVPlayer())
            
            //for iPad Support
            self.iPadActionSheet(sheet: qualityAlert)
            
            self.present(qualityAlert, animated: true, completion: {
                
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Share", style: .default , handler:{ (UIAlertAction)in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Report", style: .destructive , handler:{ (UIAlertAction)in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        //for iPad Support
        iPadActionSheet(sheet: alert)
        
        self.present(alert, animated: true, completion: {
            
        })
        
    }
    
    
    // MARK: - Take the video in full screen mode
    /// This is a button and used to enter and exit full screen mode
    @objc func makeVideoFullScreen(_ sender: Any) {
        
        if self.isRotate == false {
            enterFullScreen()
            fullScreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
            self.miniPlayerButton.isHidden = true
            self.hideMiniPlayerButtons()
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else {
            ExitFullScreen()
            fullScreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
            self.miniPlayerButton.isHidden = false
            self.navigationItem.setHidesBackButton(false, animated: false)
        }
        
    }
    
    
    func allComponentsOfPlayerView() {
        
        setPositionPlayerView()
        setPositionPlayAndPauseButton()
        setPositionForwardSkipButton()
        setPositionBackwardSkipButton()
        setPositionActivityIndicator(color: UIColor.red)
        setPositionMiniPlayerButtonOutlet()
        setPositionSettingButtonOutlet()
        setPositionProgressView()
        setPositionFullScreenButtonOutlet()
        setPositionSlider(
            minimumTrackTintColor: UIColor.red,
            maximumTrackTintColor: UIColor.systemGray,
            thumbTintColor: UIColor.red
        )
        setPositionPlayerTime()
        setPositionPlayerTotalDuration()
        setPositionLiveStack()
        
    }

}
