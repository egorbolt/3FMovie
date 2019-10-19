import UIKit
import Kingfisher

class TrailerCell: UICollectionViewCell {
    @IBOutlet private weak var labelTrailerName: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageViewPlayButton: UIImageView!
    
    func setupCell(trailerImage: String, trailerName: String) {
        labelTrailerName.text = trailerName
        imageView.kf.setImage(with: URL(string: trailerImage))
    }

}
