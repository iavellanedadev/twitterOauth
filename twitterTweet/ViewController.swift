//
//  ViewController.swift
//  twitterTweet
//
//  Created by Consultant on 6/1/20.
//  Copyright © 2020 Avellaneda. All rights reserved.
//

import UIKit
import OAuthSwift

let TWITTER_CONSUMER_KEY = "yQf9EcTGbXEhBPNX6bJtPs3Xi"
let TWITTER_CONSUMER_SECRET = "PMN7O4HgcMcfBPvmfvKh3SZ1XJwwO2lDHSLFmve0y6xHDPg9GR"

class ViewController: UIViewController {

    @IBOutlet weak var mainLabe: UILabel!
    
    var oauthSwift = OAuth1Swift(
        consumerKey:    TWITTER_CONSUMER_KEY,
        consumerSecret: TWITTER_CONSUMER_SECRET,
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl:    "https://api.twitter.com/oauth/authorize",
        accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func twitterButtonTouch(_ sender: UIButton) {
        oauthSwift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthSwift)
        // authorize
        oauthSwift.authorize(
        withCallbackURL: "twitterTweet://authorize") { [weak self] result in
            switch result {
            case .success(let (credential, _, parameters)):
                //these we should store, in keychain for later
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                guard let screenName = parameters["screen_name"] as? String else { return }
                self?.mainLabe.text = "Welcome, \(screenName)"
            // Do your request
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    

}

