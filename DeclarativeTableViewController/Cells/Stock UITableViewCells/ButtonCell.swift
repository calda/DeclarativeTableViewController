//
//  ButtonCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - Button Cell

class ButtonCell: UITableViewCell {
    
    var title: String {
        didSet {
            titleLabel.text = title
        }
    }
    
    enum Style {
        case `default`
        case destructive
    }
    
    var buttonTappedHandler: () -> Void
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        
        label.textColor = UIApplication.shared.keyWindow?.tintColor
            ?? UIButton(type: .system).tintColor
        
        return label
    }()
    
    fileprivate let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    init(title: String, style: Style = .default, handler: @escaping () -> Void) {
        self.title = title
        self.buttonTappedHandler = handler
        super.init(style: .default, reuseIdentifier: nil)
        
        titleLabel.text = title
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityIndicator)
        accessoryType = .disclosureIndicator
        
        switch style {
        case .default:
            break
        case .destructive:
            titleLabel.textColor = .red
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -50),
            
            activityIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    convenience init(title: String, style: Style = .default, handler: @escaping (ButtonCell) -> Void) {
        self.init(title: title, style: style, handler: {})
        self.buttonTappedHandler = { [weak self] in
            guard let self = self else { return }
            handler(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showActivityIndicator() {
        self.accessoryType = .none
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        self.accessoryType = .disclosureIndicator
        activityIndicator.stopAnimating()
    }
    
}

extension ButtonCell: SelectableCell {
    
    var isCurrentlySelectable: Bool {
        return !activityIndicator.isAnimating
    }
    
    func handleSelection() {
        buttonTappedHandler()
    }
    
}

