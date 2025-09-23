//
//  DropDownButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import UIKit
import SnapKit

// MARK: - 서버 스펙과 동일한 type 매핑
enum NonWorkingType: Int, CaseIterable {
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
    case personalReasonLeave = 16
}

extension NonWorkingType {
    var displayTitle: String {
        switch self {
        case .parentalLeave: return "육아휴직"
        case .maternityLeave: return "출산전후휴가"
        case .miscarriageStillbirth: return "유사산휴가"
        case .reserveForcesTraining: return "예비군훈련"
        case .industrialAccident: return "산재 기간"
        case .civicDuty: return "공민권 행사일"
        case .spouseMaternityLeave: return "출산휴가"
        case .familyCareLeave: return "가족돌봄휴가"
        case .unfairDismissal: return "부당해고"
        case .illegalLockout: return "직장폐쇄(불법)"
        case .unauthorizedAbsence: return "무단결근"
        case .disciplinarySuspension: return "징계 정·휴직 등"
        case .illegalStrike: return "불법쟁의행위"
        case .militaryServiceLeave: return "군 휴직"
        case .personalIllnessLeave: return "개인 질병 휴직"
        case .personalReasonLeave:
            return "일반휴직(개인사유)"
        }
    }
    
    static func from(title: String) -> NonWorkingType? {
        Self.allCases.first { $0.displayTitle == title }
    }
    
    var serverCode: Int {
        switch self {
        case .parentalLeave,
                .maternityLeave,
                .miscarriageStillbirth,
                .reserveForcesTraining,
                .industrialAccident,
                .civicDuty,
                .spouseMaternityLeave,
                .familyCareLeave,
                .unfairDismissal,
                .illegalLockout:
            return 1
            
        case .unauthorizedAbsence,
                .disciplinarySuspension,
                .illegalStrike:
            return 2
            
        case .militaryServiceLeave,
                .personalIllnessLeave,
                .personalReasonLeave:
            return 3
        }
    }
}

enum CompanyHolidayType: CaseIterable, Hashable {
    case companyFoundationDay                       // 회사 창립기념일
    case collectiveAgreementLeave                   // 단체협약상 유·무급 휴가일
    case laborUnionFoundationDay                    // 노동조합 창립기념일
    case internalPolicyHoliday                      // 사내 규정상 휴일(Family day, 종무식)
    case companyWideSummerBreak                     // 일괄 여름휴가 지정일(단체 연차사용 제외)
    case discretionaryPrePostHoliday                // 명절 전후 임의휴무일(단체 연차사용 제외)
    case other                                      // 기타
    
    var title: String {
        switch self {
        case .companyFoundationDay:        return "회사 창립기념일"
        case .collectiveAgreementLeave:    return "단체협약상 유·무급 휴가일"
        case .laborUnionFoundationDay:     return "노동조합 창립기념일"
        case .internalPolicyHoliday:       return "사내 규정상 휴일"
        case .companyWideSummerBreak:      return "일괄 여름휴가 지정일"
        case .discretionaryPrePostHoliday: return "명절 전후 임의휴무일"
        case .other:                       return "기타"
        }
    }
}

// MARK: - 재사용 가능한 드롭다운 버튼
final class DropDownButton: UIButton {
    
    // 외부에서 고르는 데이터 소스 종류
    enum Kind: Equatable {
        case nonWorkingTypes
        case holidaysTypes
    }
    
    // 내부 표현
    struct Item: Hashable {
        let id: AnyHashable
        let title: String
    }
    
    // MARK: Public 상태/콜백(하위 호환 유지)
    private(set) var selectedItem: String?
    private(set) var selectedType: NonWorkingType?
    var selectedTypeId: Int? { selectedType?.serverCode }
    private(set) var selectedId: AnyHashable?
    
    var onItemSelected: ((String) -> Void)?
    var onItemSelectedType: ((String, NonWorkingType) -> Void)?
    var onSelect: ((Item) -> Void)?
    
    // 사용자 지정 가능 속성
    var maxHeightFraction: CGFloat = 0.4
    var rowHeight: CGFloat = 48
    var minPopoverWidth: CGFloat = 230
    var cellNumberOfLines: Int = 1
    var placeholder: String = "선택"
    
    // MARK: Private
    private var kind: Kind
    private var items: [Item] = []
    
