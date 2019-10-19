//
//  ShowAllData.swift
//  3F Movie
//
//  Created by stud on 11/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation

struct ShowAllData {
    let name: String
    let id: Int
    let imageUrl: String?
    let role: String?
    let vote_average: Float?
    
    init(_ movie: Movie) {
        self.name = movie.title
        self.id = movie.id
        self.imageUrl = movie.poster_path
        self.vote_average = movie.vote_average
        self.role = nil
    }
    
    init(_ actor: Actor) {
        self.name = actor.name
        self.id = actor.id
        self.imageUrl = actor.profile_path
        self.role = actor.character
        self.vote_average = nil
    }
    
    init(_ crewPerson: CrewPerson) {
        self.name = crewPerson.name
        self.id = crewPerson.id
        self.imageUrl = crewPerson.profile_path
        self.role = crewPerson.job
        self.vote_average = nil
    }
    
    init(_ crewElement: CrewElement) {
        self.name = crewElement.title
        self.id = crewElement.id
        self.imageUrl = crewElement.poster_path
        self.role = crewElement.job
        self.vote_average = crewElement.vote_average
    }
    
    init(_ castElement: CastElement) {
        self.name = castElement.title
        self.id = castElement.id
        self.imageUrl = castElement.poster_path
        self.role = castElement.character
        self.vote_average = castElement.vote_average
    }
}
