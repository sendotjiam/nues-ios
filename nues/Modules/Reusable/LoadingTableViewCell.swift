//
//  LoadingTableViewCell.swift
//  nues
//
//  Created by Sendo Tjiam on 20/06/23.
//

import UIKit
import SnapKit

final class LoadingTableViewCell: UITableViewCell {
    
    static let identifier = "LoadingTableViewCell"
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
extension LoadingTableViewCell {
    private func setupViews() {
        contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints({ make in
            make.center.equalToSuperview()
        })
    }
}
