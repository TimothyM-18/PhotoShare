//
//  ViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var collectionView: UICollectionView?
    
    private var viewModels = [[HomeFeedCellType]]()
    
    private var observere: NSObjectProtocol?
    
    private var allPosts: [(post: Post, owner: String)] = []
    
    private var postsCount: [Post] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Share"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
        
        observere = NotificationCenter.default.addObserver(forName: .didPostNotification, object: nil, queue: .main) { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchPosts()
        }
        
    }
    
    private func fetchPosts() {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        var allPosts: [(post: Post, owner: String)] = []
        var postsCount: [Post] = []
        
        DatabaseManager.shared.posts(for: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    
                    self?.allPosts = allPosts
                    self?.postsCount = posts
                    let group = DispatchGroup()
                    
                    posts.forEach { model in
                        group.enter()
                        self?.createViewModel(model: model, username: username, completion: { success in
                            defer {
                                group.leave()
                            }
                            
                            if !success {
                              print("Failed to create VM")
                            }
                        })
                    }
                    
                    group.notify(queue: .main) {
                        self?.viewModels = (self?.viewModels.sorted(by: { first, second in
                            var date1: Date?
                            var date2: Date?
                            first.forEach { type in
                                switch type {
                                case .timeStamp(let vm):
                                    date1 = vm.date
                                default:
                                    break
                                }
                            }
                            second.forEach { type in
                                switch type {
                                case .timeStamp(let vm):
                                    date2 = vm.date
                                default:
                                    break
                                }
                            }
                            
                            if let date1 = date1, let date2 = date2 {
                                return date1 > date2
                            }
                            
                            return false
                        }))!
                        self?.collectionView?.reloadData()
                    }
                case .failure(_):
                    fatalError()
                }
            }
        }
    }
    
    private func createViewModel(model: Post, username: String, completion: @escaping (Bool) -> Void) {
        StorageManager.shared.downloadURL(for: model) { postURL in
            guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
            
            StorageManager.shared.profilePicDownloadURL(for: username) { [weak self] profilePictureURL in
                guard let postUrl = postURL, let profilePictureURL = profilePictureURL else {
                    
                    return
                }
                let isLiked = model.likers.contains(username)
                let postData: [HomeFeedCellType] = [ .poster(viewModel: PosterCollectionViewCellViewModel(username: username, profilePictureURL: profilePictureURL)),
                                                     .post(viewModel: PostCollectionViewCellViewModel(postUrl: postUrl)),
                                                     .actions(viewModel: PostActionsCollectionViewCellModel(isLiked: isLiked)),
                                                     .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: model.likers)),
                                                     .caption(viewModel: PostCaptionCollectionViewCellModel(username: username, caption: model.caption)),
                                                     .timeStamp(viewModel: PostDatetimeCollectionViewCellModel(date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()))
                ]
                self?.viewModels.append(postData)
                completion(true)
            }
        }
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cellType = viewModels[indexPath.section][indexPath.row]
        
        switch cellType {
        
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as? PosterCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
            
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
            return cell
            
        case .actions(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionsCollectionViewCell.identifier, for: indexPath) as? PostActionsCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.configure(with: viewModel)
            return cell
            
        case .likeCount(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLikesCollectionViewCell.identifier, for: indexPath) as? PostLikesCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
            
        case .caption(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCaptionCollectionViewCell.identifier, for: indexPath) as? PostCaptionCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
            
        case .timeStamp(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostDateTimeCollectionViewCell.identifier, for: indexPath) as? PostDateTimeCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
        
    }
}

extension HomeViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool) {
//        let vc = ListViewController(type: .likers(usernames: []))
//        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
        
    }
    
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let post = postsCount[index]
        
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: post.identfier,
            owner: username) { success in
            guard success else {
                return
            }
        }
    }
    
//    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
//        let tuple = allPosts[index]
//        let vc = PostViewController(post: tuple.post, owner: tuple.owner)
//        vc.title = "Post"
//        navigationController?.pushViewController(vc, animated: true)
//    }
}


extension HomeViewController: PostCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let post = postsCount[index]
        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like : .unlike,
            postID: post.identfier,
            owner: username) { success in
            guard success else {
                return
            }
        }
    }
}

extension HomeViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewDidTapUsername(_ cell: PosterCollectionViewCell) {
        
        print("tapped username")
        
        let vc = ProfileViewController(user: User(username: "Timothy", email: "timothy@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController {
    func configureCollectionView() {
        
        let height: CGFloat  = 240 + view.width
        
        let collectionView =  UICollectionView(
            
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {index, _ -> NSCollectionLayoutSection? in
                
                let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)))
                
                let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
                
                let actionsItems = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
                
                let likeCountItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
                let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)))
                let timeStampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [posterItem, postItem, actionsItems, likeCountItem, captionItem, timeStampItem])
               
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                return NSCollectionLayoutSection(group: group)
            })
        )
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        collectionView.register(PosterCollectionViewCell.self, forCellWithReuseIdentifier: PosterCollectionViewCell.identifier)
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(PostActionsCollectionViewCell.self, forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifier)
        collectionView.register(PostLikesCollectionViewCell.self, forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier)
        collectionView.register(PostCaptionCollectionViewCell.self, forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier)
        collectionView.register(PostDateTimeCollectionViewCell.self, forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifier)
  
        self.collectionView = collectionView
    }
}
