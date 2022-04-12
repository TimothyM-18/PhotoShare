//
//  PSFollowButton.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 4/6/22.
//

import UIKit

final class PSFollowButton: UIButton {

    enum State: String {
        case friend = "Add Friend"
        case unfriend = "Unfriend"
        
        var titleColor: UIColor {
            switch self {
            case .friend: return .white
            case .unfriend: return .label
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .friend: return .systemBlue
            case .unfriend: return .tertiarySystemBackground
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(for state: State) {
        setTitle(state.rawValue, for: .normal)
        backgroundColor = state.backgroundColor
        setTitleColor(state.titleColor, for: .normal)
        
        switch state {
        case .friend:
            layer.borderWidth = 0
        case .unfriend:
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
}
