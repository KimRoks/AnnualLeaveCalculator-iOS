//
//  DropDownButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import UIKit
import SnapKit

enum NonWorkingType: Int {
    case parentalLeave              = 1   // 육아휴직
    case maternityLeave             = 2   // 출산전후휴가
    case miscarriageStillbirth      = 3   // 유사산휴가
    case reserveForcesTraining      = 4   // 예비군훈련
    case industrialAccident         = 5   // 업무상 부상 또는 질병(산재인정)
    case civicDuty                  = 6   // 공민권 행사를 위한 휴무일
    case spouseMaternityLeave       = 7   // 배우자 출산휴가
    case familyCareLeave            = 8   // 가족돌봄휴가
    case unfairDismissal            = 9   // 부당해고
    case illegalLockout             = 10  // 불법직장폐쇄
    case unauthorizedAbsence        = 11  // 무단결근
    case disciplinarySuspension     = 12  // 징계로 인한 정직, 강제 휴직, 직위해제
    case illegalStrike              = 13  // 불법쟁의행위
    case militaryServiceLeave       = 14  // 병역의무 이행을 위한 휴직
    case personalIllnessLeave       = 15  // 개인질병(업무상 질병X)으로 인한 휴직

    static func from(title: String) -> NonWorkingType? {
        switch title {
        case "육아휴직": return .parentalLeave
        case "출산전후휴가": return .maternityLeave
        case "유사산휴가": return .miscarriageStillbirth
        case "예비군훈련": return .reserveForcesTraining
        case "업무상 부상 또는 질병(산재인정)": return .industrialAccident
        case "공민권 행사를 위한 휴무일": return .civicDuty
        case "배우자 출산휴가": return .spouseMaternityLeave
        case "가족돌봄휴가": return .familyCareLeave
        case "부당해고": return .unfairDismissal
        case "불법직장폐쇄": return .illegalLockout
        case "무단결근": return .unauthorizedAbsence
        case "징계로 인한 정직, 강제 휴직, 직위해제": return .disciplinarySuspension
        case "불법쟁의행위": return .illegalStrike
        case "병역의무 이행을 위한 휴직": return .militaryServiceLeave
        case "개인질병(업무상 질병X)으로 인한 휴직": return .personalIllnessLeave
        default: return nil
        }
    }
}

// MARK: - 버튼

final class DropDownButton: UIButton {

    // MARK: Public
    private(set) var selectedItem: String?
    private(set) var selectedType: NonWorkingType?
    var selectedTypeId: Int? { selectedType?.rawValue }

    var onItemSelected: ((String) -> Void)?
    var onItemSelectedType: ((String, NonWorkingType) -> Void)?

    // 최대 높이(화면 높이의 비율). 0.4 => 40%
    var maxHeightFraction: CGFloat = 0.4
    var rowHeight: CGFloat = 48

