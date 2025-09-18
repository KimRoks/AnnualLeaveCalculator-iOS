//
//  DetailCell.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/27/25.
//

import UIKit
import SnapKit

final class DetailCell: UITableViewCell, Reusable {
    
    var onDeleteTapped: (() -> Void)?
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(style: .semiBold, size: 13)
        label.textColor = .black
        
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(style: .regular, size: 12)
        label.textColor = UIColor(hex: "#8E8E93")
        
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.tintColor = .systemGray
        button.titleLabel?.font = .pretendard(style: .bold, size: 13)
        
        return button
    }()
    
    override func prepareForReuse() {
        self.durationLabel.text = nil
        self.durationLabel.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupConstraints()
        deleteButton.addTarget(
            self,
            action: #selector(handleDeleteTapped),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubviews(
            reasonLabel,
            durationLabel,
            deleteButton
        )
    }
    
    private func setupConstraints() {
        reasonLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.equalTo(reasonLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview()

            $0.bottom.equalToSuperview().offset(-10)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    
    @objc private func handleDeleteTapped() {
        onDeleteTapped?()
    }
    
    func configureCell(title: String, duration: String) {
        self.reasonLabel.text = title
        self.durationLabel.text = duration
    }
}
