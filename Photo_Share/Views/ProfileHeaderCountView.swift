//
//  ProfileHeaderCountView.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 3/26/22.
//

import UIKit

protocol ProfileHeaderCountViewDelegate: AnyObject {
    func profileHeaderCountViewDidtapFriends(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidtapPosts(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidtapEditProfile(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidtapAddFriend(_ containerView: ProfileHeaderCountView)
    func profileHeaderCountViewDidtapRemoveFriend(_ containerView: ProfileHeaderCountView)
}

class ProfileHeaderCountView: UIView {
    
    weak var delegate: ProfileHeaderCountViewDelegate?
    
    private var action = ProfileButtonType.edit

    private let followerCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
        
    }()
    
    private let postCountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
        
    }()
    
    private var isFollowing = false
    
    private let actionButton = PSFollowButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(followerCountButton)
        addSubview(postCountButton)
        addSubview(actionButton)
        
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addActions() {
        followerCountButton.addTarget(self, action: #selector(didTapFriends), for: .touchUpInside)
        postCountButton.addTarget(self, action: #selector(didTapPosts), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    // Actions
    @objc func didTapFriends() {
        delegate?.profileHeaderCountViewDidtapFriends(self)
    }
    
    @objc func didTapPosts() {
        delegate?.profileHeaderCountViewDidtapPosts(self)
    }
    
    @objc func didTapActionButton() {
        switch action {
        case.edit:
            delegate?.profileHeaderCountViewDidtapEditProfile(self)
        case .follow:
            
            if self.isFollowing {
                delegate?.profileHeaderCountViewDidtapRemoveFriend(self)
            }
            else {
                delegate?.profileHeaderCountViewDidtapAddFriend(self)
            }
            
            self.isFollowing = !isFollowing
            actionButton.configure(for: isFollowing ? .unfriend : .friend)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth: CGFloat = (width-15)/3
        followerCountButton.frame = CGRect(x: 5, y: 5, width: buttonWidth, height: height/2)
        postCountButton.frame = CGRect(x: followerCountButton.right + 100, y: 5, width: buttonWidth, height: height/2)
        actionButton.frame = CGRect(x: 5, y: height-42, width: width-10, height: 40)
    }
    
    func configure(with viewModel: ProfileHeaderCountViewModel) {
        followerCountButton.setTitle("Friends", for: .normal)
        postCountButton.setTitle("Posts", for: .normal)
        
        self.action = viewModel.actionType
        
        switch viewModel.actionType {
        case .edit:
            actionButton.backgroundColor = .systemBackground
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.label, for: .normal)
            actionButton.layer.borderWidth = 0.5
            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor

        case .follow(let isFollowing):
            self.isFollowing = isFollowing
            actionButton.configure(for: isFollowing ? .unfriend : .friend)
        }
    }
    
 
}
