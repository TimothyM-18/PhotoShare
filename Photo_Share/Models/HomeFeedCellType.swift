//
//  HomeFeedCellType.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/28/22.
//

import Foundation

enum HomeFeedCellType {
    
    case poster(viewModel: PosterCollectionViewCellViewModel)
    case post(viewModel: PostCollectionViewCellViewModel)
    case actions(viewModel: PostActionsCollectionViewCellModel)
    case likeCount(viewModel: PostLikesCollectionViewCellViewModel)
    case caption(viewModel: PostCaptionCollectionViewCellModel)
    case timeStamp(viewModel: PostDatetimeCollectionViewCellModel)
    
}


