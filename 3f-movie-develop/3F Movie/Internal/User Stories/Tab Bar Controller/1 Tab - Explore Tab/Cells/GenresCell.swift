//
//  GenresCell.swift
//  3F Movie
//
//  Created by stud on 13/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

class GenresCell: UICollectionViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var genreNameLabel: UILabel!
    
    
    func setupCell(genreName: String) {
        genreNameLabel.text = genreName
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.layer.cornerRadius = self.bounds.height / 2
    }

}
