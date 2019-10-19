//
//  Human.swift
//  3F Movie
//
//  Created by stud on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

struct Person: Codable {
    let birthday: String?
    let known_for_department: String
    let deathday: String?
    let id: Int
    let name: String
    let also_known_as: [String]
    let gender: Int
    let biography: String
    let popularity: Float
    let place_of_birth: String?
    let profile_path: String?
    let adult: Bool
    let imdb_id: String
    let homepage: String?
}

struct CrewPerson: Codable {
    let credit_id: String
    let department: String
    let gender: Int?
    let id: Int
    let job: String
    let name: String
    let profile_path: String?
}
