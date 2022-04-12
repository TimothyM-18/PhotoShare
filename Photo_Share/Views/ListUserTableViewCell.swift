//
//  ListUserTableViewCell.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 4/9/22.
//

import UIKit

class ListUserTableViewCell: UITableViewCell {

   static let identifier = "ListUserTableViewCell"
    
    private let profilePictureimageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(profilePictureimageView)
        contentView.addSubview(usernameLabel)
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        usernameLabel.sizeToFit()
        let size: CGFloat = contentView.height/1.3
        profilePictureimageView.frame = CGRect(x: 5, y: (contentView.height-size)/2, width: size, height: size)
        profilePictureimageView.layer.cornerRadius = size/2
        usernameLabel.frame = CGRect(x: profilePictureimageView.right+10, y: 0, width: usernameLabel.width, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        profilePictureimageView.image = nil
    }
    
    func configure(with viewModel: ListUserTableViewCellModel) {
        usernameLabel.text = viewModel.username
        StorageManager.shared.profilePicDownloadURL(for: viewModel.username) { [weak self] url in
            
            DispatchQueue.main.async {
                self?.profilePictureimageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
}
