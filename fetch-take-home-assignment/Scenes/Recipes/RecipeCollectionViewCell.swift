//
//  RecipeCollectionViewCell.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/16/24.
//

import Combine
import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "RecipeCollectionViewCell"
    
    private var imageCancellable: AnyCancellable?
    
    var viewModel: RecipeCellViewModel?
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.photoPlaceholder
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .black.withAlphaComponent(0.5)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var topBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        titleLabel.text = viewModel?.recipe.name
        titleLabel.numberOfLines = 0
        
        subTitleLabel.text = viewModel?.recipe.cuisine
        imageCancellable = viewModel?.$image
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.imageView.image = image
            })
        
        viewModel?.loadImageData()
    }
    
    private func configureUI() {
        backgroundColor = .white
        
        layer.cornerRadius = 8
        layer.borderWidth = 0.0
        layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 1
        
        contentView.addSubview(topBar)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 108),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        imageView.image = UIImage.photoPlaceholder
        viewModel = nil
        imageCancellable = nil
    }
}
