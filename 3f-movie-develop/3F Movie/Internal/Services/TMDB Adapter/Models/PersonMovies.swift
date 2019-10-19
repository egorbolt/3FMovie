//
//  PersonMovies.swift
//  3F Movie
//
//  Created by stud on 14/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

struct CastElement: Codable {
    let character: String
    let credit_id: String
    let release_date: String
    let vote_count: Int
    let video: Bool
    let adult: Bool
    let vote_average: Float
    let title: String
    let genre_ids: [Int]
    let original_language: String
    let original_title: String
    let popularity: Float
    let id: Int
    let backdrop_path: String?
    let overview: String
    let poster_path: String?
}

struct CrewElement: Codable {
    let id: Int
    let department: String
    let original_language: String
    let original_title: String
    let job: String
    let overview: String
    let vote_count: Int
    let video: Bool
    let poster_path: String?
    let backdrop_path: String?
    let title: String
    let popularity: Float
    let genre_ids: [Int]
    let vote_average: Float
    let adult: Bool
    let release_date: String
    let credit_id: String
}

struct PersonMovies: Codable {
    let cast: [CastElement]
    let crew: [CrewElement]
    let id: Int
}
