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
    /// Player Time/Duration Outlet
    @IBOutlet weak var playerTime: UILabel!
    /// Player settings Outlet
    @IBOutlet weak var settingButtonOutlet: UIButton!
    /// Shows the total duration/time of the video
    @IBOutlet weak var playerTotalDuration: UILabel!
    /// ProgressView for live
    @IBOutlet weak var progressView: UIProgressView!
    /// Image of live red Circle
    @IBOutlet weak var liveRedCircleImage: UIImageView!
    /// Label for live
    @IBOutlet weak var liveLabel: UILabel!
    /// Stack of live label and red circle image
    @IBOutlet weak var liveStack: UIStackView!
    
    
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
    var minimizedOrigin: CGPoint?
    
    var crossButton = UIButton()
    var playAndPauseButtonForMiniPlayer = UIButton()

    var playerLayer = AVPlayerLayer()
    var avPlayer = AVPlayer()
    
    let preview = SeekPreview()
    var images: [ Double : UIImage ] = [:]
    
    /// For hiding button after a certain time (5 seconds)
    var workItem: DispatchWorkItem?
    
    /// Timer for slider to move continuously
    var timer = Timer()
    
    /// To store the height of playerView as it change it's height for different orientation of device
    var playerViewHeight: CGFloat?
    
    /// Tracks whether live stream is on or off
    var isLiveStream = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewHeight = playerView.bounds.height
        
        // Hide the buttons of playerView
        hidePlayerControllers()
        
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
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        
        let url = Urls.BigBuckBunny
        playVideo(url: url)
        
        timer.invalidate()
    }
    
    
    /// Executes this function when app comes from background to foreground
    @objc func activeFromBackground() {

        playAndPauseButtonOutlet.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
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
                print("portrait")
                self.showVideoInPortrait()
                self.isRotate = false
                self.isLandscape = false
                self.hideMiniPlayerButtons()
                self.hidePlayerControllers()
            }
            if orientation == Orientation.landscapeRight.rawValue || orientation == Orientation.landscapeLeft.rawValue {
                print("landscape")
                self.showVideoInLandscape()
                self.isRotate = true
                self.isLandscape = true
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

    
    // MARK: - Starts the video from beginning
    /// This is a button to start a video. Here configures the player and set the frame of playerLayer to an UIView (playerView)
    @IBAction func startVideo(_ sender: Any) {
        hidePlayerControllers()
        let url = Urls.m3u8Video1
        playVideo(url: url)
        
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
        
        togglePauseAndPlay()
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
                    buttonWidth: Int(self.playAndPauseButtonOutlet.bounds.width),
                    buttonHeight: Int(self.playAndPauseButtonOutlet.bounds.height)
                )
                
                self.crossButton.addTarget(self, action:#selector(self.closeMiniPlayer), for: .touchUpInside)
                
                self.playAndPauseButtonForMiniPlayer.addTarget(self, action:#selector(self.pauseAndPlayMiniPlayerAction), for: .touchUpInside)
                
                self.isMinimize = true
            }
        })
        
    }
    
    
    // MARK: - Settings button to open Action Sheet
    @IBAction func SettingsToShowActionSheet(_ sender: Any) {
        
        let alert = UIAlertController(title: "Settings", message: "Select any", preferredStyle: .actionSheet)
        
        if !isLiveStream {
            alert.addAction(UIAlertAction(title: "Video Speed", style: .default , handler:{ _ in
                let speedAlert = ActionSheet.shared.speedActionSheet(avPlayer: self.avPlayer)
                
                self.present(speedAlert, animated: true, completion: {
                    print("completion block")
                })
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Video Quality", style: .default , handler:{ (UIAlertAction)in
            
            let qualityAlert = ActionSheet.shared.qualityActionSheet(avPlayer: self.avPlayer)
            
            self.present(qualityAlert, animated: true, completion: {
                print("completion block")
            })
        }))

        alert.addAction(UIAlertAction(title: "Report", style: .destructive , handler:{ (UIAlertAction)in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    @objc func closeMiniPlayer() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.playerLayer.player?.pause()
            self.view.frame.origin.x = -self.view.bounds.width - 20
        })
        
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
        playAndPauseButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)

        let url = url
        guard let url = url else {
            print("Video doesn't exist or format issue. Please make sure the correct name of the video and format.")
            return
        }
        
        avPlayer = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: avPlayer)
        
        // Buffer
        avPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        configureSlider(color: UIColor.red)
        
        self.playerView.layer.addSublayer(playerLayer)
        
        // Set the frame of the player Layer according to the playerView bound
        playerLayer.frame = self.playerView.layer.bounds
        
        // Set the full Screen Button to playerView
        self.playerView.addSubview(fullScreenButtonOutlet)
        
        // Set the play Button to playerView
        self.playerView.addSubview(playAndPauseButtonOutlet)
        
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
        
        // Set the preview to playerView
        self.playerView.addSubview(preview)
        
        // Set the player time to playerView
        self.playerView.addSubview(playerTime)
        
        // Set the player total time/duration to playerView
        self.playerView.addSubview(playerTotalDuration)
        
        // Set the settings to playerView
        self.playerView.addSubview(settingButtonOutlet)
        
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
        
        // Play the video
        avPlayer.play()
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
//        let height = view.bounds.height/2 - 70
        let height = playerViewHeight
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        playerView.frame = CGRect(x: 5, y: 60, width: width, height: height ?? 0.0)
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
    
    
    // MARK: - Function for entering in full screen
    /// This function works when we click the full screen button to enter in full screen mode. It rotates playerView and set the playerView frame to the main view.
    func enterFullScreen() {
        
        if self.isLandscape == true {
            print("isRotate")
            //Rotate the playerView to 360 Degree
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(360))
        }
        else {
            print("Not isRotate")
            //Rotate the playerView to 90 Degree
            playerView.transform = CGAffineTransform(rotationAngle: Utils.shared.degreeToRadian(90))
        }
        
        startButtonOutlet.isHidden = true
        
        self.view.addSubview(self.playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = true
        self.playerView.frame = self.view.bounds
        self.playerLayer.frame = self.playerView.bounds
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
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
        
        slider.minimumValue = 0
        let duration = self.avPlayer.currentItem?.asset.duration
        
        guard let duration = duration else {
            return
        }
        
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
        slider.tintColor = color
        
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
    
    
    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        
        let seconds: Int64 = Int64(playbackSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer.seek(to: targetTime)
        
        // Sets the value of slider to playerTime label
        setPlayerTime()
        
    }
    
    
    // MARK: - Hide Player Controllers
    /// Hides the buttons, stackView, slilder and activity Indicator of player
    func hidePlayerControllers() {
        
        activityIndicator.isHidden = true
        playAndPauseButtonOutlet.isHidden = true
        fullScreenButtonOutlet.isHidden = true
        progressView.isHidden = true
        liveLabel.isHidden = true
        liveRedCircleImage.isHidden = true
        slider.isHidden = true
        forwardSkipButtonOutlet.isHidden = true
        backwardSkipButtonOutlet.isHidden = true
        miniPlayerButtonOutlet.isHidden = true
        playerTime.isHidden = true
        playerTotalDuration.isHidden = true
        settingButtonOutlet.isHidden = true
        preview.alpha = 0
        
        changeOpacityOfPlayerLayer(opacity: 1.0) // change opacitiy of player
        
    }
    
    
    // MARK: - Unhide Player Controllers
    /// Unhide the buttons, stackView, slilder and activity Indicator of player
    func unhidePlayerControllers() {
        
        playAndPauseButtonOutlet.isHidden = false
        fullScreenButtonOutlet.isHidden = false
        
        if isLiveStream {
            progressView.isHidden = false
            playerTotalDuration.isHidden = true
            playerTime.isHidden = true
            
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
            
            liveLabel.isHidden = true
            liveRedCircleImage.isHidden = true
        }
        
        forwardSkipButtonOutlet.isHidden = false
        backwardSkipButtonOutlet.isHidden = false
        
        if isLandscape || isRotate {
            miniPlayerButtonOutlet.isHidden = true
        }
        else {
            miniPlayerButtonOutlet.isHidden = false
        }

        settingButtonOutlet.isHidden = false
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
            avPlayer.pause()
            
            playAndPauseButtonOutlet.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAndPauseButtonForMiniPlayer.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else {
            avPlayer.play()
            
            playAndPauseButtonOutlet.setImage(UIImage(systemName: "pause.fill"), for: .normal)
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
        let duration = self.avPlayer.currentItem?.asset.duration
        
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

    
}


extension VideoPlayerController: SeekPreviewDelegate {
    
    
    /// Function of SeekPreviewDelegate
    func getSeekPreview(value: Float) -> UIImage? {
        
        guard let asset = avPlayer.currentItem?.asset else {return nil}
        
        print("Image: ", self.images)
        
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
        
        guard let asset = avPlayer.currentItem?.asset else {
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
    
    
}
