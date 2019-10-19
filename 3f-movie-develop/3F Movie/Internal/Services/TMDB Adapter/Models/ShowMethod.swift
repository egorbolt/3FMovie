//
//  ShowMethod.swift
//  3F Movie
//
//  Created by stud on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

enum ShowMethod {
    case trending
    case nowPlaying
    case popular
    case topRated
    case upcoming
    
    // (idFilm)
    case actors(Int)
    case crew(Int)
    case genre(Genre)
    
    // (data, title of controller)
    case moviesData([ShowAllData], String)
}
