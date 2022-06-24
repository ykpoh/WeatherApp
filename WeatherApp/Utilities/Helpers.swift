//
//  Constant.swift
//  WeatherApp
//
//  Created by YK Poh on 22/06/2022.
//

import UIKit

class Constant {
    static let updateLocationNotification = NSNotification.Name("UpdateLocation")
    static let userInfoLocation = "location"
}

class Cache {
    static let locationResultCache = NSCache<AnyObject, AnyObject>()
    static let imageCache = NSCache<AnyObject, AnyObject>()
}

extension UIViewController {
    func showAlert( _ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
