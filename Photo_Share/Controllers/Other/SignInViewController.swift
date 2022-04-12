//
//  SignInViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon")
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username or Email..."
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
        field.placeholder = "Password"
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
    
    private let loginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
       return button
    }()
    
    private let createAccountButton: UIButton = {
       let button = UIButton()
       button.setTitleColor(.link, for: .normal)
       button.setTitle("Create an Account", for: .normal)
       return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(imageView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
        
        addButtonActions()
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/2)
        emailField.frame = CGRect(x: 25, y: imageView.bottom+20, width: view.width-50, height: 50)
        passwordField.frame = CGRect(x: 25, y: emailField.bottom + 10, width: view.width-50, height: 52.0)
        loginButton.frame = CGRect(x: 35, y: passwordField.bottom + 20, width: view.width-70, height: 52.0)
        createAccountButton.frame = CGRect(x: 25, y: loginButton.bottom + 10, width: view.width-50, height: 52.0)
    }
    
    private func addButtonActions() {
        loginButton.addTarget(self, action: #selector(didTapLogInButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
    }
    
    @objc func didTapLogInButton() {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        
        guard let usernameEmail = emailField.text, !usernameEmail.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            return
        }
        
//        var username: String?
//        var email: String?
//
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
        AuthManager.shared.signIn(email: usernameEmail, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let vc  = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                case .failure(let error):
                    print(error)
                }
            }
            
        }
    }
    
    @objc func didTapCreateAccountButton() {
        
        let vc = SignUpViewController()
       
        
        vc.completion = {
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self.present(tabVC, animated: true)
            }
        }
        

        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func signIn() {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            didTapLogInButton()
        }
        
        return true
    }

}

