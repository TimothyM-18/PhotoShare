//
//  EditProfileViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 3/27/22.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    public var completion: (() -> Void)?
    
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Name..."
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.keyboardType = .emailAddress
        field.becomeFirstResponder()
        field.layer.cornerRadius = 8
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private var bioTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.backgroundColor = .secondarySystemBackground
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        view.addSubview(nameField)
        view.addSubview(bioTextView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                   style: .done,
                                                                   target: self,
                                                                   action: #selector(didTapSave))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        DatabaseManager.shared.getUserInfo(username: username) { [weak self] info in
            DispatchQueue.main.async {
                if let info = info {
                    self?.nameField.text = info.name
                    self?.bioTextView.text = info.bio
                }
            }
        }
                                                            
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameField.frame = CGRect(x: 20, y: view.safeAreaInsets.top+10, width: view.width-40, height: 50)
        bioTextView.frame = CGRect(x: 20, y: nameField.bottom+10, width: view.width-40, height: 50)
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapSave() {
        let name = nameField.text ?? ""
        let bio = bioTextView.text ?? ""
        let newInfo = UserInfo(name: name, bio: bio)
        DatabaseManager.shared.setUserInfo(userInfo: newInfo) { [weak self]success in
            DispatchQueue.main.async {
                if success {
                    self?.completion?()
                    self?.didTapClose()
                    
                }
            }
            
        }
    }

}
