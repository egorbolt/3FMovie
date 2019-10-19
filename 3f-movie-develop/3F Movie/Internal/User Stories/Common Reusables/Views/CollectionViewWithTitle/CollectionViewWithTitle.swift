//
//  ReusableTrendingCell.swift
//  3F Movie
//
//  Created by stud on 09/08/2019.
//  Copyright © 2019 Anton Kovalenko. All rights reserved.
//

import UIKit

@IBDesignable class CollectionViewWithTitle: UIView {
    
    // MARK: - UI Outlets
    // MARK: Views
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleView: UIView!
    
    // MARK: Labels
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Collection Views
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Buttons
    @IBOutlet private weak var showAllBtn: UIButton!
    @IBOutlet private weak var viewBackground: UIView! {
        didSet {
            self.viewBackground.isHidden = true
        }
    }
    @IBOutlet private weak var labelNoContent: UILabel! {
        didSet {
            self.labelNoContent.isHidden = true
        }
    }
    
    
    // MARK: - Properties
    // MARK: Public properties
    weak var delegate: UICollectionViewDelegate? {
        willSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.delegate = newValue
            }
        }
    }
    weak var dataSource: UICollectionViewDataSource? {
        willSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.dataSource = newValue
            }
        }
    }
    
    // IBInspectable properties
    fileprivate var _title: String = ""
    @IBInspectable var title: String {
        set {
            _title = newValue
            titleLabel.text = _title
        }
        get {
            return _title
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
        bundle.loadNibNamed(Constants.NibNames.collectionViewWithTitle, owner: self, options: nil)
//        titleView.addSubview(titleLabel)
//        titleView.addSubview(showAllBtn)
//        contentView.addSubview(titleView)
//        contentView.addSubview(collectionView)
        addSubview(contentView)
        showAllBtn.addTarget(self, action: #selector(showAllButtonWasPressed), for: .touchUpInside)
        showAllBtn.setTitle(L10n.CollectionViewWithTitle.Button.ShowAll.title, for: .normal)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
    // MARK: - Methods
    // MARK: Publuc methods
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func setShowAll(action: @escaping (()->()) ) {
        self.showAllAction = action
    }
    
    func hideShowAllButton() {
        DispatchQueue.main.async {
            self.showAllBtn.isHidden = true
        }
    }
    
    func showNoContentMessage(message: String) {
        DispatchQueue.main.async {
            self.viewBackground.isHidden = false
            self.labelNoContent.isHidden = false
            self.labelNoContent.text = message
        }
    }
}


// MARK: - Selectors
extension CollectionViewWithTitle {
    @objc func showAllButtonWasPressed() {
        showAllAction?()
    }
    
}


// MARK: Layout Helper
extension CollectionViewWithTitle {
    
}



