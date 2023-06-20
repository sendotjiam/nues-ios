//
//  SourceTableViewCell.swift
//  nues
//
//  Created by Sendo Tjiam on 19/06/23.
//

import UIKit
import SnapKit

final class SourceTableViewCell: UITableViewCell {

    static let identifier = "SourceTableViewCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    var data: SourceModel? {
        didSet {
            configure()
        }
    }
    
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

extension SourceTableViewCell {
    private func configure() {
        titleLabel.text = data?.name ?? ""
        descLabel.text = data?.description ?? ""
    }
    
    private func setupViews() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        })
        descLabel.snp.makeConstraints({ make in
            make.top.equalTo(titleLabel.snp_bottomMargin).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        })
    }
}
