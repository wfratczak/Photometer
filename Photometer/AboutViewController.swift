//
//  AboutViewController.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 10.12.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import UIKit
import FontAwesome_swift

class AboutViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var githubButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        let linkedInIcon = UIImage.fontAwesomeIcon(name: .linkedIn, textColor: UIColor.blue.withAlphaComponent(0.5), size: CGSize(width: 40, height: 40))
        let githubIcon = UIImage.fontAwesomeIcon(name: .github, textColor: UIColor.black.withAlphaComponent(0.5), size: CGSize(width: 40, height: 40))
        let facebookIcon = UIImage.fontAwesomeIcon(name: .facebook, textColor: UIColor.black.withAlphaComponent(0.5), size: CGSize(width: 40, height: 40))
        let mailIcon = UIImage.fontAwesomeIcon(name: .envelope, textColor: UIColor.black.withAlphaComponent(0.5), size: CGSize(width: 40, height: 40))
        linkedInButton.setImage(linkedInIcon, for: .normal)
        githubButton.setImage(githubIcon, for: .normal)
        facebookButton.setImage(facebookIcon, for: .normal)
        mailButton.setImage(mailIcon, for: .normal)
    }

    @IBAction func linkedInButtonAction(_ sender: AnyObject) {
        if let url = URL(string: "https://www.linkedin.com/in/wojciechfratczak") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func githubButtonAction(_ sender: AnyObject) {
        if let url = URL(string: "https://github.com/wfratczak") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func mailButtonAction(_ sender: AnyObject) {
        if let url = URL(string: "mailto:fratczak.wojciech@gmail.com") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func facebookButtonAction(_ sender: AnyObject) {
        if let url = URL(string: "https://www.facebook.com/wojciech.fratczak") {
            UIApplication.shared.openURL(url)
        }
    }
}
