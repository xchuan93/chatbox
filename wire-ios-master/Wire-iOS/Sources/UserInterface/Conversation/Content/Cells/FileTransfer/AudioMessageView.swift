//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import Cartography
import CocoaLumberjackSwift
import Classy

final class AudioMessageView: UIView, TransferView {
    public var fileMessage: ZMConversationMessage?
    weak public var delegate: TransferViewDelegate?
    private var _audioTrackPlayer: AudioTrackPlayer?
    public var audioTrackPlayer: AudioTrackPlayer? {
        get {
            if _audioTrackPlayer == nil {
                _audioTrackPlayer = AppDelegate.shared().mediaPlaybackManager?.audioTrackPlayer
                
                setupAudioPlayerObservers()
            }
            return _audioTrackPlayer
        }
        set(newValue) {
            _audioTrackPlayer = newValue
            setupAudioPlayerObservers()
        }
    }
    
    private let downloadProgressView = CircularProgressView()
    private let playButton = IconButton()
    private let timeLabel = UILabel()
    private let playerProgressView = ProgressView()
    private let waveformProgressView = WaveformProgressView()
    private let loadingView = ThreeDotsLoadingView()
    
    private var audioPlayerProgressObserver: NSObject? = .none
    private var audioPlayerStateObserver: NSObject? = .none
    private var allViews : [UIView] = []
    
    private var expectingDownload: Bool = false
    
