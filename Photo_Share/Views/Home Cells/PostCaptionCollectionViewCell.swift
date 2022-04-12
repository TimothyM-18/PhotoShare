//
//  PostCaptionCollectionViewCell.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/28/22.
//

import UIKit

class PostCaptionCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCaptionCollectionViewCell"
    
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.sizeThatFits(contentView.bounds.size)
        label.frame = CGRect(x: 12, y: 3, width: size.width-12, height: size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostCaptionCollectionViewCellModel) {
        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"
    }
}
