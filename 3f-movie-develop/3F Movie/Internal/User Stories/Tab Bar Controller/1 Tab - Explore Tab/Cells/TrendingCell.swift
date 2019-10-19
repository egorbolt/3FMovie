//
//  TrendingCell.swift
//  3F Movie
//
//  Created by stud on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

class TrendingCell: UICollectionViewCell {
    
    // MARK: - UI Outlets
    // MARK: Images
    @IBOutlet weak var moviePosterImage: UIImageView!
    
    // MARK: Labels
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieScore: UILabel!
    
    @IBOutlet weak var movieRatingView: UIView!
    
    // MARK: - Methods
    func setupCell(moviePoster: String?, movieName: String, movieScore: Float) {
        self.movieName.text = movieName
        self.movieScore.text = String(movieScore)
        movieRatingView.layer.cornerRadius = movieRatingView.frame.height / 2
        movieRatingView.layer.shadowColor = UIColor.black.cgColor
        movieRatingView.layer.shadowOffset = CGSize(width: 3, height: 3)
        movieRatingView.layer.shadowOpacity = 0.3
        movieRatingView.layer.shadowRadius = 4.0
        if movieScore > 8 {
            movieRatingView.backgroundColor = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1)
            self.movieScore.textColor = .white
        } else if movieScore > 6 {
            movieRatingView.backgroundColor = UIColor(red: 74.0/255.0, green: 105.0/255.0, blue: 189.0/255.0, alpha: 1)
        } else {
            movieRatingView.backgroundColor = UIColor(red: 229.0/255.0, green: 80.0/255.0, blue: 57.0/255.0, alpha: 1)
        }
        self.movieScore.textColor = .white
        guard let poster = moviePoster else { moviePosterImage.image = UIImage(named: "noMoviePoster")
            return
        }
        moviePosterImage.kf.indicatorType = .activity
        moviePosterImage.kf.setImage(with: URL(string: poster), placeholder: UIImage(named: "noMoviePoster"), options: [], progressBlock: nil) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                self.moviePosterImage.image = UIImage(named: "noMoviePoster")
            }
        }
    
    }
    
}
