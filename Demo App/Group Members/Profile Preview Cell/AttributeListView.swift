//
//  AttributeListView.swift
//  Window
//
//  Created by Cal Stephens on 2/1/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//

import UIKit


// MARK: - Attribute

struct Attribute {
    
    static func location(_ placeName: String) -> Attribute {
        return Attribute(.location, placeName)
    }
    
    static func memberCount(_ memberCount: Int) -> Attribute {
        return Attribute(.memberCount, memberCount == 1 ? "1 member" : "\(memberCount) members")
    }
    
    static func dateJoined(_ date: Date) -> Attribute {
        return Attribute(.date, "Joined \(monthYearDateFormatter.string(from: date))")
    }
    
    static func dateCreated(_ date: Date) -> Attribute {
        return Attribute(.date, "Created \(monthYearDateFormatter.string(from: date))")
    }
    
    private static let monthYearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM y"
        return formatter
    }()
    
    
    // MARK: Instance
    
    enum Kind: Equatable {
        case location
        case date
        case memberCount
        case groupOwner
        
        var image: UIImage {
            switch self {
            case .location: return #imageLiteral(resourceName: "Attribute Icons/Location")
            case .date: return #imageLiteral(resourceName: "Attribute Icons/Date")
            case .memberCount: return #imageLiteral(resourceName: "Attribute Icons/Members")
            case .groupOwner: return #imageLiteral(resourceName: "Attribute Icons/Owner")
            }
        }
    }
    
    let kind: Kind
    let value: String
    
    private init(_ kind: Kind, _ value: String) {
        self.kind = kind
        self.value = value
    }
    
}


// MARK: - AttributeListView

class AttributeListView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        addSubviewAndConstrainToEqualSize(stackView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(_ attributes: [Attribute]) {
        // toss out the extra AttributeViews that we don't need anymore (if there are too many)
        if attributes.count < stackView.arrangedSubviews.count {
            stackView.arrangedSubviews[attributes.count...].forEach {
                stackView.removeArrangedSubview($0)
            }
        }
        
        // display each attribute in an existing view, or create a new one if there aren't enough
        for (index, attribute) in attributes.enumerated() {
            if index < stackView.arrangedSubviews.count,
                let existingAttributeView = stackView.arrangedSubviews[index] as? AttributeView
            {
                existingAttributeView.display(attribute)
            }
            
            else {
                let newAttributeView = AttributeView()
                newAttributeView.display(attribute)
                stackView.addArrangedSubview(newAttributeView)
            }
        }
    }
    
}


// MARK: - AttributeView

private class AttributeView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 3
        stackView.alignment = .center
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.tintColor = UIColor.darkText.withAlphaComponent(0.4)
        imageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkText.withAlphaComponent(0.4)
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        addSubviewAndConstrainToEqualSize(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
    }
    
    func display(_ attribute: Attribute) {
        imageView.image = attribute.kind.image
        label.text = attribute.value
    }
    
}
