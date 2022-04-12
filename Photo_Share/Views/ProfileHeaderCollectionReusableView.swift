//
//  ProfileHeaderCollectionReusableView.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 3/26/22.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public let countContainerView = ProfileHeaderCountView()
    
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "This is my profile file"
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countContainerView)

        addSubview(imageView)
        addSubview(bioLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        bioLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = width/3.5
        imageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize / 2
        countContainerView.frame = CGRect(x: imageView.right+5, y: 3, width: width-imageView.right-10, height: imageSize)
        
        let bioSize = bioLabel.sizeThatFits(bounds.size)
        bioLabel.frame = CGRect(x: 5, y: imageView.bottom+10, width: width.magnitude, height: bioSize.height+50)
    }
    
    public func configure(with viewModel: ProfileHeaderViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        
        text += viewModel.bio ?? "Welcome to My Profile!"
        bioLabel.text = text
        let containerViewModel = ProfileHeaderCountViewModel(friendsCount: viewModel.followerCount, postsCount: viewModel.postCount, actionType: viewModel.buttonType)
        countContainerView.configure(with: containerViewModel)
    }
    
    
    
}
