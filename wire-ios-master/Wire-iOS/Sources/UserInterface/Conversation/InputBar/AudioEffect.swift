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


extension String {
    @discardableResult public func deleteFileAtPath() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: self)
        }
        catch (let error) {
            DDLogError("Cannot delete file: \(self): \(error)")
            return false
        }
        return true
    }
}

extension AVSAudioEffectType: CustomStringConvertible {

    public var icon: ZetaIconType {
        get {
            switch self {
            case .none:
                return .person
            case .pitchupInsane:
                return .effectBallon // Helium
            case .pitchdownInsane:
                return .effectJellyfish // Jellyfish
            case .paceupMed:
                return .effectRabbit // Hare
            case .reverbMax:
                return .effectChurch // Cathedral
            case .chorusMax:
                return .effectAlien // Alien
            case .vocoderMed:
                return .effectRobot // Robot
            case .pitchUpDownMax:
                return .effectRollerCoaster // Roller coaster
            default:
                return .exclamationMark
            }
        }
    }
    
    public var description: String {
        get {
            switch self {
            case .chorusMin:
                return "ChorusMin"
            case .chorusMax:
                return "Alien"
            case .reverbMin:
                return "ReverbMin"
            case .reverbMed:
                return "ReverbMed"
            case .reverbMax:
                return "Cathedral"
            case .pitchupMin:
                return "PitchupMin"
            case .pitchupMed:
                return "PitchupMed"
            case .pitchupMax:
                return "PitchupMax"
            case .pitchupInsane:
                return "Helium"
            case .pitchdownMin:
                return "PitchdownMin"
            case .pitchdownMed:
                return "PitchdownMed"
            case .pitchdownMax:
                return "PitchdownMax"
            case .pitchdownInsane:
                return "Jellyfish"
            case .paceupMin:
                return "PaceupMin"
            case .paceupMed:
                return "Hare"
            case .paceupMax:
                return "PaceupMax"
            case .pacedownMin:
                return "PacedownMin"
            case .pacedownMed:
                return "PacedownMed"
            case .pacedownMax:
                return "Turtle"
            case .reverse:
                return "UpsideDown"
            case .vocoderMed:
                return "VocoderMed"
            case .pitchUpDownMax:
                return "Roller coaster"
            case .none:
                return "None"
            default:
                return "Unknown"
            }
        }
    }
    
    public static let displayedEffects: [AVSAudioEffectType] = [.none,
                                                                .pitchupInsane,
                                                                .pitchdownInsane,
                                                                .paceupMed,
                                                                .reverbMax,
                                                                .chorusMax,
                                                                .vocoderMed,
                                                                .pitchUpDownMax]
    
    static let wr_convertQueue = DispatchQueue(label: "audioEffectQueue")
    
    public func apply(_ inPath: String, outPath: String, completion: (() -> ())? = .none) {
        
        type(of: self).wr_convertQueue.async {
            
            let result = AVSAudioEffect().applyWav(nil, inFile: inPath, outFile: outPath, effect: self, nr_flag: true)
            DDLogInfo("applyEffect \(self) from \(inPath) to \(outPath): \(result)")
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}
