//
//  UIView Constraint Helpers.swift
//  Demo App
//
//  Created by Cal Stephens on 3/14/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviewAndConstrainToEqualSize(
        _ subview: UIView,
        with insets: UIEdgeInsets = .zero)
    {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
        ])
    }
    
}
