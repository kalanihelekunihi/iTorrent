//
//  AppDelegate+UserNotificationCenter.swift
//  iTorrent
//
//  Created by Daniil Vinogradov on 14.06.2020.
//  Copyright © 2020  XITRIX. All rights reserved.
//

import UIKit

extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let hash = response.notification.request.content.userInfo["hash"] as? String {
            if hash == "RSS" {
                return
            }

            if Core.shared.state != .InProgress {
                DispatchQueue.global(qos: .background).async {
                    while Core.shared.state != .InProgress {
                        sleep(1)
                    }
                    DispatchQueue.main.async {
                        self.openTorrentDetailsViewController(withHash: hash, sender: self)
                    }
                }
            } else {
                openTorrentDetailsViewController(withHash: hash, sender: self)
            }
        }
        completionHandler()
    }

    func openTorrentDetailsViewController(withHash hash: String, sender: Any) {
        if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? UISplitViewController,
            let viewController = Utils.mainStoryboard.instantiateViewController(withIdentifier: "Detail") as? TorrentDetailsController {
            viewController.managerHash = hash
            if !splitViewController.isCollapsed {
                if splitViewController.viewControllers.count > 1,
                    let nvc = splitViewController.viewControllers[1] as? UINavigationController {
                    nvc.show(viewController, sender: sender)
                } else {
                    let navController = Utils.instantiateNavigationController(viewController)
                    navController.isToolbarHidden = false
                    splitViewController.showDetailViewController(navController, sender: sender)
                }
            } else {
                splitViewController.showDetailViewController(viewController, sender: sender)
            }
        }
    }
}
