//
//  QuickHelpViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/4/25.
//

import UIKit
import SnapKit

// MARK: - Help Models

enum QuickHelpKind {
    case calculationType
    case detailPeriods
    case companyHolidays
    case custom([HelpSection]) // 외부에서 직접 섹션 주입
}

struct HelpSection {
    let title: String
    let description: String
}

enum QuickHelpContentLibrary {
    static func sections(for kind: QuickHelpKind) -> [HelpSection] {
        switch kind {
        case .calculationType:
            return [
                HelpSection(
                    title: "입사일 VS. 회계연도",
                    description:
                    """
                    회사가 입사일을 기준으로
                    1년마다 연차를 산정하면 입사일을 선택하고
                    통상 매년 1월 1일(또는 특정일)마다 
                    1년단위로 연차휴가를 지급하면
                    회계연도를 선택하면 돼요
                    """
                ),
                HelpSection(
                    title: "회계연도 연차계산법이란?",
                    description:
                    """
                    원칙적으로 연차유급휴가는 입사일 기준으로 산정해야해요.
                    하지만 편의를 위해 회계연도 기준을 연차를 계산하는것을 허용하고 있어요.
                    모든 직원의 입사일이 다르니, 연차발생일도 달라져 관리가 힘들기 때문이죠.
                    """
                )
            ]

        case .detailPeriods:
            return [
                HelpSection(
                    title: "특이사항이 있는 기간은 무엇인가요?",
                    description:
                    """
                    해당 기간은 재직 중 일시적으로 근로 제공이 중단되었거나, 특별한 사정으로 인하여 정상적으로 근로하지 못한 기간을 의미해요.
                    유형에 따라 
                    출근간주 / 결근처리 / 소정근로제외로 반영되며, 이에 따라 연차휴가 발생일수가 달라져요.

                    • 입력 범위 : 입사일 ~ 산정 기준일 사이
                    • 서로 기간이 겹치지 않게 등록이 가능
                    • 주말/공휴일은 자동 반영
                    """
                )
            ]

        case .companyHolidays:
            return [
                HelpSection(
                    title: "공휴일 외 회사휴일이 무엇인가요?",
                    description:
                    """
                    공식 휴일 외 회사 지정 특별휴일은 
                    회사창립기념일, 단체협약상 유·무급휴일, 노조 창립기념일 등
                    법정공휴일을 제외하고 회사 내부 규정에 따라 부여되는 휴일을 의미합니다.
                    """
                )
            ]

        case .custom(let sections):
            return sections
        }
    }
}

// MARK: - ViewController

final class QuickHelpViewController: BaseViewController {

    // MARK: Inputs
    private let kind: QuickHelpKind
    private let confirmButton: ConfirmButton
    private var items: [HelpSection] = []

