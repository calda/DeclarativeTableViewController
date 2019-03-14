//
//  LoadingIndicatorCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit

public class LoadingIndicatorCell: UITableViewCell {
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    public init(height: CGFloat = 140) {
        super.init(style: .default, reuseIdentifier: nil)
        
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: height),
            contentView.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: activityIndicator.centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
