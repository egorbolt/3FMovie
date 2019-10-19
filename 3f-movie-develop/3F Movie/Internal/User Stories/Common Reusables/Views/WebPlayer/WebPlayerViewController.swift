import Foundation
import UIKit
import YoutubePlayer_in_WKWebView

class WebPlayerViewController: UIViewController {
    @IBOutlet private weak var uiWebView: WKYTPlayerView!
    
    private var urlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        uiWebView.load(withVideoId: urlString)
    }
    
    
    func setupWebView(url: String) {
        self.urlString = url
    }
    
    func setupNavBar() {
        let leftBarButton = UIBarButtonItem(title: NSLocalizedString("WebPlayerVC.Button.Back", comment: ""), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}
