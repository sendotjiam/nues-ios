//
//  ArticleTableViewCell.swift
//  nues
//
//  Created by Sendo Tjiam on 20/06/23.
//

import UIKit
import SnapKit
import Kingfisher

final class ArticleTableViewCell: UITableViewCell {

    static let identifier = "ArticleTableViewCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    var data: ArticleModel? {
        didSet {
            configure()
        }
    }
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        guard let article = data else {
            return
        }
        titleLabel.text = article.title
        timestampLabel.text = "Published at \(article.publishedAt.updateToDateString())"
        itemImageView.kf.setImage(with: URL(string: article.urlToImage ?? ""),
                             options: [.transition(.fade(0.3)),.cacheOriginalImage])
    }

}

extension ArticleTableViewCell {
    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(itemImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timestampLabel)
        itemImageView.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(120)
            make.height.equalTo(80).priority(.high)
        })
        titleLabel.snp.makeConstraints({ make in
            make.leading.equalTo(itemImageView.snp_trailingMargin).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        })
        timestampLabel.snp.makeConstraints({ make in
            make.top.equalTo(titleLabel.snp_bottomMargin).offset(10).priority(.high)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalTo(itemImageView.snp_trailingMargin).offset(16)
            make.trailing.equalToSuperview().offset(-16)
        })
    }
}
