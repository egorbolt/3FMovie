//
//  API.swift
//  3F Movie
//
//  Created by stud on 10/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

protocol API {}

//MARK - url

extension API {
    func host() -> String {
        return "https://api.themoviedb.org/3"
    }
    
    func key() -> String {
        return "api_key=e4bc0f9cee69e195923579d0cf450c48"
    }
    
    func urlTrending() -> String {
        return "\(host())/trending/movie/week?\(key())"
    }
    
    func urlNowPlaying() -> String {
        return "\(host())/movie/now_playing?\(key())&language=\(MoviesListManager.shared.locale)"
    }
    
    func urlGenres() -> String {
        return "\(host())/genre/movie/list?\(key())&language=\(MoviesListManager.shared.locale)"
    }
    
    func urlPopular() -> String {
        return "\(host())/movie/popular?\(key())&language=\(MoviesListManager.shared.locale)"
    }
    
    func urlTopRated() -> String {
        return "\(host())/movie/top_rated?\(key())&language=\(MoviesListManager.shared.locale)"
    }
    
    func urlUpcoming() -> String {
        return "\(host())/movie/upcoming?\(key())&language=\(MoviesListManager.shared.locale)"
    }
    
    func urlPersonDetailedInfo(personId: Int, language: String) -> String {
        return "\(host())/person/\(personId)?\(key())&language=\(language)"
    }
    
    func urlMovieInfo(movieID: Int, language: String) -> String {
        return "\(host())/movie/\(movieID)?\(key())&language=\(language)"
    }
    
    func urlTrailers(movieID: Int, language: String) -> String {
        return "\(host())/movie/\(movieID)/videos?\(key())&language=\(language)"
    }
    
    func urlMovieRelatedImages(movieID: Int, language: String) -> String {
        return "\(host())/movie/\(movieID)/images?\(key())"
    }
    
    func urlPersonRelatedImages(personId: Int, language: String) -> String {
        return "\(host())/person/\(personId)/images?\(key())&language=\(language)"
    }
    
    func urlPersonMovies(personId: Int, language: String) -> String {
        return "\(host())/person/\(personId)/movie_credits?\(key())&language=\(language)"
    }
    
    func urlSingleImage(image: String) -> String {
        return "https://image.tmdb.org/t/p/w500/\(image)"
    }
    
    func urlSingleImageFromYoutube(image: String) -> String {
        return "https://img.youtube.com/vi/\(image)/0.jpg"
    }
    
    func urlGetYoutubeVideo(video: String) -> String {
        return "https://www.youtube.com/watch?v=\(video)"
    }
    
    func urlSearchMovie(query: String) -> String {
        guard let nsQuery = (query as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return "" }
        return "https://api.themoviedb.org/3/search/movie?\(key())&language=\(MoviesListManager.shared.locale)&query=\(nsQuery)"
    }
}

//MARK - Requests

extension API {
    
    func loadPersonDetailedInfo(personId: Int,
                               language: String,
                               completion: @escaping (Person?) -> ()) {
        
        if let url = URL(string: urlPersonDetailedInfo(personId: personId, language: language)) {
            DispatchQueue.global().async {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(nil)
                        return
                    }
                    
                    let personInfo = try? JSONDecoder().decode(Person.self, from: data)
                    completion(personInfo)
                }
                task.resume()
            }
        }
    }
    
    func loadMovieInfo(movieID: Int, language: String, completion: @escaping (MovieInfo?) -> Void) {
        if let url = URL(string: urlMovieInfo(movieID: movieID, language: language)) {
            DispatchQueue.global().async {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(nil)
                        return
                    }
                    
                    let movieInfo = try? JSONDecoder().decode(MovieInfo.self, from: data)
                    completion(movieInfo)
                }
                task.resume()
            }
        }
    }
        
    func loadMovies(url: String, completion: @escaping ([Movie], Int) -> ()) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion([], 0)
                    return
                }
                
                guard let popularMovies = try? JSONDecoder().decode(PopularMovies.self, from: data) else {
                    
                    completion([], 0)
                    return
                }
                completion(popularMovies.results, popularMovies.total_pages)
                
            }
            task.resume()
        }
    }
    
    func loadPeople(idMovie: Int, language: String, completion: @escaping (Team?) -> ()) {
        guard let url = URL(string: "\(host())/movie/\(idMovie)/credits?\(key())&language=\(language)") else { return }
        DispatchQueue.global().async {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                guard let team = try? JSONDecoder().decode(Team.self, from: data) else {
                    completion(nil)
                    return
                }
                completion(team)
            }
            task.resume()
        }
    }
    
    func loadGenres(language: String, completion: @escaping ([Genre], String?) -> ()) {
        guard let url = URL(string: "\(host())/genre/movie/list?\(key())&language=\(language)") else { return }
        DispatchQueue.global().async {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion([], "Information cann't be downloaded now.")
                    return
                }
                
                guard let genres = try? JSONDecoder().decode(GenreList.self, from: data) else {
                    completion([], "Information cann't be downloaded now.")
                    return
                }
                completion(genres.genres, nil)
            }
            task.resume()
        }
    }
    
    func loadTrailers(movieID: Int, language: String, completion: @escaping ([TrailerInfo]) -> ()) {
        if let url = URL(string: urlTrailers(movieID: movieID, language: language)) {
            DispatchQueue.global().async {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion([])
                        return
                    }
                    
                    guard let trailers = try? JSONDecoder().decode(Trailer.self, from: data) else {
                        completion([])
                        return
                    }
                    
                    completion(trailers.results)
                }
                task.resume()
            }
        }
    }
    
    func loadMovieImages(movieID: Int, language: String, completion: @escaping ([String]) -> ()) {
        if let url = URL(string: urlMovieRelatedImages(movieID: movieID, language: language)) {
            DispatchQueue.global().async {
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    var stash: [String] = []
                    
                    guard let data = data, error == nil else {
                        completion([])
                        return
                    }

                    guard let images = try? JSONDecoder().decode(Pictures.self, from: data) else {
                        completion([])
                        return
                    }
                    
                    images.backdrops.forEach { backdrop in
                        stash.append(backdrop.file_path)
                    }
                    
                    images.backdrops.forEach { poster in
                        stash.append(poster.file_path)
                    }

                    completion(stash)
                }
                task.resume()
            }
        }
    }
    
    func loadPersonImages(personId: Int, language: String, completion: @escaping ([String]) -> ()) {
        if let url = URL(string: urlPersonRelatedImages(personId: personId, language: language)) {
            DispatchQueue.global().async {
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        completion([])
                        return
                    }
                    
                    guard let images = try? JSONDecoder().decode(PersonImagesInfo.self, from: data) else {
                        completion([])
                        return
                    }
                    
                    var paths: [String] = []
                    images.profiles.forEach { image in
                        paths.append(image.file_path)
                    }
                    
                    completion(paths)
                }
                task.resume()
            }
        }
    }
    
    func loadPersonMovies(personId: Int, language: String, completion: @escaping (PersonMovies?) -> ()) {
        guard let url = URL(string: urlPersonMovies(personId: personId, language: language)) else { return }
        DispatchQueue.global().async {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                guard let personMovies = try? JSONDecoder().decode(PersonMovies.self, from: data) else {
                    completion(nil)
                    return
                }
                completion(personMovies)
                
            }
            task.resume()
        }
    }
}
