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
import Classy

@objc public final class AudioButtonOverlay: UIView {
    
    enum AudioButtonOverlayButtonType {
        case play, send, stop
    }
    
    typealias ButtonPressHandler = (AudioButtonOverlayButtonType) -> Void
    
    var recordingState: AudioRecordState = .recording {
        didSet { updateWithRecordingState(recordingState) }
    }
    
    var playingState: PlayingState = .idle {
        didSet { updateWithPlayingState(playingState) }
    }
    
    fileprivate var heightConstraint: NSLayoutConstraint?
    fileprivate var widthConstraint: NSLayoutConstraint?
    
    var iconColor, iconColorHighlighted, greenColor, grayColor, superviewColor: UIColor?
    
    let audioButton = IconButton()
    let playButton = IconButton()
    let sendButton = IconButton()
    let backgroundView = UIView()
    var buttonHandler: ButtonPressHandler?
    
    init() {
        super.init(frame: CGRect.zero)
        CASStyler.default().styleItem(self)
        configureViews()
        createConstraints()
        updateWithRecordingState(recordingState)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.layer.cornerRadius = bounds.width / 2
    }

    func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        audioButton.isUserInteractionEnabled = false
        audioButton.setIcon(.microphone, with: .tiny, for: UIControlState())
        audioButton.accessibilityIdentifier = "audioRecorderRecord"
        
        playButton.setIcon(.play, with: .tiny, for: UIControlState())
        playButton.accessibilityIdentifier = "audioRecorderPlay"
        playButton.accessibilityValue = PlayingState.idle.description

        sendButton.setIcon(.checkmark, with: .tiny, for: UIControlState())
        sendButton.accessibilityIdentifier = "audioRecorderSend"
        
        [backgroundView, audioButton, sendButton, playButton].forEach(addSubview)
        
        playButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func createConstraints() {
        let initialViewWidth: CGFloat = 40
        
        constrain(self, audioButton, playButton, sendButton, backgroundView) { view, audioButton, playButton, sendButton, backgroundView in
            audioButton.centerY == view.bottom - initialViewWidth / 2
            audioButton.centerX == view.centerX
            
            playButton.centerX == view.centerX
            playButton.centerY == view.bottom - initialViewWidth / 2
            
            sendButton.centerX == view.centerX
            sendButton.centerY == view.top + initialViewWidth / 2
            
            widthConstraint = view.width == initialViewWidth
            heightConstraint = view.height == 96
            backgroundView.edges == view.edges
        }
    }
    
    func setOverlayState(_ state: AudioButtonOverlayState) {
        defer { layoutIfNeeded() }
        heightConstraint?.constant = state.height
        widthConstraint?.constant = state.width
        alpha = state.alpha
        
        guard let greenColor = greenColor, let grayColor = grayColor, let darkColor = iconColor,
            let brightColor = iconColorHighlighted, let superviewColor = superviewColor else { return }
        
        let blendedGray = grayColor.removeAlphaByBlending(with: superviewColor)!
        sendButton.setIconColor(state.colorWithColors(greenColor, highlightedColor: brightColor), for: UIControlState())
        backgroundView.backgroundColor = state.colorWithColors(blendedGray, highlightedColor: greenColor)
        audioButton.setIconColor(state.colorWithColors(darkColor, highlightedColor: brightColor), for: UIControlState())
        playButton.setIconColor(darkColor, for: UIControlState())
    }
    
    func updateWithRecordingState(_ state: AudioRecordState) {
        audioButton.isHidden = state == .finishedRecording
        playButton.isHidden = state == .recording
        sendButton.isHidden = false
        backgroundView.isHidden = false
    }
    
    func updateWithPlayingState(_ state: PlayingState) {
        let icon: ZetaIconType = state == .idle ? .play : .stop
        playButton.setIcon(icon, with: .tiny, for: UIControlState())
        playButton.accessibilityValue = state.description
    }
    
    func buttonPressed(_ sender: IconButton) {
        let type: AudioButtonOverlayButtonType
        
        if sender == sendButton {
            type = .send
        } else {
            type = playingState == .idle ? .play : .stop
        }
        
        buttonHandler?(type)
    }
    
}
