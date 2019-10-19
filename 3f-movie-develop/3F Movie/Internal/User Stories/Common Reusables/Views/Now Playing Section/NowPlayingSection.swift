//
//  NowPlayingSection.swift
//  3F Movie
//
//  Created by stud on 10/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class NowPlayingSection: UIView, API {
    
    // MARK: - UI Outlets
    // MARK: Stack views
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Views
    @IBOutlet var contentView: UIView!
    
    // MARK: Labels
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    // MARK: Buttons
    @IBOutlet weak var showAllButton: UIButton!
    

    // MARK: - Properties
    // MARK: Public properties
    weak var delegate: UIViewController? {
        willSet {
            for subview in stackView.arrangedSubviews {
                guard let nowPlayingMovie = subview as? NowPlayingMovie else { continue }
                nowPlayingMovie.delegate = newValue
            }
        }
    }
    
    // MARK: Private properties
    private var showAllAction: (() -> ())?
    
    
    // MARK: - Initializators
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("NowPlayingSection", owner: self, options: nil)
        addSubview(contentView)
        for _ in 0...1 {
            let a = NowPlayingMovie()
            stackView.addArrangedSubview(a)
        }
        contentView.frame = bounds
        showAllButton.addTarget(self, action: #selector(showAllButtonWasPressed), for: .touchUpInside)
        showAllButton.setTitle(L10n.CollectionViewWithTitle.Button.ShowAll.title, for: .normal)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    func setShowAll(action: @escaping (()->()) ) {
        self.showAllAction = action
    }
    
    func reloadData(data: [Movie]) {
        for (index,item) in stackView.arrangedSubviews.enumerated() where item is NowPlayingMovie  {
            guard let nowPlayingMovie = item as? NowPlayingMovie, let dataToShow = data.safelyGetElementAt(IndexPath(row: index, section: 0)) else { continue }
            var filmImage: String = ""
            if dataToShow.backdrop_path != nil {
                filmImage = dataToShow.backdrop_path!
            } else { filmImage = "" }
            nowPlayingMovie.setupView(filmImage: urlSingleImage(image: filmImage), filmName: dataToShow.title, filmOverview: dataToShow.overview, filmRating: dataToShow.vote_average, movieId: dataToShow.id)
        }
    }
    
}

// MARK: - Selectors
extension NowPlayingSection {
    @objc func showAllButtonWasPressed() {
        showAllAction?()
    }
    
}
    