    // MARK: Private
    private let items: [(title: String, type: NonWorkingType)] = [
        ("육아휴직", .parentalLeave),
        ("출산전후휴가", .maternityLeave),
        ("유사산휴가", .miscarriageStillbirth),
        ("예비군훈련", .reserveForcesTraining),
        ("업무상 부상 또는 질병(산재인정)", .industrialAccident),
        ("공민권 행사를 위한 휴무일", .civicDuty),
        ("배우자 출산휴가", .spouseMaternityLeave),
        ("가족돌봄휴가", .familyCareLeave),
        ("부당해고", .unfairDismissal),
        ("불법직장폐쇄", .illegalLockout),
        ("무단결근", .unauthorizedAbsence),
        ("징계로 인한 정직, 강제 휴직, 직위해제", .disciplinarySuspension),
        ("불법쟁의행위", .illegalStrike),
        ("병역의무 이행을 위한 휴직", .militaryServiceLeave),
        ("개인질병(업무상 질병X)으로 인한 휴직", .personalIllnessLeave)
    ]

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        rebuildMenu()
        applyTitle("사유 선택")
        showsMenuAsPrimaryAction = false
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        rebuildMenu()
        applyTitle("사유 선택")
        showsMenuAsPrimaryAction = false
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    // MARK: UI
    private func setupButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemGray6
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .medium
        configuration.titleLineBreakMode = .byTruncatingTail

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        configuration.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfiguration)
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 6

        configuration.attributedTitle = AttributedString("사유 선택", attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .medium, size: 14)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        self.configuration = configuration
    }

    private func rebuildMenu() {
        let actions = items.map { item in
            UIAction(title: item.title, state: item.title == selectedItem ? .on : .off) { [weak self] _ in
                self?.applySelection(title: item.title, type: item.type)
                self?.onItemSelected?(item.title)
                self?.onItemSelectedType?(item.title, item.type)
            }
        }
        menu = UIMenu(options: .displayInline, children: actions)
        isEnabled = !items.isEmpty
    }

    private func applySelection(title: String, type: NonWorkingType) {
        selectedItem = title
        selectedType = type
        applyTitle(title)
        rebuildMenu()
    }

    private func applyTitle(_ title: String) {
        guard var buttonConfiguration = configuration else { return }
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .medium, size: 14)
        ]))
        configuration = buttonConfiguration
    }

    // MARK: Public Helpers
    func preselect(title: String) {
        guard let type = NonWorkingType.from(title: title) else { return }
        applySelection(title: title, type: type)
    }

    func preselect(type: NonWorkingType) {
        if let pair = items.first(where: { $0.type == type }) {
            applySelection(title: pair.title, type: pair.type)
        }
    }

    func reset() {
        selectedItem = nil
        selectedType = nil
        applyTitle("사유 선택")
        rebuildMenu()
    }

    // MARK: Actions
    @objc private func didTap() {
        guard let parentViewController = parentViewController else { return }

        let popoverController = DropdownPopoverController(
            items: items.map { .init(title: $0.title, type: $0.type) },
            selectedTitle: selectedItem,
            rowHeight: rowHeight
        )
        popoverController.onSelect = { [weak self] item in
            self?.applySelection(title: item.title, type: item.type)
            self?.onItemSelected?(item.title)
            self?.onItemSelectedType?(item.title, item.type)
        }

        popoverController.modalPresentationStyle = .popover
        if let popoverPresentationController = popoverController.popoverPresentationController {
            popoverPresentationController.sourceView = self
            popoverPresentationController.sourceRect = bounds
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            popoverPresentationController.delegate = popoverController // iPhone에서도 팝오버 유지
        }

        // 높이 계산: 아이템 총 높이 vs 화면 40%
        let screenHeight = UIScreen.main.bounds.height
        let maxHeight = screenHeight * maxHeightFraction
        let totalHeight = CGFloat(items.count) * rowHeight
        let finalHeight = min(maxHeight, totalHeight)
        // 너비: 버튼 너비 기준, 최소 250 보장
        let width = max(bounds.width, 250)
        popoverController.preferredContentSize = CGSize(width: width, height: finalHeight)

        parentViewController.present(popoverController, animated: true)
    }
}

// MARK: - 팝오버 컨트롤러(스크롤 지원)
private final class DropdownPopoverController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    struct Item {
        let title: String
        let type: NonWorkingType
    }

    var onSelect: ((Item) -> Void)?

    private let items: [Item]
    private let selectedTitle: String?
    private let rowHeight: CGFloat

    private let tableView = UITableView(frame: .zero, style: .plain)

    init(items: [Item], selectedTitle: String?, rowHeight: CGFloat) {
        self.items = items
        self.selectedTitle = selectedTitle
        self.rowHeight = rowHeight
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = rowHeight
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // iPhone에서도 팝오버 유지
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = item.title
        configuration.textProperties.numberOfLines = 1
        configuration.textProperties.font = .pretendard(style: .medium, size: 14)
        
        cell.contentConfiguration = configuration
        cell.accessoryType = (item.title == selectedTitle) ? .checkmark : .none
        return cell
    }

    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        onSelect?(item)
        dismiss(animated: true)
    }
}
