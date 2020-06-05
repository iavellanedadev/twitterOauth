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
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var tweetTextView: UITextView!
    
    var loggedIn: Bool = false
    var user: String? {
        didSet {
//            guard let userName = user, token = retrieveToken(user: userName + "oauthToken") else { return }
//            oauthSwift.client.credential.oauthToken = token
        }
    }
    let postTweetEndPoint: String = "https://api.twitter.com/1.1/statuses/update.json"
    
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
        setupView()
    }
    
    @IBAction func twitterButtonTouch(_ sender: UIButton) {
        if !loggedIn {
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
                    self?.user = screenName
                    self?.storeTokens(credentials: credential, user: screenName)
                    self?.setupTweet(parameters: parameters)
                // Do your request
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        }
        else {
            sendTweet()
        }
    }
    
    func setupView() {
        tweetTextView.isHidden = true
        tweetTextView.text = ""
        tweetTextView.layer.borderWidth = 1
        tweetTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func setupTweet(parameters: OAuthSwift.Parameters) {
        loggedIn = true
        guard let screenName = parameters["screen_name"] as? String else { return }
        mainLabe.text = "Welcome, \(screenName)"
        twitterButton.titleLabel?.text = "Tweet"
        tweetTextView.isHidden = false
    }
    
    func sendTweet() {
        print("sending tweet")
        
        //setCredentials()
        
        guard let tweet = tweetTextView.text, let encodedTweet = tweet.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let endPoint = postTweetEndPoint + "?status=\(encodedTweet)"

        oauthSwift.client.post(endPoint) { (response) in
            switch response {
            case .success(let resp):
                print("we live \(resp)")
            case .failure(let error):
                print("error posting tweet: \(error.localizedDescription)")
            }
        }
        
    }
    
    func setCredentials() {
        oauthSwift.client.credential.oauthToken = "cxxxxxxxxxxxxxxxxxxxxxxxxx"
        oauthSwift.client.credential.oauthTokenSecret = "xxxxxxxxxxxxxxxxxxxxxxxx"
    }
    
    func storeTokens(credentials: OAuthSwiftCredential, user: String) {
        createInsertKey(key: credentials.oauthToken, tag: "\(user)authKey")
        createInsertKey(key: credentials.oauthTokenSecret, tag: "\(user)authSecret")
    }
    
    func createInsertKey(key: String, tag: String) {
        
        guard let tag = tag.data(using: .utf8) else { return }
        let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecValueRef as String: key]
        let status = SecItemAdd(addquery as CFDictionary, nil)
        guard status == errSecSuccess else { return }
    }
    
    func retrieveToken(user: String) -> SecKey? {
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: user,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else { return nil}
        let key = item as! SecKey
        
        return key
    }
}
