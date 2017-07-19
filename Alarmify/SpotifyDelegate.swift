//
//  SpotifyDelegate.swift
//  Alarmify
//
//  Created by David on 7/18/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import Foundation

class SpotifyDelegate: NSObject {
    fileprivate let sptAuth = SPTAuth.defaultInstance()!
    fileprivate let sptPlayer = SPTAudioStreamingController.sharedInstance()!
    fileprivate var authViewController: UIViewController?
    
    override init() {
        super.init()
        setSpotifyAuth()
        sptPlayer.delegate = self
        do {
            try sptPlayer.start(withClientId: CLIENT_ID)
        } catch {
            print("Failed to initialize Spotify Player; Error: \(error.localizedDescription)")
        }
    }
    
    private func setSpotifyAuth() {
        sptAuth.clientID = CLIENT_ID
        sptAuth.redirectURL = URL(string: LOGIN_CALLBACK)
        sptAuth.sessionUserDefaultsKey = "current session"
        sptAuth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope]
    }
    
    func loginPressed() {
        DispatchQueue.main.async {
            self.startAuthentication()
        }
    }
    
    private func startAuthentication() {
        guard sptAuth.session != nil,
            sptAuth.session.isValid() else {
                let authenticationURL = sptAuth.spotifyWebAuthenticationURL()
                authViewController = SFSafariViewController(url: authenticationURL!)
                UIApplication.shared.keyWindow?.rootViewController?.present(authViewController!, animated: true, completion: nil)
                return
        }
        sptPlayer.login(withAccessToken: sptAuth.session.accessToken)
    }
}

// MARK: SPTAudioStreamingDelegate
extension SpotifyDelegate: SPTAudioStreamingDelegate {
    // Login
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        sptPlayer.playSpotifyURI("spotify:track:46gjYTEK7W8ZTABcglGP2f", startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print("Failed to Playback Spotify URI; Error: \(error!.localizedDescription)")
            } else {
                print("Playing...")
            }
        })
    }
}

// MARK: Login Callback Delegate
extension SpotifyDelegate {
    func handleCallback(url: URL) -> Bool {
        guard sptAuth.canHandle(url) else {
            return false
        }
        authViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        authViewController = nil
        sptAuth.handleAuthCallback(withTriggeredAuthURL: url, callback: {
            (error, session) in
            if error != nil {
                print("Failed to Handle Authentication Callback; Error: \(error!.localizedDescription)")
                return
            }
            guard let session = session else {
                print("Session is Nil")
                return
            }
            self.sptPlayer.login(withAccessToken: session.accessToken)
        })
        return true
    }
}