    // MARK: UI
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        
        return sv
    }()
    private let contentView = UIView()
    private lazy var contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()

    
    private struct HighlightUnit { let ctxIndex: Int; let rangeIndex: Int }
    private var labelContexts: [LabelHighlightContext] = []
    private var highlightQueue: [HighlightUnit] = []
    private var highlightTimer: Timer?


    private let highlighterColors: [UIColor] = [
        UIColor(red: 1.00, green: 0.97, blue: 0.60, alpha: 1.0), // yellow
    ]

    // 하이라이트 키워드
    private var highlightKeywords: [String] {
        switch kind {
        case .calculationType:
            return [
                "1년마다 연차를 산정하면 입사일을 선택",
                "1년단위로 연차휴가를 지급하면 회계연도를 선택",
                "편의를 위해 회계연도 기준을 연차를 계산하는것을 허용"
            ]
        case .detailPeriods:
            return ["정상적으로 근로하지 못한 기간을 의미","이에 따라 연차휴가 발생일수가 달라져요"]
        case .companyHolidays:
            return ["법정공휴일을 제외", "내부 규정에 따라 부여되는 휴일"]
        case .custom:
            return []
        }
    }

    // 키워드 → 고정색
    private lazy var keywordColorMap: [String: UIColor] = {
        var map: [String: UIColor] = [:]
        for (i, k) in highlightKeywords.enumerated() {
            map[k] = highlighterColors[i % highlighterColors.count]
        }
        return map
    }()

    // MARK: Init
    init(kind: QuickHelpKind, confirmTitle: String = "확인") {
        self.kind = kind
        self.confirmButton = ConfirmButton(title: confirmTitle)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        items = QuickHelpContentLibrary.sections(for: kind)

        confirmButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        setupLayout()
        setupConstraints()
        setupDismissGesture()
        buildSections()
        prepareHighlightQueueAndStart()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        highlightTimer?.invalidate()
        highlightTimer = nil
    }

    @objc private func dismissView() { dismiss(animated: true) }

    // MARK: Layout
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubviews(scrollView, confirmButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)
    }

    private func setupConstraints() {
        // 충돌 없도록: 중앙 정렬 + 최대폭 + 좌우 여백(이상/이하)
        containerView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.width.lessThanOrEqualTo(360)
            $0.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.8)
            $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.5).priority(.high)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.equalTo(containerView.snp.leading).offset(20)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
            $0.bottom.equalTo(containerView.snp.bottom).offset(-20)
            $0.height.equalTo(48)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top).offset(30)
            $0.leading.equalTo(containerView.snp.leading).offset(23)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-23)
            $0.bottom.equalTo(confirmButton.snp.top).offset(-20)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: Build Sections
    private func buildSections() {
        items.forEach { item in
            let section = makeSectionStack(title: item.title, body: item.description)
            contentStack.addArrangedSubview(section.stack)
            registerHighlightContext(for: section.descriptionLabel, text: item.description)
        }
    }

    private func makeSectionStack(title: String, body: String)
    -> (stack: UIStackView, titleLabel: UILabel, descriptionLabel: UILabel) {
        let titleLabel = UILabel()
        titleLabel.textColor = .label
        titleLabel.font = .pretendard(style: .bold, size: 20)
        titleLabel.numberOfLines = 0
        titleLabel.text = title

        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.font = .pretendard(style: .regular, size: 17)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = body

        let sv = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        sv.axis = .vertical
        sv.spacing = 8
        return (sv, titleLabel, descriptionLabel)
    }

    // MARK: Highlight Register + Queue + Timer

    /// 키워드를 "공백/개행 무시" 정규식으로 변환
    private func makeFlexiblePattern(from phrase: String) -> String {
        let tokens = phrase
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return tokens
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .joined(separator: "\\s*")
    }

    private func registerHighlightContext(for label: UILabel, text: String) {
        guard !highlightKeywords.isEmpty, !text.isEmpty else { return }

        let ns = text as NSString
        var foundRanges: [NSRange] = []
        var foundColors: [UIColor] = []

        for key in highlightKeywords where !key.isEmpty {
            let pattern = makeFlexiblePattern(from: key)
            guard let regex = try? NSRegularExpression(
                pattern: pattern,
                options: [.caseInsensitive]
            ) else { continue }

            let full = NSRange(location: 0, length: ns.length)
            regex.enumerateMatches(in: text, options: [], range: full) { match, _, _ in
                guard let r = match?.range else { return }
                foundRanges.append(r)
                foundColors.append(self.keywordColorMap[key] ?? self.highlighterColors[foundRanges.count % self.highlighterColors.count])
            }
        }

        guard foundRanges.isEmpty == false else { return }

        // 위치 순서대로 정렬(위→아래)
        let indices = Array(foundRanges.indices).sorted { a, b in
            foundRanges[a].location < foundRanges[b].location
        }
        let sortedRanges = indices.map { foundRanges[$0] }
        let sortedColors = indices.map { foundColors[$0] }

        let ctx = LabelHighlightContext(label: label, text: text, ranges: sortedRanges, colors: sortedColors)
        labelContexts.append(ctx)
    }

    private func prepareHighlightQueueAndStart() {
        highlightQueue.removeAll()

        // 위에서부터(등록 순서) → 각 라벨의 범위(정렬됨) 순서대로 누적
        for (ci, ctx) in labelContexts.enumerated() {
            for ri in ctx.ranges.indices {
                highlightQueue.append(HighlightUnit(ctxIndex: ci, rangeIndex: ri))
            }
        }
        guard highlightQueue.isEmpty == false else { return }
        scheduleNextTick()
    }

    private func scheduleNextTick() {
        highlightTimer?.invalidate()
        highlightTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { [weak self] _ in
            self?.tickHighlightOnce()
            self?.scheduleNextTick()
        }
        if let timer = highlightTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func tickHighlightOnce() {
        guard highlightQueue.isEmpty == false else {
            highlightTimer?.invalidate()
            highlightTimer = nil
            return
        }
        let unit = highlightQueue.removeFirst()
        let ctx = labelContexts[unit.ctxIndex]
        let range = ctx.ranges[unit.rangeIndex]
        let color = ctx.colors[unit.rangeIndex]

        let strongTextColor: UIColor = .label

        ctx.attributed.addAttributes([
            .backgroundColor: color,
            .foregroundColor: strongTextColor
        ], range: range)

        UIView.transition(with: ctx.label, duration: 0.25, options: .transitionCrossDissolve, animations: {
            ctx.label.attributedText = ctx.attributed
        }, completion: nil)
    }


    // MARK: Dismiss Gesture (바깥 터치 시 닫기)
    private func setupDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}

struct LabelHighlightContext {
    let label: UILabel
    let text: String
    let ranges: [NSRange]
    let colors: [UIColor]
    let attributed: NSMutableAttributedString
    init(label: UILabel, text: String, ranges: [NSRange], colors: [UIColor]) {
        self.label = label
        self.text = text
        self.ranges = ranges
        self.colors = colors
        self.attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: label.font as Any,
                .foregroundColor: label.textColor as Any
            ]
        )
    }
}
