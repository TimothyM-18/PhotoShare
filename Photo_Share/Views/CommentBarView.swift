//
//  CommentBarView.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 4/10/22.
//

import UIKit

protocol CommentBarViewDelagate: AnyObject {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String)
}

class CommentBarView: UIView, UITextFieldDelegate {

    weak var delegate: CommentBarViewDelagate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    
    let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Comment"
        field.backgroundColor = .tertiarySystemBackground
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(field)
        addSubview(button)
        field.delegate = self
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapComment() {
        guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        delegate?.commentBarViewDidTapDone(self, withText: text)
        field.resignFirstResponder()
        field.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.sizeToFit()
        button.frame = CGRect(x: width-button.width-4-2, y: (height-button.height)/2, width: button.width+4, height: button.height)
        field.frame = CGRect(x: 2, y: (height-50)/2, width: width-button.width-8, height: 50)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        didTapComment()
        return true
    }
}
