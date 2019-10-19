//
//  TableViewCell.swift
//  3F Movie
//
//  Created by stud on 13/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    func setupCell(movieImagePath: String?, movieName: String, movieOverview: String) {
        self.movieName.text = movieName
        self.movieOverview.text = movieOverview
        
        guard let poster = movieImagePath else { movieImage.image = UIImage(named: "placeholder")
            return
        }
        movieImage.kf.indicatorType = .activity
        movieImage.kf.setImage(with: URL(string: poster), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.7))], progressBlock: nil)
    }
    

    
}
