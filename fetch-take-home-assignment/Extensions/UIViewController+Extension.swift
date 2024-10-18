//
//  UIViewController+Extension.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/17/24.
//

import UIKit
import SafariServices

extension UIViewController {
    func showWebView(_ urlString: String) {
        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true)
        }
    }
}
