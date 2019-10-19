//
//  Image.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation


struct Image: Codable {
    let aspect_ratio: Float
    let file_path: String
    let height: Int
    let iso_639_1: String?
    let vote_average: Float
    let vote_count: Int
    let width: Int
}

struct PersonImagesInfo: Codable {
    let id: Int
    let profiles: [Image]
}
