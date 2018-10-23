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
import CocoaLumberjackSwift
import Cartography


@objc public protocol AudioEffectsPickerDelegate: NSObjectProtocol {
    func audioEffectsPickerDidPickEffect(_ picker: AudioEffectsPickerViewController, effect: AVSAudioEffectType, resultFilePath: String)
}

@objc public final class AudioEffectsPickerViewController: UIViewController {
    
    public let recordingPath: String
    fileprivate let duration: TimeInterval
    public weak var delegate: AudioEffectsPickerDelegate?
    
    fileprivate var audioPlayerController: AudioPlayerController? {
        didSet {
            if self.audioPlayerController == .none {
                let selector = #selector(AudioEffectsPickerViewController.updatePlayProgressTime)
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: .none)
            }
        }
    }
    
    internal enum State {
        case none
        case tip
        case time
        case playing
    }
    
    internal var state: State = .none
    
    fileprivate let effects: [AVSAudioEffectType] = AVSAudioEffectType.displayedEffects
    internal var normalizedLoudness: [Float] = []
    fileprivate var lastLayoutSize = CGSize.zero
    
    internal var selectedAudioEffect: AVSAudioEffectType = .none {
        didSet {
            if self.selectedAudioEffect == .reverse {
                self.progressView.samples = self.normalizedLoudness.reversed()
            }
            else {
                self.progressView.samples = self.normalizedLoudness
            }
            
            self.setState(.playing, animated: true)

            if let audioPlayerController = self.audioPlayerController, oldValue == self.selectedAudioEffect {
                
                if audioPlayerController.state == .playing {
                    audioPlayerController.stop()
                } else {
                    audioPlayerController.play()
                }
            
                return
            }
            
            if self.selectedAudioEffect != .none {
                self.audioPlayerController?.stop()
                
                
                let effectPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("effect.wav")
                effectPath.deleteFileAtPath()
                self.selectedAudioEffect.apply(self.recordingPath, outPath: effectPath) {
                    self.delegate?.audioEffectsPickerDidPickEffect(self, effect: self.selectedAudioEffect, resultFilePath: effectPath)
                    
                    self.playMedia(effectPath)
                }
            }
            else {
                self.delegate?.audioEffectsPickerDidPickEffect(self, effect: .none, resultFilePath: self.recordingPath)
                self.playMedia(self.recordingPath)
            }
        }
    }
    
    fileprivate static let effectRows = 2
    fileprivate static let effectColumns = 4
    
    deinit {
        self.audioPlayerController?.stop()
        self.audioPlayerController = .none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatal("init?(coder) is not implemented")
    }
    
    public init(recordingPath: String, duration: TimeInterval) {
        self.duration = duration
        self.recordingPath = recordingPath
        super.init(nibName: .none, bundle: .none)
    }
    
    fileprivate let collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate var collectionView: UICollectionView!
    fileprivate let statusBoxView = UIView()
    internal let progressView = WaveformProgressView()
    fileprivate let subtitleLabel = UILabel()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.createCollectionView()
        self.progressView.barColor = UIColor.white
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        
        self.subtitleLabel.textAlignment = .center
        self.subtitleLabel.font = UIFont(magicIdentifier: "style.text.small.font_spec_light")
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusBoxView.translatesAutoresizingMaskIntoConstraints = false

        self.statusBoxView.addSubview(self.progressView)
        self.statusBoxView.addSubview(self.subtitleLabel)
        self.view.addSubview(self.statusBoxView)
        self.view.addSubview(self.collectionView)
        
        constrain(self.view, self.collectionView, self.progressView, self.subtitleLabel, self.statusBoxView) { view, collectionView, progressView, subtitleLabel, statusBoxView in
            collectionView.left == view.left
            collectionView.top == view.top
            collectionView.right == view.right

            statusBoxView.top == collectionView.bottom + 8
            statusBoxView.height == 24
            statusBoxView.left == collectionView.left + 48
            statusBoxView.right == collectionView.right - 48
            statusBoxView.bottom == view.bottom
            
            progressView.edges == statusBoxView.edges
            subtitleLabel.edges == statusBoxView.edges
        }
        
        self.loadLevels()
        
        self.setState(.time, animated: false)
    }
    
    fileprivate func createCollectionView() {
        self.collectionViewLayout.scrollDirection = .vertical
        self.collectionViewLayout.minimumLineSpacing = 0
        self.collectionViewLayout.minimumInteritemSpacing = 0
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.register(AudioEffectCell.self, forCellWithReuseIdentifier: AudioEffectCell.reuseIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.allowsSelection = true
        self.collectionView.backgroundColor = UIColor.clear
    }
    
    fileprivate func loadLevels() {
        let url = URL(fileURLWithPath: recordingPath)
        FileMetaDataGenerator.metadataForFileAtURL(url, UTI: url.UTI(), name: url.lastPathComponent) { metadata in
            DispatchQueue.main.async(execute: {
                if let audioMetadata = metadata as? ZMAudioMetadata {
                    self.normalizedLoudness = audioMetadata.normalizedLoudness
                    self.progressView.samples = audioMetadata.normalizedLoudness
                }
            })
        }
    }
    
    public override func removeFromParentViewController() {
        self.audioPlayerController?.stop()
        self.audioPlayerController = nil
        super.removeFromParentViewController()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectCurrentFilter()
        delay(2) {
            if self.state == .time {
                self.setState(.tip, animated: true)
            }
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.audioPlayerController?.stop()
        self.audioPlayerController = nil
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.lastLayoutSize.equalTo(self.view.bounds.size) {
            self.lastLayoutSize = self.view.bounds.size
            self.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
            self.selectCurrentFilter()
        }
    }
    
    internal func setState(_ state: State, animated: Bool) {
        if self.state == state {
            return
        }
        
        self.state = state
        
        let colorScheme = ColorScheme()
        colorScheme.variant = .dark
        
        
        switch self.state {
        case .tip:
            self.subtitleLabel.text = "conversation.input_bar.audio_message.keyboard.filter_tip".localized.uppercased()
            self.subtitleLabel.textColor = colorScheme.color(withName: ColorSchemeColorTextForeground)
        case .time:
            let duration: Int
            if let player = self.audioPlayerController?.player {
                duration = Int(ceil(player.duration))
            }
            else {
                duration = Int(ceil(self.duration))
            }
            
            let (seconds, minutes) = (duration % 60, duration / 60)
            self.subtitleLabel.text = String(format: "%d:%02d", minutes, seconds)
            self.subtitleLabel.accessibilityValue = self.subtitleLabel.text
            self.subtitleLabel.textColor = colorScheme.color(withName: ColorSchemeColorTextForeground)
        default:
            // no-op
            break
        }
        
        let change = {
            self.subtitleLabel.isHidden = self.state == .playing
            self.progressView.isHidden = self.state != .playing
        }
        
        if animated {
            let options: UIViewAnimationOptions = (state == .playing) ? .transitionFlipFromTop : .transitionFlipFromBottom
            UIView.transition(with: self.statusBoxView, duration: 0.35, options: options, animations: change, completion: .none)
        }
        else {
            change()
        }
    }
    
    fileprivate func selectCurrentFilter() {
        if let index = self.effects.index(where: {
            $0 == self.selectedAudioEffect
        }) {
            let indexPath = IndexPath(item:index, section:0)
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
    
    fileprivate func playMedia(_ atPath: String) {
        Analytics.shared().tagPreviewedAudioMessageRecording(.keyboard)
        self.audioPlayerController = try? AudioPlayerController(contentOf: URL(fileURLWithPath: atPath))
        self.audioPlayerController?.delegate = self
        self.audioPlayerController?.play()
        self.updatePlayProgressTime()
    }
    
    @objc fileprivate func updatePlayProgressTime() {
        let selector = #selector(AudioEffectsPickerViewController.updatePlayProgressTime)
        if let player = self.audioPlayerController?.player {
            self.progressView.progress = Float(player.currentTime / player.duration)
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: .none)
            self.perform(selector, with: .none, afterDelay: 0.05)
        }
        else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: .none)
        }
    }
}

