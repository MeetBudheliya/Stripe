//
//  loadingView.swift
//  StripePay
//
//  Created by Adsum MAC 1 on 15/04/21.
//

import UIKit
public class LoadingOverlay{

var overlayView = UIView()
var activityIndicator = UIActivityIndicatorView()

class var shared: LoadingOverlay {
    struct Static {
        static let instance: LoadingOverlay = LoadingOverlay()
    }
    return Static.instance
}

    public func showOverlay(view: UIView) {

        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.center = view.center
        overlayView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10

        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .large
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)

        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)

        activityIndicator.startAnimating()
    }

    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
