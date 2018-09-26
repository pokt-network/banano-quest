//
//  UIApplication+extension.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication{
    public typealias PresentVCCompletionHandler = (_: UIViewController?) -> Void

    class func getPresentedViewController(handler: @escaping PresentVCCompletionHandler) {

        DispatchQueue.main.async {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                if let _ = rootVC as? UINavigationController {
                    if let vc = rootVC.children.last {
                        handler(vc)
                    }
                }else {
                    handler(rootVC)
                }
            }else {
                handler(nil)
            }
        }
    }
}