    private var proximityMonitorManager: ProximityMonitorManager? {
        return ZClientViewController.shared()?.proximityMonitorManager
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        self.playButton.addTarget(self, action: #selector(AudioMessageView.onActionButtonPressed(_:)), for: .touchUpInside)
        self.playButton.accessibilityLabel = "AudioActionButton"
        self.playButton.layer.masksToBounds = true
        
        self.downloadProgressView.isUserInteractionEnabled = false
        self.downloadProgressView.accessibilityLabel = "AudioProgressView"
        
        self.timeLabel.numberOfLines = 1
        self.timeLabel.textAlignment = .center
        self.timeLabel.accessibilityLabel = "AudioTimeLabel"
        
        self.playerProgressView.setDeterministic(true, animated: false)
        self.playerProgressView.accessibilityLabel = "PlayerProgressView"
        
        self.loadingView.isHidden = true
        
        self.allViews = [self.playButton, self.timeLabel, self.downloadProgressView, self.playerProgressView, self.waveformProgressView, self.loadingView]
        self.allViews.forEach(self.addSubview)
        
        CASStyler.default().styleItem(self)
        self.timeLabel.font = self.timeLabel.font.monospaced()
        
        self.createConstraints()
        
        var currentElements = self.accessibilityElements ?? []
        currentElements.append(contentsOf: [playButton, timeLabel])
        self.accessibilityElements = currentElements
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    deinit {
        audioPlayerStateObserver = nil
        audioPlayerProgressObserver = nil
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 56)
    }
    
    private func createConstraints() {
        constrain(self, self.playButton, self.timeLabel) { selfView, playButton, timeLabel in
            selfView.height == 56
            
            playButton.left == selfView.left + 12
            playButton.centerY == selfView.centerY
            playButton.width == 32
            playButton.height == playButton.width
            
            timeLabel.left == playButton.right + 12
            timeLabel.centerY == selfView.centerY
            timeLabel.width >= 32
        }
        
        constrain(self.downloadProgressView, self.playButton) { downloadProgressView, playButton in
            downloadProgressView.center == playButton.center
            downloadProgressView.width == playButton.width - 2
            downloadProgressView.height == playButton.height - 2
        }
        
        constrain(self, self.playerProgressView, self.timeLabel, self.waveformProgressView, self.loadingView) { selfView, playerProgressView, timeLabel, waveformProgressView, loadingView in
            playerProgressView.centerY == selfView.centerY
            playerProgressView.left == timeLabel.right + 12
            playerProgressView.right == selfView.right - 12
            playerProgressView.height == 1
            
            waveformProgressView.centerY == selfView.centerY
            waveformProgressView.left == playerProgressView.left
            waveformProgressView.right == playerProgressView.right
            waveformProgressView.height == 32
            
            loadingView.center == selfView.center
        }
        
    }
    
    override open var tintColor: UIColor! {
        didSet {
            self.downloadProgressView.tintColor = self.tintColor
        }
    }
    
    public func stopProximitySensor() {
        self.proximityMonitorManager?.stopListening()
    }
    
    public func configure(for message: ZMConversationMessage, isInitial: Bool) {
        self.fileMessage = message
        
        guard let fileMessageData = message.fileMessageData else {
            return
        }
        
        if isInitial {
            self.expectingDownload = false
        }
        else {
            if fileMessageData.transferState == .downloaded && self.expectingDownload {
                self.playTrack()
                self.expectingDownload = false
            }
        }
        
        self.configureVisibleViews(forFileMessageData: fileMessageData, isInitial: isInitial)
        self.updateTimeLabel()
        
        if self.isOwnTrackPlayingInAudioPlayer() {
            self.updateActivePlayerProgressAnimated(false)
            self.updateActivePlayButton()
        }
        else {
            self.playerProgressView.setProgress(0, animated: false)
            self.waveformProgressView.setProgress(0, animated: false)
        }
    }
    
    public func willDeleteMessage() {
        proximityMonitorManager?.stopListening()
        guard let player = audioTrackPlayer, let source = player.sourceMessage, source.isEqual(self.fileMessage) else { return }
        player.stop()
    }
    
    private func configureVisibleViews(forFileMessageData fileMessageData: ZMFileMessageData, isInitial: Bool) {
        guard let fileMessage = self.fileMessage,
            let state = FileMessageViewState.fromConversationMessage(fileMessage) else { return }
        
        var visibleViews = [self.playButton, self.timeLabel]
        
        if (fileMessageData.normalizedLoudness?.count ?? 0 > 0) {
            waveformProgressView.samples = fileMessageData.normalizedLoudness ?? []
            if let accentColor = fileMessage.sender?.accentColor {
                waveformProgressView.barColor = accentColor
                waveformProgressView.highlightedBarColor = UIColor.gray
            }
            visibleViews.append(self.waveformProgressView)
        } else {
            visibleViews.append(self.playerProgressView)
        }
        
        switch state {
        case .obfuscated: visibleViews = []
        case .unavailable: visibleViews = [self.loadingView]
        case .downloading, .uploading:
            visibleViews.append(self.downloadProgressView)
            self.downloadProgressView.setProgress(fileMessageData.progress, animated: !isInitial)
        default:
            break
        }
        
        if let viewsState = state.viewsStateForAudio() {
            self.playButton.setIcon(viewsState.playButtonIcon, with: .tiny, for: .normal)
            self.playButton.backgroundColor = viewsState.playButtonBackgroundColor
            self.playButton.accessibilityValue = viewsState.playButtonIcon == .play ? "play" : "pause"
        }
        
        updateVisibleViews(allViews, visibleViews: visibleViews, animated: !loadingView.isHidden)
    }
    
    private func updateTimeLabel() {
        
        var duration: Int? = .none
        
        if self.isOwnTrackPlayingInAudioPlayer() {
            if let audioTrackPlayer = self.audioTrackPlayer {
                duration = Int(audioTrackPlayer.elapsedTime)
            }
        }
        else {
            guard let message = self.fileMessage,
                let fileMessageData = message.fileMessageData else {
                    return
            }
            if fileMessageData.durationMilliseconds != 0 {
                duration = Int(roundf(Float(fileMessageData.durationMilliseconds) / 1000.0))
            }
        }
        
        if let durationUnboxed = duration {
            let (seconds, minutes) = (durationUnboxed % 60, durationUnboxed / 60)
            let time = String(format: "%d:%02d", minutes, seconds)
            self.timeLabel.text = time
        }
        else {
            self.timeLabel.text = ""
        }
        self.timeLabel.accessibilityLabel = "AudioTimeLabel"
        self.timeLabel.accessibilityValue = self.timeLabel.text
    }
    
    private func updateActivePlayButton() {
        guard let audioTrackPlayer = self.audioTrackPlayer else { return }
        
        self.playButton.backgroundColor = FileMessageViewState.normalColor
        
        if audioTrackPlayer.isPlaying {
            self.playButton.setIcon(.pause, with: .tiny, for: UIControlState())
            self.playButton.accessibilityValue = "pause"
        }
        else {
            self.playButton.setIcon(.play, with: .tiny, for: UIControlState())
            self.playButton.accessibilityValue = "play"
        }
    }
    
    private func updateInactivePlayer() {
        self.playButton.backgroundColor = FileMessageViewState.normalColor
        self.playButton.setIcon(.play, with: .tiny, for: UIControlState())
        self.playButton.accessibilityValue = "play"
        
        self.playerProgressView.setProgress(0, animated: false)
        self.waveformProgressView.setProgress(0, animated: false)
    }
    
    private func updateActivePlayerProgressAnimated(_ animated: Bool) {
        guard let audioTrackPlayer = self.audioTrackPlayer else { return }
        
        let progress: Float
        var animated = animated
        
        if fabs(1 - audioTrackPlayer.progress) < 0.01 {
            progress = 0
            animated = false
        }
        else {
            progress = Float(audioTrackPlayer.progress)
        }
        
        self.playerProgressView.setProgress(progress, animated: animated)
        self.waveformProgressView.setProgress(progress, animated: animated)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.playButton.layer.cornerRadius = self.playButton.bounds.size.width / 2.0
    }
    
    public func stopPlaying() {
        guard let player = self.audioTrackPlayer, let source = player.sourceMessage, source.isEqual(self.fileMessage) else { return }
        player.pause()
    }
    
    private func playTrack() {
        guard let fileMessage = self.fileMessage, let fileMessageData = fileMessage.fileMessageData, let audioTrackPlayer = self.audioTrackPlayer else {
            return
        }
        
        self.proximityMonitorManager?.stateChanged = proximityStateDidChange
        
        let audioTrackPlayingSame = audioTrackPlayer.sourceMessage?.isEqual(self.fileMessage) ?? false
        
        if let track = fileMessage.audioTrack(), !audioTrackPlayingSame {
            audioTrackPlayer.load(track, sourceMessage: fileMessage) { [weak self] success, error in
                if success {
                    self?.setAudioOutput(earpiece: false)
                    audioTrackPlayer.play()
                    
                    let duration = TimeInterval(Float(fileMessageData.durationMilliseconds) / 1000.0)
                    Analytics.shared().tagPlayedAudioMessage(duration, extensionString: ((fileMessageData.filename ?? "") as NSString).pathExtension)
                }
                else {
                    DDLogWarn("Cannot load track \(track): \(String(describing: error))")
                }
            }
        } else {
            if audioTrackPlayer.isPlaying {
                audioTrackPlayer.pause()
            } else {
                audioTrackPlayer.play()
            }
        }
    }
    
    
    /// Check if the audioTrackPlayer is playing my track
    ///
    /// - Returns: true if audioTrackPlayer is playing the audio of this view (not other instance of AudioMessgeView or other audio playing object)
    private func isOwnTrackPlayingInAudioPlayer() -> Bool {
        guard let message = self.fileMessage,
            let audioTrack = message.audioTrack(),
            let audioTrackPlayer = self.audioTrackPlayer
            else {
                return false
        }
        
        let audioTrackPlayingSame = audioTrackPlayer.sourceMessage?.isEqual(self.fileMessage) ?? false
        return audioTrackPlayingSame && audioTrackPlayer.audioTrack.isEqual(audioTrack)
    }
    
    func setupAudioPlayerObservers() {
        audioPlayerProgressObserver = KeyValueObserver.observe(_audioTrackPlayer, keyPath: "progress", target: self, selector: #selector(audioProgressChanged(_:)), options: [.initial, .new])
        audioPlayerStateObserver = KeyValueObserver.observe(_audioTrackPlayer, keyPath: "state", target: self, selector: #selector(audioPlayerStateChanged(_:)), options: [.initial, .new])
    }

    // MARK: - Actions
    
    dynamic private func onActionButtonPressed(_ sender: UIButton) {
        
        guard let fileMessage = self.fileMessage, let fileMessageData = fileMessage.fileMessageData else { return }
        
        switch(fileMessageData.transferState) {
        case .downloading:
            self.downloadProgressView.setProgress(0, animated: false)
            self.delegate?.transferView(self, didSelect: .cancel)
        case .uploading:
            if .none != fileMessageData.fileURL {
                self.delegate?.transferView(self, didSelect: .cancel)
            }
        case .cancelledUpload, .failedUpload:
            if .none != fileMessageData.fileURL {
                self.delegate?.transferView(self, didSelect: .resend)
            }
        case .uploaded, .failedDownload:
            self.expectingDownload = true
            ZMUserSession.shared()?.enqueueChanges({
                fileMessage.requestFileDownload()
            })
            
        case .downloaded:
            self.playTrack()
        }
    }
    
    // MARK: - Audio state observer
    dynamic private func audioProgressChanged(_ change: NSDictionary) {
        DispatchQueue.main.async {
            if self.isOwnTrackPlayingInAudioPlayer() {
                self.updateActivePlayerProgressAnimated(false)
                self.updateTimeLabel()
            }
        }
    }
    
    
    ///  Observer function for audioTrackPlayer's keyPath "state".
    ///  This function updates the visual progress of the audio, play button icon image, time label and proximity sensor's sate.
    ///  Notice: when there are more then 1 instance of this class exists, this function will be called in every instance.
    ///          This function may called from background thread (in case incoming call).
    ///
    /// - Parameter change: a dictionary with KVP kind and new (enum MediaPlayerState: 0 = ready, 1 = play, 2 = pause, 3 = completed, 4 = error)
    dynamic private func audioPlayerStateChanged(_ change: NSDictionary) {
        DispatchQueue.main.async {
            if self.isOwnTrackPlayingInAudioPlayer() {
                self.updateActivePlayerProgressAnimated(false)
                self.updateActivePlayButton()
                self.updateTimeLabel()
                self.updateProximityObserverState()
            }
            /// when state is completed, there is no info about it is own track or not. Update the time label in this case anyway (set to the length of own audio track)
            else if let new = change["new"] as? Int, let state = MediaPlayerState(rawValue: new), state == .completed {
                self.updateTimeLabel()
            }
            else {
                self.updateInactivePlayer()
            }
        }
    }
    
    // MARK: - Proximity Listener
    
    private func updateProximityObserverState() {
        guard let audioTrackPlayer = self.audioTrackPlayer, isOwnTrackPlayingInAudioPlayer() else { return }
        
        if audioTrackPlayer.isPlaying {
            proximityMonitorManager?.startListening()
        } else {
            proximityMonitorManager?.stopListening()
        }
    }
    
    private func setAudioOutput(earpiece: Bool) {
        do {
            if earpiece {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                AVSMediaManager.sharedInstance().playbackRoute = .builtIn
            } else {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                AVSMediaManager.sharedInstance().playbackRoute = .speaker
            }
        } catch {
            DDLogError("Cannot set AVAudioSession category: \(error)")
        }
    }
    
    func proximityStateDidChange(_ raisedToEar: Bool) {
        setAudioOutput(earpiece: raisedToEar)
    }
}
