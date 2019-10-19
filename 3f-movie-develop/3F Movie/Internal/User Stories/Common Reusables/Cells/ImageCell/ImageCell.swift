//
//  ImageCell.swift
//  3F Movie
//
//  Created by stud on 14/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    static let nib = UINib(nibName: Constants.CellReuseIdentifiers.imageCell, bundle: .main)
    
    func setupImage(path: String) {
        image.kf.indicatorType = .activity
        image.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500/\(path)"),
                              options: [])
    }
}
