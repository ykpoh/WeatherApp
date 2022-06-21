//
//  UIViewController+Extensions.swift
//  WeatherApp
//
//  Created by YK Poh on 21/06/2022.
//

import UIKit

extension UIViewController {
    func showAlert( _ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
