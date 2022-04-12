//
//  PosterCollectionViewCell.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/28/22.
//

import SDWebImage
import UIKit

protocol PosterCollectionViewCellDelegate: AnyObject {
    func posterCollectionViewDidTapUsername(_ cell: PosterCollectionViewCell)
}

final class PosterCollectionViewCell: UICollectionViewCell {
    static let identifier = "PosterCollectionViewCell"
    
    weak var delegate: PosterCollectionViewCellDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        let tap = UIGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapMore() {
        
    }
    
    @objc func didTapUsername() {
        delegate?.posterCollectionViewDidTapUsername(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-4
        imageView.frame = CGRect(x: 2, y: 2, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: imageView.right+10, y: 0, width: usernameLabel.width, height: contentView.height)
        moreButton.frame = CGRect(x: contentView.width-60, y: (contentView.height-50)/2, width: 50, height: 50)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        imageView.image = nil
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel) {
        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
    }
}
