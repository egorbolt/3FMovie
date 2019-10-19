//
//  Actor.swift
//  3F Movie
//
//  Created by Anton Kovalenko on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

struct Actor: Codable {
    let cast_id: Int
    let character: String
    let credit_id: String
    let gender: Int?
    let id: Int
    let name: String
    let order: Int
    let profile_path: String?
}

