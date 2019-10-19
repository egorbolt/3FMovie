//
//  Constants.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

internal enum Constants {
    
    internal enum StoryboardNames {
    }
    
    
    internal enum StoryboardIDs {
        internal static let showAllControllerID = "ShowAllController"
        internal static let movieControllerID = "MovieController"
        internal static let actorControllerID = "PersonController"
        internal static let searchTableViewCeontrollerID = "SearchTableView"
    }
    
    
    internal enum NibNames {
        internal static let collectionViewWithTitle = "CollectionViewWithTitle"
        internal static let nowPlayingPoster = "NowPlayingPoster"
        internal static let nowPlayingSection = "NowPlayingSection"
        internal static let trendingCellNib = "TrendingCell"
        internal static let genresCellNib = "GenresCell"
    }
    
    
    internal enum CellReuseIdentifiers {
        internal static let imageCell = "ImageCell"
        internal static let personCell = "PersonCell"
        internal static let showAllCell = "ShowAllCell"
        internal static let trendingCell = "TrendingCell"
        internal static let genresCell = "GenresCell"
    }
    
    
    internal enum PicturesNames {
        internal enum TabBarIconNames {
            internal static let explore = "Tab Bar Icons/Explore"
            internal static let find = "Tab Bar Icons/Search"
            internal static let randomMovie = "Tab Bar Icons/Random Movie"
            internal static let list = "Tab Bar Icons/Lists"
        }
    }
    
}
