//
//  SongCell.swift
//  Demo App
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//


// MARK: - SongCell

class SongCell: UITableViewCell, ReusableCell {

    
    // MARK: ReusableCell
    
    typealias ModelType = ViewModel
    
    struct ViewModel: Hashable {
        let song: Song
        let isCurrentlyPlaying: Bool
    }
    
    func display(_ model: ViewModel) {
        titleLabel.text = model.song.title
        subtitleLabel.text = model.song.artist
        albumArtView.image = model.song.albumArt
        
        if model.isCurrentlyPlaying {
            pauseIcon.isHidden = false
        } else {
            pauseIcon.isHidden = true
        }
    }
    
    
    // MARK: Instance Setup
    
    private let albumArtView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pauseIcon = UIImageView(image: #imageLiteral(resourceName: "Pause"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupCell() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = titleLabel.textColor.withAlphaComponent(0.75)
        albumArtView.layer.cornerRadius = 7
        albumArtView.layer.masksToBounds = true
        
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 3
        textStackView.alignment = .leading
        
        let horizontalStackView = UIStackView(arrangedSubviews: [albumArtView, textStackView, pauseIcon])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.spacing = 12
        horizontalStackView.alignment = .center
        contentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            albumArtView.heightAnchor.constraint(equalToConstant: 60),
            albumArtView.widthAnchor.constraint(equalToConstant: 60),
            
            pauseIcon.heightAnchor.constraint(equalToConstant: 25),
            pauseIcon.widthAnchor.constraint(equalToConstant: 25),
            
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
}

