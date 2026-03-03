//
//  SoundManager.swift
//  Notch Touch
//
//  Handles playback of the bundled notch sound.
//

import Foundation
import AVFoundation

final class SoundManager {

    // Keep strong reference so audio does not stop immediately
    private var player: AVAudioPlayer?

    /// Plays the sound once. If already playing, it restarts for immediate feedback.
    func playSound() {
        guard let url = Bundle.main.url(forResource: "notch_sound", withExtension: "mp4") else {
            print("[SoundManager] Missing resource: notch_sound.mp4. Make sure it is added to Target Membership.")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.volume = 1.0
            player.prepareToPlay()
            player.play()

            // retain player
            self.player = player

            print("[SoundManager] ✅ Sound played successfully")
        } catch {
            print("[SoundManager] Failed to play sound: \(error)")
        }
    }
}
