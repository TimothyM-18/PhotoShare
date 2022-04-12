//
//  ListViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class ListViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ListUserTableViewCell.self, forCellReuseIdentifier: ListUserTableViewCell.identifier)
    
        return tableView
    }()
    
    let type: ListType
    
    private var viewModels: [ListUserTableViewCellModel] = []
    
    // MARK: - Init
    
    enum ListType {
        case friends(user: User)
        case likers(usernames: [String])
        
        var title: String {
            switch self {
            case .friends:
                return "Friends"
            case .likers:
                return  "Liked By"
            }
        }
    }
    
    
    init(type: ListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        title = type.title
        tableView.delegate = self
        tableView.dataSource = self
        
        configureViewModels()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func configureViewModels() {
        switch type {
        case .likers(let usernames):
            viewModels = usernames.compactMap({
                ListUserTableViewCellModel(imageUrl: nil, username: $0)
            })
            tableView.reloadData()
        case .friends(let targetUser):
            DatabaseManager.shared.friends(for: targetUser.username) { [weak self] usernames in
                self?.viewModels = usernames.compactMap({
                    ListUserTableViewCellModel(imageUrl: nil, username: $0)
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListUserTableViewCell.identifier, for: indexPath) as? ListUserTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let username = viewModels[indexPath.row].username
        DatabaseManager.shared.findUser(with: username) { [weak self] user in
            if let user = user {
                DispatchQueue.main.async {
                    let vc = ProfileViewController(user: user)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
