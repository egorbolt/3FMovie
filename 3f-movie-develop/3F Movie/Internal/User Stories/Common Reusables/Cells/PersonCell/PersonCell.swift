import UIKit
import Kingfisher

class PersonCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var labelPersonName: UILabel!
    @IBOutlet private weak var labelPersonPosition: UILabel!
    
    func setupCell(personImage: String?, personName: String, personPosition: String, imagePlaceholder: String) {
        if let image = personImage {
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: URL(string: image),
                                       placeholder: UIImage(named: imagePlaceholder))
        } else {
            self.imageView.image = UIImage(named: imagePlaceholder)
        }
        self.labelPersonName.text = personName
        if personPosition != MovieViewControllerPublicConsts.noPositionProvided {
            self.labelPersonPosition.text = personPosition
        } else {
            self.labelPersonPosition.isHidden = true
        }
    }
}
