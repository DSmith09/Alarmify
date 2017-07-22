//
//  TracksTableViewController.swift
//  Alarmify
//
//  Created by David on 7/22/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import UIKit

class TracksTableViewController: UITableViewController {
    private var tracks: [SPTPlaylistTrack]?
    private let playlistDelegate = PlaylistDelegate.defaultInstance()
    private let reuseIdentifier = NSStringFromClass(UITableViewCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = SONGS_TITLE
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(setTracks), name: TRACKS_RETRIEVED_NOTIFICATION, object: nil)
    }
    
    @objc private func setTracks() {
        tracks = playlistDelegate.getTracks()
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tracks = tracks else { return 0 }
        return tracks.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if (tracks != nil) {
            let track = tracks![indexPath.row]
            cell.textLabel?.text = track.name
            cell.detailTextLabel?.text = String(track.duration)
        }
        return cell
    }
    
    // TODO: Add didSelectRow At IndexPath Delegate
}
