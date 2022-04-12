//
//  SinglePostCellType.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 4/11/22.
//

import Foundation

enum SingePostCellType {
    
    case poster(viewModel: PosterCollectionViewCellViewModel)
    case post(viewModel: PostCollectionViewCellViewModel)
    case actions(viewModel: PostActionsCollectionViewCellModel)
    case likeCount(viewModel: PostLikesCollectionViewCellViewModel)
    case caption(viewModel: PostCaptionCollectionViewCellModel)
    case timeStamp(viewModel: PostDatetimeCollectionViewCellModel)
    case comment(viewModel: Comment)
}
