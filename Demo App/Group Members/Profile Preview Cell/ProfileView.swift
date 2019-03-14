//
//  ProfileView.swift
//  Window
//
//  Created by Cal Stephens on 2/1/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - ProfileView

class ProfileView: UIView {
    
    private let imageViewShadowContainer: UIView = {
        let shadowContainer = UIView()
        shadowContainer.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60),
            cornerRadius: 30).cgPath
        
        shadowContainer.layer.shadowRadius = 3
        shadowContainer.layer.shadowOpacity = 0.185
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.masksToBounds = false
        shadowContainer.clipsToBounds = false
        return shadowContainer
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.layer.cornerRadius = 30
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 3
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 5
        return label
    }()
    
    private let attributesListView = AttributeListView()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 20
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        addSubviewAndConstrainToEqualSize(horizontalStackView)
        horizontalStackView.addArrangedSubview(imageViewShadowContainer)
        imageViewShadowContainer.addSubviewAndConstrainToEqualSize(imageView)
        horizontalStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(subtitleLabel)
        verticalStackView.addArrangedSubview(attributesListView)
        verticalStackView.setCustomSpacing(8, after: subtitleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func display(_ profile: ProfileDisplayable) {
        titleLabel.text = profile.name
        attributesListView.display(profile.attributes)
        imageView.image = profile.image
        
        if let subtitle = profile.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
    
}
