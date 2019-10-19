//
//  NowPlayingCellTableViewCell.swift
//  3F Movie
//
//  Created by stud on 10/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

@IBDesignable class NowPlayingMovie: UIView {

    // MARK: - UI Outlets
    // MARK: Image Views
    @IBOutlet weak var movieImageView: UIImageView!
    
    // MARK: Views
    @IBOutlet var contentView: UIView!
    
    // MARK: Labels
    @IBOutlet weak var filmRatingLabel: UILabel!
    @IBOutlet weak var filmNameLabel: UILabel!
    @IBOutlet weak var filmOverviewLabel: UILabel!
    
    
    // MARK: Properties
    // MARK: Public properties
    weak var delegate: UIViewController?
    var movieId: Int?
    
    
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
        bundle.loadNibNamed("NowPlayingMovie", owner: self, options: nil)
        addSubview(contentView)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieWasTapped)))
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "NowPlayingMovie", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    // MARK: - Methods
    // MARK: Public methods
    func setupView(filmImage: String?, filmName: String, filmOverview: String, filmRating: Float, movieId: Int) {
        self.filmNameLabel.text = filmName
        self.filmRatingLabel.text = String(filmRating)
        self.filmOverviewLabel.text = filmOverview
        self.movieId = movieId
        
        guard let backdrop = filmImage else { movieImageView.image = UIImage(named: "placeholder")
            return
        }
        movieImageView.kf.indicatorType = .activity
        movieImageView.kf.setImage(with: URL(string: backdrop), placeholder: UIImage(named: "placeholder"), options: [], progressBlock: nil) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                self.movieImageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    @objc func movieWasTapped() {
        let movieStoryboard = UIStoryboard(name: "MovieController", bundle: nil)
        guard let movieViewController = movieStoryboard.instantiateInitialViewController() as? MovieViewController else { return }
        guard let idOfMovie = movieId else { return }
        movieViewController.setMovieID(movieID: idOfMovie)
        delegate?.navigationController?.pushViewController(movieViewController, animated: true)
    }
    
    
}


@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
        (layer as! CAGradientLayer).locations = [0.25, 1]
    }
}
