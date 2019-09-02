//
//  ButtonCell.swift
//  DeclarativeTableViewController
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - Button Cell

public class ButtonCell: UITableViewCell {
    
    public enum Style {
        case `default`
        case destructive
    }
    
    public var title: String {
        didSet {
            updateTitleLabel()
        }
    }
    
    public var style: Style {
        didSet {
            updateTitleLabel()
        }
    }
    
    public var buttonTappedHandler: () -> Void
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    fileprivate let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    public init(title: String, style: Style = .default, handler: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.buttonTappedHandler = handler
        super.init(style: .default, reuseIdentifier: nil)
        
        titleLabel.text = title
        contentView.addSubview(titleLabel)
        contentView.addSubview(activityIndicator)
        accessoryType = .disclosureIndicator
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -50),
            
            activityIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        updateTitleLabel()
    }
    
    public convenience init(title: String, style: Style = .default, handler: @escaping (ButtonCell) -> Void) {
        self.init(title: title, style: style, handler: {})
        self.buttonTappedHandler = { [weak self] in
            guard let self = self else { return }
            handler(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateTitleLabel() {
        titleLabel.text = title
        
        switch style {
        case .default:
            titleLabel.textColor = UIApplication.shared.windows.first?.tintColor
                ?? UIButton(type: .system).tintColor
        case .destructive:
            titleLabel.textColor = .red
        }
    }
    
    public func showActivityIndicator() {
        self.accessoryType = .none
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicator() {
        self.accessoryType = .disclosureIndicator
        activityIndicator.stopAnimating()
    }
    
}

extension ButtonCell: SelectableCell {
    
    public var isCurrentlySelectable: Bool {
        return !activityIndicator.isAnimating
    }
    
    public func handleSelection() {
        buttonTappedHandler()
    }
    
}

