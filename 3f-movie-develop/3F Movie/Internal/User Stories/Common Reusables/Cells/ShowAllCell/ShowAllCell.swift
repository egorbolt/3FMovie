//
//  ShowAllCollectionViewCell.swift
//  3F Movie
//
//  Created by stud on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit
import Kingfisher

class ShowAllCell: UICollectionViewCell {
    var id: Int?
    static let nib = UINib(nibName: Constants.CellReuseIdentifiers.showAllCell, bundle: .main)
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var rating: UILabel!
    @IBOutlet private weak var subname: UILabel!
    @IBOutlet private weak var ratingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .black
        clipsToBounds = true
        layer.cornerRadius = 4
       
    }
}

extension ShowAllCell: API {
    func update(data: ShowAllData, placeholder: String) {
        self.id = data.id
        
        
        if let voteAverage = data.vote_average {
            rating.text = String(voteAverage)
            
            ratingView.layer.cornerRadius = ratingView.frame.height / 2
            ratingView.layer.shadowColor = UIColor.black.cgColor
            ratingView.layer.shadowOffset = CGSize(width: 3, height: 3)
            ratingView.layer.shadowOpacity = 0.3
            ratingView.layer.shadowRadius = 4.0
            
            if voteAverage > 8 {
                ratingView.backgroundColor = UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1)
                
            } else if voteAverage > 6 {
                ratingView.backgroundColor = UIColor(red: 74.0/255.0, green: 105.0/255.0, blue: 189.0/255.0, alpha: 1)
                
            } else {
                ratingView.backgroundColor = UIColor(red: 229.0/255.0, green: 80.0/255.0, blue: 57.0/255.0, alpha: 1)
            }
            
            rating.textColor = .white
            
        } else {
            rating.text = nil
        }
        
        title.text = "\(data.name)"
        if let role = data.role {
            subname.text = "\(role)"
        } else {
            subname.text = nil
        }
        
        guard let poster = data.imageUrl else {
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: placeholder)
            return
        }
        self.imageView.kf.indicatorType = .activity
        self.imageView.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(poster)"),
                                   options: [])
    }
}