extension AudioEffectsPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.effects.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioEffectCell.reuseIdentifier, for: indexPath) as! AudioEffectCell
        cell.effect = self.effects[indexPath.item]
        let lastColumn = ((indexPath as NSIndexPath).item % type(of: self).effectColumns) == type(of: self).effectColumns - 1
        let lastRow = Int(floorf(Float((indexPath as NSIndexPath).item) / Float(type(of: self).effectColumns))) == type(of: self).effectRows - 1

        cell.borders = (lastColumn ? AudioEffectCellBorders.None : AudioEffectCellBorders.Right).union(lastRow ? [] : [AudioEffectCellBorders.Bottom])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(Int(collectionView.bounds.width) / type(of: self).effectColumns),
                          height: CGFloat(Int(collectionView.bounds.height) / type(of: self).effectRows))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedAudioEffect = self.effects[indexPath.item]
    }
}

extension AudioEffectsPickerViewController : AudioPlayerControllerDelegate {
    
    func audioPlayerControllerDidFinishPlaying() {
        setState(.time, animated: true)
    }
    
}

private protocol AudioPlayerControllerDelegate : class {
    
    func audioPlayerControllerDidFinishPlaying()
    
}

private class AudioPlayerController : NSObject, MediaPlayer, AVAudioPlayerDelegate {
    
    let player : AVAudioPlayer
    weak var delegate : AudioPlayerControllerDelegate?
    weak var mediaManager: MediaPlayerDelegate? = AppDelegate.shared().mediaPlaybackManager
    
    init(contentOf URL: URL) throws {
        player = try AVAudioPlayer(contentsOf: URL)
        
        super.init()
        
        player.delegate = self
    }
    
    deinit {
        mediaManager?.mediaPlayer(self, didChangeTo: .completed)
    }

    var state: MediaPlayerState {
        if player.isPlaying {
            return MediaPlayerState.playing
        } else {
            return MediaPlayerState.completed
        }
    }
    
    var title: String? {
        return nil
    }
    
    var sourceMessage: ZMConversationMessage? {
        return nil
    }
    
    func play() {
        mediaManager?.mediaPlayer(self, didChangeTo: .playing)
        player.currentTime = 0
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player == self.player {
            mediaManager?.mediaPlayer(self, didChangeTo: .completed)
            delegate?.audioPlayerControllerDidFinishPlaying()
        }
    }
    
}
