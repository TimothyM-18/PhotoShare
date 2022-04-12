//
//  SettingsViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        createTableFooter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        
        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        
        tableView.tableFooterView = footer
        
    }
    
    @objc func didTapClose() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            AuthManager.shared.signOut(completion: { success in
                
                    if success {
                        DispatchQueue.main.async {
                            let vc = SignInViewController()
                            let navVC = UINavigationController(rootViewController: vc)
                            navVC.modalPresentationStyle = .fullScreen
                            self?.present(navVC, animated: true)
                        }
                     
                    }
                    else {
                        fatalError("Could Not Log Out User")
                    }
                
            })
        }))
        
        present(actionSheet, animated: true)
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        return UITableViewCell()
    }
}
