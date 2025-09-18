//
//  InfoViewContoller.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/5/25.
//

import UIKit

final class InfoViewController: BaseViewController {
    private struct InfoItem {
        let title: String
        let showsChevron: Bool
    }
    // 데이터 소스 (필요 시 showsChevron를 항목별로 조정)
    private let items: [InfoItem] = [
        .init(title: "공지사항", showsChevron: true),
        .init(title: "연차 산정 기준", showsChevron: true),
        .init(title: "이용 약관", showsChevron: false)
    ]

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = UIColor(hex: "#FDFDFD")

        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 56
        tv.keyboardDismissMode = .onDrag
        tv.isScrollEnabled = false
        return tv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLayout()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.register(InfoCell.self, forCellReuseIdentifier: InfoCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    private func setupLayout() {
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension InfoViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: InfoCell.reuseIdentifier,
            for: indexPath
        ) as? InfoCell else { return UITableViewCell() }

        let item = items[indexPath.row]
        cell.configure(title: item.title, showsChevron: item.showsChevron)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.row]
        // 여기에 실제 화면 전환/액션을 연결하세요.
        // 예시:
        switch item.title {
        case "공지사항":
            // navigationController?.pushViewController(NoticeListViewController(), animated: true)
            print("공지사항 tapped")
        case "연차 산정 기준":
            // navigationController?.pushViewController(AnnualRuleViewController(), animated: true)
            print("연차 산정 기준 tapped")
        case "이용 약관":
            // showsChevron=false 이더라도 탭 액션을 막을 필요는 없음. 필요시 early return
            print("이용 약관 tapped")
        default:
            break
        }
    }
}


// MARK: - Cell
final class InfoCell: UITableViewCell,Reusable {
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .pretendard(style: .medium, size: 16)
        lb.textColor = .label
        lb.numberOfLines = 1
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        contentView.addSubviews(titleLabel)
        contentView.backgroundColor = .white
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().offset(20)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        accessoryType = .none
    }

    func configure(title: String, showsChevron: Bool) {
        titleLabel.text = title
        // 시각적 피드백(하이라이트/셀 선택 화살표)도 원하면 accessoryType 사용 가능
        accessoryType = showsChevron ? .disclosureIndicator : .none
        // accessoryType과 chevronView를 동시에 쓰고 싶지 않다면, 위 한 줄을 제거하세요.
    }
}
