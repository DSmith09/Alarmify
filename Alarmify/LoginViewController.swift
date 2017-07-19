//
//  ViewController.swift
//  Alarmify
//
//  Created by David on 7/16/17.
//  Copyright © 2017 DSmith. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    // Spotify Delegate
    var spotifyDelegate: SpotifyDelegate!
    
    // UI Views
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = ALARMIFY
        setupLoginButton()
    }

    private func setupLoginButton() {
        loginButton.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
    }
    
    @objc private func loginPressed() {
        spotifyDelegate.loginPressed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

