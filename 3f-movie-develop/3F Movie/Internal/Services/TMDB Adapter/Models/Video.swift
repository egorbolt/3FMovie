//
//  Video.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

struct Video: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let size: Int
    let type: String
}
