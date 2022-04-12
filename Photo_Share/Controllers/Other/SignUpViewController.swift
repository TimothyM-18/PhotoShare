//
//  SignUpViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 45
        return imageView
    }()
    
    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.becomeFirstResponder()
        field.layer.cornerRadius = 8
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email..."
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

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Create Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.isSecureTextEntry = true
        field.layer.cornerRadius = 8
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let signUpButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
       return button
    }()
    
    public var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(imageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        
        addButtonActions()
        addImageGesture()
        
    }
    
    private func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let imageSize: CGFloat = 90
        
        imageView.frame = CGRect(x: (view.width-imageSize)/2, y:view.safeAreaInsets.top + 15 , width: imageSize, height: imageSize)
        usernameField.frame = CGRect(x: 20, y: imageView.bottom + 20, width: view.width-40, height: 52.0)
        emailField.frame = CGRect(x: 20, y: usernameField.bottom+10, width: view.width-40, height: 52.0)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 52.0)
        signUpButton.frame = CGRect(x: 20, y: passwordField.bottom+10, width: view.width-40, height: 52.0)
    }
    
    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        
    }
    
    @objc func didTapImage() {
        let sheet = UIAlertController(title: "Profile Picture", message: "Set a picture for your profile", preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .camera
                picker.delegate = self
                self?.present(picker, animated: true)
            }
           
        }))
        
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {[weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        
        present(sheet, animated: true)
    }
    
    @objc func didTapSignUpButton() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        
        guard let username = usernameField.text, !username.isEmpty, let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            return
        }
        
        //var username: String?
//        var email: String?

//
//        // login functionality
//
//        if usernameEmail.contains("@"), usernameEmail.contains(".") {
//            // email
//            email = usernameEmail
//        }
//        else {
//            // username
//            username = usernameEmail
//
//        }
        let data = imageView.image?.pngData()
        
        AuthManager.shared.signUp(username: username, email: email, password: password, profilePicture: data) { [weak self ]result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    
                    UserDefaults.standard.setValue(user.email, forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.completion?()
                case .failure(let error):
                    print(error)
                }
            }
          
        }
    }
    
    
    private func signIn() {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            didTapSignUpButton()
        }
        
        return true
    }
    
    //
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = image
    }

}

