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
import XCTest
@testable import Wire


class MockAudioRecordKeyboardDelegate: AudioRecordViewControllerDelegate {
    var didCancelHitCount = 0
    @objc func audioRecordViewControllerDidCancel(_ audioRecordViewController: AudioRecordBaseViewController) {
        didCancelHitCount = didCancelHitCount + 1
    }
    
    var didStartRecordingHitCount = 0
    @objc func audioRecordViewControllerDidStartRecording(_ audioRecordViewController: AudioRecordBaseViewController) {
        didStartRecordingHitCount = didStartRecordingHitCount + 1
    }
    
    var wantsToSendAudioHitCount = 0
    @objc func audioRecordViewControllerWantsToSendAudio(_ audioRecordViewController: AudioRecordBaseViewController, recordingURL: URL, duration: TimeInterval, context: AudioMessageContext, filter: AVSAudioEffectType) {
        wantsToSendAudioHitCount = wantsToSendAudioHitCount + 1
    }
}

class MockAudioRecorder: AudioRecorderType {
    var format: AudioRecorderFormat = .wav
    var state: AudioRecorderState = .recording
    var fileURL: URL? = Bundle(for: MockAudioRecorder.self).url(forResource: "audio_sample", withExtension: "m4a")
    var maxRecordingDuration: TimeInterval? = 25 * 60
    var currentDuration: TimeInterval = 0.0
    var recordTimerCallback: ((TimeInterval) -> Void)?
    var recordLevelCallBack: ((RecordingLevel) -> Void)?
    var playingStateCallback: ((PlayingState) -> Void)?
    var recordStartedCallback: (() -> Void)?
    var recordEndedCallback: ((Bool) -> Void)?
    
    var startRecordingHitCount = 0
    func startRecording() {
        startRecordingHitCount = startRecordingHitCount + 1
    }
    
    var stopRecordingHitCount = 0
    @discardableResult func stopRecording() -> Bool {
        stopRecordingHitCount = stopRecordingHitCount + 1
        return true
    }
    
    var deleteRecordingHitCount = 0
    func deleteRecording() {
        deleteRecordingHitCount = deleteRecordingHitCount + 1
    }
    
    var playRecordingHitCount = 0
    func playRecording() {
        playRecordingHitCount = playRecordingHitCount + 1
    }
    
    var stopPlayingHitCount = 0
    func stopPlaying() {
        stopPlayingHitCount = stopPlayingHitCount + 1
    }
    
    func levelForCurrentState() -> RecordingLevel {
        return 0
    }
    
    func durationForCurrentState() -> TimeInterval? {
        return 0
    }
}


class AudioRecordKeyboardViewControllerTests: XCTestCase {
    var sut: AudioRecordKeyboardViewController!
    var audioRecorder = MockAudioRecorder()
    var mockDelegate = MockAudioRecordKeyboardDelegate()
    
    override func setUp() {
        super.setUp()
        self.sut = AudioRecordKeyboardViewController(audioRecorder: self.audioRecorder)
        self.sut.delegate = self.mockDelegate
    }
    
    func testThatItStartsRecordingWhenClickingRecordButton() {
        // when
        self.sut.recordButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(self.audioRecorder.startRecordingHitCount, 1)
        XCTAssertEqual(self.audioRecorder.stopRecordingHitCount, 0)
        XCTAssertEqual(self.audioRecorder.deleteRecordingHitCount, 0)
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.recording)
        XCTAssertEqual(self.mockDelegate.didStartRecordingHitCount, 1)
    }
    
    func testThatItStartsRecordingWhenClickingRecordArea() {
        // when
        self.sut.recordButtonPressed(self)
        
        // then
        XCTAssertEqual(self.audioRecorder.startRecordingHitCount, 1)
        XCTAssertEqual(self.audioRecorder.stopRecordingHitCount, 0)
        XCTAssertEqual(self.audioRecorder.deleteRecordingHitCount, 0)
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.recording)
        XCTAssertEqual(self.mockDelegate.didStartRecordingHitCount, 1)
    }
    
    func testThatItStopsRecordingWhenClickingStopButton() {
        // when
        self.sut.recordButtonPressed(self)
        
        // and when
        self.sut.stopRecordButton.sendActions(for: .touchUpInside)

        // then
        XCTAssertEqual(self.audioRecorder.startRecordingHitCount, 1)
        XCTAssertEqual(self.audioRecorder.stopRecordingHitCount, 1)
        XCTAssertEqual(self.audioRecorder.deleteRecordingHitCount, 0)
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.recording)
        XCTAssertEqual(self.mockDelegate.didStartRecordingHitCount, 1)
    }
    
    func testThatItSwitchesToEffectsScreenAfterRecord() {
        // when
        self.sut.recordButton.sendActions(for: .touchUpInside)
        
        // and when
        self.audioRecorder.recordEndedCallback!(true)
        
        // then
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.effects)
    }
    
    func testThatItSwitchesToRecordingAfterRecordDiscarded() {
        // when
        self.sut.recordButton.sendActions(for: .touchUpInside)
        
        // and when
        self.audioRecorder.recordEndedCallback!(true)
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.effects)

        // and when
        self.sut.redoButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.ready)
        XCTAssertEqual(self.mockDelegate.didStartRecordingHitCount, 1)

    }

    func testThatItCallsErrorDelegateCallback() {
        // when
        self.sut.recordButton.sendActions(for: .touchUpInside)
        
        // and when
        self.audioRecorder.recordEndedCallback!(true)
        XCTAssertEqual(self.sut.state, AudioRecordKeyboardViewController.State.effects)
        
        // and when
        self.sut.cancelButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(self.mockDelegate.didStartRecordingHitCount, 1)
        XCTAssertEqual(self.mockDelegate.didCancelHitCount, 1)
    }
}
