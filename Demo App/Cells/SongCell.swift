//
//  SongCell.swift
//  Demo App
//
//  Created by Cal Stephens on 3/13/19.
//  Copyright © 2019 Cal Stephens. All rights reserved.
//


// MARK: - SongCell

class SongCell: UITableViewCell, DequeueableCell {
    
    typealias ModelType = Song
    
    private let albumArtView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(_ song: Song) {
        titleLabel.text = song.title
        subtitleLabel.text = song.artist
        albumArtView.image = song.albumArt
    }
    
    private func setupCell() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        albumArtView.layer.cornerRadius = 7
        albumArtView.layer.masksToBounds = true
        
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 3
        textStackView.alignment = .leading
        
        let horizontalStackView = UIStackView(arrangedSubviews: [albumArtView, textStackView])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.spacing = 12
        horizontalStackView.alignment = .center
        contentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            albumArtView.heightAnchor.constraint(equalToConstant: 60),
            albumArtView.widthAnchor.constraint(equalToConstant: 60),
            
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
}

