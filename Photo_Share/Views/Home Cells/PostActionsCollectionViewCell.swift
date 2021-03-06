//
//  PostActionsCollectionViewCell.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/28/22.
//

import UIKit

protocol PostActionsCollectionViewCellDelegate: AnyObject {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int)
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell)
}

class PostActionsCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostActionsCollectionViewCell"
    
    weak var delegate: PostActionsCollectionViewCellDelegate?
    
    private var isLiked = false
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
        
    }()
    
    private var index = 0
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        
        let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        
        return button
        
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        
        let image = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        
        return button
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapLike() {
        if self.isLiked {
            let image = UIImage(systemName: "suit.heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .label
        }
        else {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
        
        delegate?.postActionsCollectionViewCellDidTapLike(self, isLiked: !isLiked, index: index)
        
        self.isLiked = !isLiked
    }
    
    @objc func didTapComment() {
        delegate?.postActionsCollectionViewCellDidTapComment(self)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size: CGFloat = contentView.height/1.15
        likeButton.frame = CGRect(x: 10, y: (contentView.height-size)/2, width: size, height: size)
        commentButton.frame = CGRect(x: likeButton.right + 12, y: (contentView.height-size)/2, width: size, height: size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostActionsCollectionViewCellModel) {
        
        isLiked = viewModel.isLiked
        
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
    }
}
