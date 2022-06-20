//
//  SplashViewController.swift
//  fanatick
//
//  Created by Yashesh on 19/09/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import AVKit

class SplashViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let path = Bundle.main.path(forResource: "iPhoneSplash", ofType: "mp4")
        
        guard let urlPath = path else {
            return
        }
        
        let videoURL = URL.init(fileURLWithPath: urlPath)
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

    }
    
    @objc func playerDidFinishPlaying() {
        if !FirebaseSession.shared.isSignIn {
            AuthenticationViewController.makeRoot()
        } else {
            RootNavigationController.makeRoot()
            FirebaseSession.shared.getUserDetail()
        }
    }
}
