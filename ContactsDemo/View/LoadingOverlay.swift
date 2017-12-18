//
//  LoadingOverlay.swift
//  iJewel
//
//  Created by hemant on 7/2/16.
//  Copyright © 2016 Diaspark. All rights reserved.
//

import Foundation
import UIKit

open class LoadingOverlay{
    
    var overlayView : UIView!
    var activityIndicator : UIActivityIndicatorView!
    var titleLabel : UILabel!
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    init(){
        self.overlayView = UIView()
        self.titleLabel = UILabel()

        self.activityIndicator = UIActivityIndicatorView()
       
        overlayView.frame =  CGRect(x: 0, y: 0, width: 150, height: 120)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.layer.zPosition = 1
        
        activityIndicator.frame =  CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2,y :overlayView.bounds.height / 2) 
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        titleLabel.frame =  CGRect(x: 0, y: 10, width: 150, height: 25)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = "Please wait..."
        titleLabel.textColor = UIColor.white
        overlayView.addSubview(titleLabel)

        overlayView.addSubview(activityIndicator)
    }
    
    open func showOverlay(_ view: UIView) {
        overlayView.center = view.center
        view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }
    
    open func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
