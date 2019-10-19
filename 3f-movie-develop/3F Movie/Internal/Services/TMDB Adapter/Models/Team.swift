//
//  Team.swift
//  3F Movie
//
//  Created by stud on 10/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

struct Team: Codable {
    let id: Int
    let cast: [Actor]
    let crew: [CrewPerson]
}
