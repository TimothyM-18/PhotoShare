//
//  ProfileViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class ProfileViewController: UIViewController {

    private var collectionView: UICollectionView?

    private let user: User
    
    private var headerViewModel: ProfileHeaderViewModel?
    
    private var posts: [Post] = []
    
    private var observere: NSObjectProtocol?
    
    private var isCurrentUser: Bool {
        
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
        
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName:nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        configurNavBar()
        configureCollectionView()
        fetchProfileInfo()
        
        if isCurrentUser {
            observere = NotificationCenter.default.addObserver(forName: .didPostNotification, object: nil, queue: .main) { [weak self] _ in
                self?.posts.removeAll()
                self?.fetchProfileInfo()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    private func fetchProfileInfo() {
        let username = user.username
        
        let group = DispatchGroup()
        
        
        group.enter()
        DatabaseManager.shared.posts(for: username) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let posts):
                self?.posts = posts
            case .failure:
                break
            }
        }
        
        var profilePictureUrl: URL?
        var buttonType: ProfileButtonType = .edit
        var followers = 0
        var posts = 0
        var name: String?
        var bio: String?
         
        
        
        group.enter()
        
        //profile picture
        StorageManager.shared.profilePicDownloadURL(for: user.username) { url in
            defer {
                group.leave()
            }
            profilePictureUrl = url
        }
        
        DatabaseManager.shared.getUserInfo(username: user.username) { userInfo in
            name = userInfo?.name
            bio = userInfo?.bio
        }
        
        if !isCurrentUser {
            buttonType = .follow(isFollowing: false)
        }
        
        group.notify(queue: .main) {
            self.headerViewModel = ProfileHeaderViewModel(profilePictureUrl: profilePictureUrl,
                                                    followerCount: followers,
                                                    followingICount: 0,
                                                    postCount: 5,
                                                    buttonType: buttonType,
                                                    name: name,
                                                    bio: bio)
            self.collectionView?.reloadData()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    private func configurNavBar() {
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettingsButton))
        }
    }
    

    @objc private func didTapSettingsButton() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension ProfileViewController {
    
    private func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
        
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize:  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3)),
                                                           subitem: item, count: 3)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
            
            return section
        }))
        
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.register(ProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        self.collectionView = collectionView
    }
}


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier, for: indexPath) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        
        if let viewModel = headerViewModel {
            headerView.configure(with: viewModel)
            headerView.countContainerView.delegate = self
        }
       
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post, owner: user.username)
        navigationController?.pushViewController(vc, animated: true)
    }
}
    
extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCountViewDidtapFriends(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .friends(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCountViewDidtapPosts(_ containerView: ProfileHeaderCountView) {
        guard posts.count >= 12 else {
            return
        }
        collectionView?.setContentOffset(CGPoint(x: 0, y: view.width * 0.4), animated: true)
    }
    
    func profileHeaderCountViewDidtapEditProfile(_ containerView: ProfileHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = { [weak self] in
            self?.headerViewModel = nil
            self?.fetchProfileInfo() 
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func profileHeaderCountViewDidtapAddFriend(_ containerView: ProfileHeaderCountView) {
        
    }
    
    func profileHeaderCountViewDidtapRemoveFriend(_ containerView: ProfileHeaderCountView) {
        
    }
    
    
}
