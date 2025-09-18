//
//  QuickHelpViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/4/25.
//

import UIKit
import SnapKit

enum QuickHelpKind {
    case calculationType
    case detailPeriods
    case companyHolidays
    case custom([HelpSection]) // 예외적으로 외부에서 직접 섹션 주입하고 싶을 때
}

enum QuickHelpContentLibrary {
    static func sections(for kind: QuickHelpKind) -> [HelpSection] {
        switch kind {
        case .calculationType:
            return [
                HelpSection(
                    title: "입사일 VS. 회계연도",
                    description:"""
                    회사가 입사일을 기준으로
                    1년마다 연차를 산정하면 입사일을 선택하고
                    통상 매년 1월 1일(또는 특정일)마다 
                    1년단위로 연차휴가를 지급하면
                    회계연도를 선택하면 돼요
                    """
                ),
                HelpSection(
                    title:"회계연도 연차계산법이란?",
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
                    title:"특이사항이 있는 기간은 무엇인가요?",
                    description: """
                    해당 기간은 재직 중 일시적으로 근로 제공이 중단되었거나, 특별한 사정으로 인하여 정상적으로 근로하지 못한 기간을 의미해요.
                    유형에 따라 출근간주 / 결근처리 / 소정근로제외로 반영되며, 이에 따라 연차휴가 발생일수가 달라져요.

                    • 입력 범위 : 입사일 ~ 산정 기준일 사이
                    • 서로 기간이 겹치지 않게 등록이 가능
                    • 주말/공휴일은 자동 반영
                    """
                )
            ]
            
        case .companyHolidays:
            return [
                HelpSection(
                    title:"공휴일 외 회사휴일이 무엇인가요?",
                    description: """
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

struct HelpSection {
    let title: String
    let description: String
}

final class QuickHelpViewController: BaseViewController {
    private let kind: QuickHelpKind
    private let confirmButton: ConfirmButton
    private var items: [HelpSection] = []
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    
    init(kind: QuickHelpKind, confirmTitle: String = "확인") {
        self.kind = kind
        self.confirmButton = ConfirmButton(title: confirmTitle)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        items = QuickHelpContentLibrary.sections(for: kind)
        
        confirmButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        setupLayout()
        setupConstraints()
        setupDismissGesture()
        buildSections()
    }
    
    @objc private func dismissView() { dismiss(animated: true) }
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubviews(scrollView, confirmButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.width.lessThanOrEqualTo(360)
            $0.height.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.8)
            $0.height.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.height).multipliedBy(0.5)
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
    
    private func buildSections() {
        items.forEach { item in
            let section = makeSectionStack(title: item.title, body: item.description)
            contentStack.addArrangedSubview(section)
        }
    }
    
    private func makeSectionStack(title: String, body: String) -> UIStackView {
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
        return sv
    }
    
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: view)
        return !containerView.frame.contains(point)
    }
}