    // MARK: Init
    init(
        kind: Kind = .nonWorkingTypes
    ) {
        self.kind = kind
        super.init(frame: .zero)
        setupButton()
        reloadItemsFromKind()
        applyTitleIfNeeded()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        self.kind = .nonWorkingTypes
        super.init(coder: coder)
        setupButton()
        reloadItemsFromKind()
        applyTitleIfNeeded()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    func preselect(title: String) {
        if let found = items.first(where: { $0.title == title }) {
            applySelection(item: found)
        }
    }
    
    func preselect(type: NonWorkingType) {
        if let found = items.first(where: { ($0.id as? NonWorkingType) == type }) {
            applySelection(item: found)
        }
    }
    
    func reset() {
        selectedItem = nil
        selectedType = nil
        selectedId = nil
        applyTitle(placeholder)
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
        
        configuration.attributedTitle = AttributedString(placeholder, attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .medium, size: 14)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        self.configuration = configuration
    }
    
    private func reloadItemsFromKind() {
        switch kind {
        case .nonWorkingTypes:
            items = NonWorkingType.allCases.map { Item(id: $0, title: $0.displayTitle) }
            
        case .holidaysTypes:
            items = CompanyHolidayType.allCases.map { Item(id: $0, title: $0.title) }
            isEnabled = !items.isEmpty
        }
    }
    
    private func applySelection(item: Item) {
        selectedItem = item.title
        selectedId = item.id
        selectedType = (item.id as? NonWorkingType)
        
        applyTitle(item.title)
        
        onSelect?(item)
        onItemSelected?(item.title)
        if let type = selectedType {
            onItemSelectedType?(item.title, type)
        }
    }
    
    private func applyTitleIfNeeded() {
        applyTitle(selectedItem ?? placeholder)
    }
    
    private func applyTitle(_ title: String) {
        guard var buttonConfiguration = configuration else { return }
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .medium, size: 14)
        ]))
        configuration = buttonConfiguration
    }
    
    // MARK: Actions
    @objc private func didTap() {
        guard let parentViewController = parentViewController else { return }
        
        let popoverController = DropdownPopoverController(
            items: items,
            selectedTitle: selectedItem,
            rowHeight: rowHeight,
            cellNumberOfLines: cellNumberOfLines
        )
        popoverController.onSelect = { [weak self] item in
            self?.applySelection(item: item)
        }
        
        popoverController.modalPresentationStyle = .popover
        if let pop = popoverController.popoverPresentationController {
            pop.sourceView = self
            pop.sourceRect = bounds
            pop.permittedArrowDirections = [.up, .down]
            pop.delegate = popoverController
        }
        
        let screenHeight = UIScreen.main.bounds.height
        let maxHeight = screenHeight * maxHeightFraction
        let totalHeight = CGFloat(items.count) * rowHeight
        let finalHeight = min(maxHeight, totalHeight)
        
        let width = max(bounds.width, minPopoverWidth)
        popoverController.preferredContentSize = CGSize(width: width, height: finalHeight)
        
        parentViewController.present(popoverController, animated: true)
    }
}

// MARK: - 팝오버 컨트롤러
private final class DropdownPopoverController: UIViewController {
    var onSelect: ((DropDownButton.Item) -> Void)?
    
    private let items: [DropDownButton.Item]
    private let selectedTitle: String?
    private let rowHeight: CGFloat
    private let cellNumberOfLines: Int
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    init(items: [DropDownButton.Item], selectedTitle: String?, rowHeight: CGFloat, cellNumberOfLines: Int) {
        self.items = items
        self.selectedTitle = selectedTitle
        self.rowHeight = rowHeight
        self.cellNumberOfLines = cellNumberOfLines
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
}

// MARK: - UIPopoverPresentationControllerDelegate
extension DropdownPopoverController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }
}

// MARK: - UITableViewDataSource
extension DropdownPopoverController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = item.title
        configuration.textProperties.numberOfLines = cellNumberOfLines
        configuration.textProperties.font = .pretendard(style: .medium, size: 14)
        cell.contentConfiguration = configuration
        cell.accessoryType = (item.title == selectedTitle) ? .checkmark : .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DropdownPopoverController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(items[indexPath.row])
        dismiss(animated: true)
    }
}

