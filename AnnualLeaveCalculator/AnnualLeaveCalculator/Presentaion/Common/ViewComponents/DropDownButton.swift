//
//  DropDownButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import UIKit

// 서버 스펙과 동일한 type 매핑
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


final class DropDownButton: UIButton {

    // MARK: - Public
    private(set) var selectedItem: String?
    private(set) var selectedType: NonWorkingType?
    var selectedTypeId: Int? { selectedType?.rawValue }

    /// 문자열만 필요할 때
    var onItemSelected: ((String) -> Void)?
    /// type까지 필요할 때
    var onItemSelectedType: ((String, NonWorkingType) -> Void)?

    // MARK: - Private
    // 내부 고정 항목: (표시 문자열, 서버 type)
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

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        rebuildMenu()
        applyTitle("사유 선택")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        rebuildMenu()
        applyTitle("사유 선택")
    }

    // MARK: - UI
    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray6
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        config.titleLineBreakMode = .byTruncatingTail

        // 드롭다운 아이콘 (오른쪽)
        let sym = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        config.image = UIImage(systemName: "chevron.down", withConfiguration: sym)
        config.imagePlacement = .trailing
        config.imagePadding = 6

        // 텍스트 스타일
        config.attributedTitle = AttributedString("사유 선택", attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .medium, size: 14)
        ]))
        
        // 패딩
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

        self.configuration = config
        self.showsMenuAsPrimaryAction = true // 탭 시 바로 메뉴 표시
    }

    private func rebuildMenu() {
        let actions = items.map { item in
            UIAction(title: item.title, state: item.title == selectedItem ? .on : .off) { [weak self] _ in
                self?.applySelection(title: item.title, type: item.type)
                self?.onItemSelected?(item.title)
                self?.onItemSelectedType?(item.title, item.type)
            }
        }
        self.menu = UIMenu(options: .displayInline, children: actions)
        self.isEnabled = !items.isEmpty
    }

    private func applySelection(title: String, type: NonWorkingType) {
        selectedItem = title
        selectedType = type
        applyTitle(title)
        // 체크표시 상태 갱신
        rebuildMenu()
    }

    private func applyTitle(_ title: String) {
        guard var cfg = self.configuration else { return }
        cfg.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.pretendard(style: .medium, size: 14)
        ]))
        self.configuration = cfg
    }

    /// 외부에서 초기 선택값을 세팅해야 할 때 (타이틀 기준)
    func preselect(title: String) {
        guard let type = NonWorkingType.from(title: title) else { return }
        applySelection(title: title, type: type)
    }

    /// 외부에서 초기 선택값을 세팅해야 할 때 (type 기준)
    func preselect(type: NonWorkingType) {
        if let pair = items.first(where: { $0.type == type }) {
            applySelection(title: pair.title, type: pair.type)
        }
    }

    /// 선택 초기화
    func reset() {
        selectedItem = nil
        selectedType = nil
        applyTitle("사유 선택")
        rebuildMenu()
    }
}
