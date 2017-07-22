//
//  PlaylistStore.swift
//  Alarmify
//
//  Created by David on 7/19/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import Foundation

class PlaylistDelegate: NSObject {
    private static var instance: PlaylistDelegate?
    private var playlists = [SPTPartialPlaylist]()
    private var playlistTracks = [SPTPlaylistTrack]()
    
    public class func defaultInstance() -> PlaylistDelegate {
        if instance == nil {
            instance = PlaylistDelegate()
        }
        return instance!
    }
    
    public func getPlaylists() -> [SPTPartialPlaylist] {
        return playlists
    }
    
    public func getTracks() -> [SPTPlaylistTrack] {
        return playlistTracks
    }
    
    public func resetPlaylistTracks() {
        playlistTracks = [SPTPlaylistTrack]()
    }
    
    public func retrievePlaylists(sptSession: SPTSession) {
        guard sptSession.isValid()
            else {
                print("Session Invalid; Cannot Retrieve Playlists")
                return
            }
        if playlists.isEmpty {
            fetchPlaylists(sptSession: sptSession, completion: {
                if $0.isEmpty {
                    print("Returned Playlists is of size 0")
                }
                self.notifyObservers(forPlaylists: true)
            })
        } else {
            notifyObservers(forPlaylists: true)
        }
    }
    
    public func retrieveTracks(playlist: SPTPartialPlaylist, sptSession: SPTSession) {
        guard sptSession.isValid()
            else {
                print("Session Invalid; Cannot Retrieve Playlist Tracks")
                return
            }
        resetPlaylistTracks()
        fetchPlaylistTracks(playlist: playlist, sptSession: sptSession, completion: {
            if $0.isEmpty {
                print("Returned Playlist Tracks is of size 0")
            }
            self.notifyObservers(forPlaylists: false)
        })
    }
    
    private func notifyObservers(forPlaylists: Bool) {
        if forPlaylists {
            NotificationCenter.default.post(name: PLAYLISTS_RETRIEVED_NOTIFICATION, object: nil)
        } else {
            NotificationCenter.default.post(name: TRACKS_RETRIEVED_NOTIFICATION, object: nil)
        }
    }
    
    private func fetchPlaylists(sptSession: SPTSession, completion: @escaping ([SPTPartialPlaylist]) -> ()) {
        do {
            let playlistRequest = try SPTPlaylistList.createRequestForGettingPlaylists(forUser: sptSession.canonicalUsername, withAccessToken: sptSession.accessToken)
            SPTRequest.sharedHandler().perform(playlistRequest, callback: {
                [unowned self]
                (error, response, data) in
                if error != nil {
                    print("Failed to Retrieve Playlists for User; Error: \(error!.localizedDescription)")
                    return
                }
                do {
                    let playlistsObj = try SPTPlaylistList(from: data, with: response)
                    playlistsObj.items.forEach({
                        guard let playlist = $0 as? SPTPartialPlaylist
                            else { return }
                        self.playlists.append(playlist)
                    })
                    return completion(self.playlists)
                } catch {
                    print("Failed to instantiate Playlist Object from response; Error: \(error.localizedDescription)")
                }
            })
        } catch {
            print("Failed to Create Request For Playlist; Error: \(error.localizedDescription)")
        }
    }
    
    private func fetchPlaylistTracks(playlist: SPTPartialPlaylist, sptSession: SPTSession, completion: @escaping ([SPTPlaylistTrack]) -> ()) {
        SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: sptSession.accessToken, callback: {
            [unowned self]
            (error, response) in
            if error != nil {
                print("Failed to Retrieve Playlist Snapshot; Error: \(error!.localizedDescription)")
            }
            guard let snapshotPlaylist = response as? SPTPlaylistSnapshot
                else {
                    print("Failed to convert Response to Playlist Snapshot")
                    return
                }
            for track in snapshotPlaylist.firstTrackPage.items {
                let playlistTrack = track as! SPTPlaylistTrack
                self.playlistTracks.append(playlistTrack)
            }
            return completion(self.playlistTracks)
        })
    }
}
