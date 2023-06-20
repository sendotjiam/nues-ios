//
//  ErrorView.swift
//  nues
//
//  Created by Sendo Tjiam on 20/06/23.
//

import UIKit
import SnapKit
import Kingfisher

protocol ErrorViewDelegate: AnyObject {
    func didTapReload()
}

final class ErrorView: UIView {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var reloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Try Again", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapReload), for: .touchUpInside)
        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        button.layer.cornerRadius = 10
        return button
    }()
    
    var error: BaseErrors = .anyError {
        didSet {
            configure()
        }
    }
    weak var delegate: ErrorViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func configure() {
        switch error {
        case .emptyDataError:
            iconImageView.image = UIImage(named: "notFound")
            titleLabel.text = "You don't have any favorite items yet"
            subtitleLabel.text = "When you have, you'll see them."
            reloadButton.isHidden = true
            reloadButton.snp.makeConstraints({ make in
                make.height.equalTo(0)
            })
        default:
            iconImageView.image = UIImage(named: "retry")
            titleLabel.text = "Failed to Load"
            subtitleLabel.text = "Please try again."
        }
    }
    
}

extension ErrorView {
    private func setupViews() {
        backgroundColor = .white
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(reloadButton)
        
        iconImageView.snp.makeConstraints({ make in
            make.height.equalTo(200).priority(.high)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        })
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(iconImageView.snp_bottomMargin).offset(16)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        })
        subtitleLabel.snp.makeConstraints({ make in
            make.top.equalTo(titleLabel.snp_bottomMargin).offset(16)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        })
        reloadButton.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp_bottomMargin).offset(32).priority(.low)
            make.bottom.equalToSuperview().offset(-8)
        })
    }
    
    @objc func didTapReload() {
        delegate?.didTapReload()
    }
}
