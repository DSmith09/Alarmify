//
//  PlaylistTableViewController.swift
//  Alarmify
//
//  Created by David on 7/19/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController {
    private var playlists: [SPTPartialPlaylist]?
    private let playlistDelegate = PlaylistDelegate.defaultInstance()
    private let reuseIdentifier = NSStringFromClass(UITableViewCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = PLAYLIST_TITLE
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(setPlaylists), name: PLAYLISTS_RETRIEVED_NOTIFICATION, object: nil)
    }
    
    @objc private func setPlaylists() {
        playlists = playlistDelegate.getPlaylists()
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let playlists = playlists else { return 0 }
        return playlists.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if (playlists != nil) {
            let playlist = playlists![indexPath.row]
            cell.textLabel?.text = playlist.name
            cell.detailTextLabel?.text = "Track Count: " + String(describing: playlist.trackCount)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (playlists != nil) {
            let playlist = playlists![indexPath.row]
            playlistDelegate.retrieveTracks(playlist: playlist, sptSession: SPTAuth.defaultInstance().session)
        }
    }
}
