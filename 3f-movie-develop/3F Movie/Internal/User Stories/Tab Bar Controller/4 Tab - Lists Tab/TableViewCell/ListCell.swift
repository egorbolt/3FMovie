import Foundation
import UIKit

class ListCell: UITableViewCell {
    @IBOutlet weak var labelListName: UILabel!
    @IBOutlet weak var labelMoviesAmount: UILabel!
    
    func configureCell(listName: String, listMoviesAmount: String) {
        self.labelListName.text = listName
        self.labelMoviesAmount.text = "\(listMoviesAmount)"
    }
}
