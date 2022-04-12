//
//  PostViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import UIKit

class PostViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let post: Post
    
    private var collectionView: UICollectionView?
    
    private var viewModels: [SingePostCellType] = []
    

    
    let owner: String
    
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    
    init(post: Post, owner: String) {
        self.owner = owner
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    private let commentBarView = CommentBarView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPost()
        view.addSubview(commentBarView)
        commentBarView.delegate = self
        observeKeyboardChange()
    }
    
    private func observeKeyboardChange() {
       observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
                return
            }
            UIView.animate(withDuration:0.2) {
                self.commentBarView.frame = CGRect(x: 0, y: self.view.height-60-height, width: self.view.width, height: 70)
            }
            
        }
        
        hideObserver = NotificationCenter.default.addObserver(
             forName: UIResponder.keyboardWillHideNotification,
             object: nil,
             queue: .main) { _ in

             UIView.animate(withDuration:0.2) {
                self.commentBarView.frame = CGRect(x: 0, y: self.view.height-self.view.safeAreaInsets.bottom-80, width: self.view.width, height: 70)
             }

         }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        commentBarView.frame = CGRect(x: 0, y: view.height-view.safeAreaInsets.bottom-80, width: view.width, height: 70)
    }

    

    private func fetchPost() {
        
       let username = owner
        
        DatabaseManager.shared.getPost(with: post.identfier, from: username) { post in
            guard let post = post else {
                return
            }
            self.createViewModel(model: post, username: username, completion: { success in
                guard success else {
                  print("Failed to create VM")
                    return
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
                
                
            })
        }
    }
    
    private func createViewModel(model: Post, username: String, completion: @escaping (Bool) -> Void) {
        StorageManager.shared.downloadURL(for: model) { postURL in
            StorageManager.shared.profilePicDownloadURL(for: username) { [weak self] profilePictureURL in
                guard let strongSelf = self, let postUrl = postURL, let profilePictureURL = profilePictureURL else {
                    completion(false)
                    return
                }
                
                DatabaseManager.shared.getComments(postID: strongSelf.post.identfier, owner: strongSelf.owner) { comments in
                    
                    let isLiked = model.likers.contains(username)
                    var postData: [SingePostCellType] = [ .poster(viewModel: PosterCollectionViewCellViewModel(username: username, profilePictureURL: profilePictureURL)),
                                                         .post(viewModel: PostCollectionViewCellViewModel(postUrl: postUrl)),
                                                         .actions(viewModel: PostActionsCollectionViewCellModel(isLiked: isLiked)),
                                                         .likeCount(viewModel: PostLikesCollectionViewCellViewModel(likers: model.likers)),
                                                         .caption(viewModel: PostCaptionCollectionViewCellModel(username: username, caption: model.caption)),
                                                         ]
                    
                    if let comment = comments.first {
                        postData.append(.comment(viewModel: comment))
                    }
                    
                    postData.append(.timeStamp(viewModel: PostDatetimeCollectionViewCellModel(date: DateFormatter.formatter.date(from: model.postedDate) ?? Date())))
                   
                    self?.viewModels = postData
                    completion(true)

                }
            }
        }
    }
        

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cellType = viewModels[indexPath.row]
        
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
        
        case .comment(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.identifier, for: indexPath) as? CommentCollectionViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            return cell
        }
    }
}

extension PostViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool) {
        
    }
    
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
        commentBarView.field.becomeFirstResponder()
    }
}


extension PostViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: post.identfier,
            owner: owner) { success in
            guard success else {
                return
            }
        }
    }
    
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: isLiked ? .like : .unlike,
            postID: post.identfier,
            owner: owner) { success in
            guard success else {
                return
            }
        }
    }
}

extension PostViewController: PosterCollectionViewCellDelegate {
    func posterCollectionViewDidTapUsername(_ cell: PosterCollectionViewCell) {
        
        print("tapped username")
        
        let vc = ProfileViewController(user: User(username: "Timothy", email: "timothy@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PostViewController {
    func configureCollectionView() {
        
        let height: CGFloat  = 370 + view.width
        
        let collectionView =  UICollectionView(
            
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {index, _ -> NSCollectionLayoutSection? in
                
                let posterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)))
                
                let postItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
                
                let actionsItems = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
                
                let likeCountItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
                let captionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)))
                
                let commentItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)))
                
                let timeStampItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [posterItem, postItem, actionsItems, likeCountItem, captionItem, commentItem, timeStampItem])
               
                
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
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: CommentCollectionViewCell.identifier)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.collectionView = collectionView
    }
}


extension PostViewController: CommentBarViewDelagate {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String) {
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        DatabaseManager.shared.createComments(
            comment: Comment(username: currentUsername, comment: text, dateString: String.date(from: Date()) ?? ""),
            postID: post.identfier,
            owner: owner
        ) { success in
            DispatchQueue.main.async {
                guard success else {
                    return
                }
            }
            
        }
    }
}


