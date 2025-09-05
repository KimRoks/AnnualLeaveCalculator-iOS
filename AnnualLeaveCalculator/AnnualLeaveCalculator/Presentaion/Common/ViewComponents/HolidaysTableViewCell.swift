//
//  HolidaysTableViewCell.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/27/25.
//

import UIKit
import SnapKit

final class HolidaysTableViewCell: UITableViewCell, Reusable {
    
    var onDeleteTapped: (() -> Void)?

    private let titleLable: UILabel = {
        let label = UILabel()
        label.font = .pretendard(style: .semiBold, size: 13)
        label.textColor = .black
        
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.tintColor = .systemGray
        button.titleLabel?.font = .pretendard(style: .bold, size: 13)
        
        return button
    }()
    
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
            titleLable,
            deleteButton
        )
    }
    
    private func setupConstraints() {
        titleLable.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(7)
            $0.leading.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(7)
            $0.trailing.equalToSuperview()
        }
    }
    
    @objc private func handleDeleteTapped() {
            onDeleteTapped?()
    }
    
    func configureCell(with date: String) {
        titleLable.text = date
    }
}
