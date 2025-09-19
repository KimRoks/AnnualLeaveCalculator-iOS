//
//  ResultDetailViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/19/25.
//

import UIKit
import SnapKit

final class ResultDetailViewController: BaseViewController {
    private let result: CalculationResultDTO
    
    // MARK: - Scroll Container
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let contentView = UIView()
    
    // MARK: - 상세보기
    private let detailCardView: CardView = CardView()
    
    private let detailLabel: UILabel =  {
        let label = UILabel()
        label.text = "상세 정보"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    
    // MARK: CalculationDetail
    private let detailSeparator: Separator = Separator()
    
    private let detailStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private let accrualPeriodLabel: UILabel = UILabel()
    private let availablePeriodLabel: UILabel = UILabel()
    private let serviceYearsLabel: UILabel = UILabel()
    private let attendanceRateLabel: UILabel = UILabel()
    private let prescribedWorkingRatioLabel: UILabel = UILabel()
    private let baseAnnualLeaveLabel: UILabel = UILabel()
    private let additionalLeaveLabel: UILabel = UILabel()
    private let totalLeaveDaysLabel: UILabel = UILabel()
    private let detailSeparatorBottom: Separator = Separator()
    
    // MARK: Explanations
    private let explanationCardView: CardView = CardView()
    private let explanationContentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    // 섹션 1: 계산 기준 설명
    private let explanationSectionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let explanationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "계산 기준 설명"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    private let explanationSeparator: Separator = Separator()
    
    // 불릿 렌더용 스택
    private let explanationsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // 섹션 2: 특이사항 관련 설명
    private let nonWorkingExplanationSectionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let nonWorkingExplanationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "특이사항 관련 설명"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    private let nonWorkingExplanationSeparator: Separator = Separator()
    
    private let nonWorkingExplanationsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Init
    init(result: CalculationResultDTO) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        setupLabelStyles()
        bindCalculationDetail()
        bindExplanation()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(detailCardView)
        contentView.addSubview(explanationCardView)
        
        // detail card
        detailCardView.addSubviews(
            detailLabel,
            detailSeparator,
            detailStack
        )
        
        detailStack.addArrangedSubviews(
            accrualPeriodLabel,
            availablePeriodLabel,
            serviceYearsLabel,
            attendanceRateLabel,
            prescribedWorkingRatioLabel,
            baseAnnualLeaveLabel,
            additionalLeaveLabel,
            detailSeparatorBottom,
            totalLeaveDaysLabel
        )
        
        explanationCardView.addSubview(explanationContentStack)
        
        // Explanation - 섹션 1
        explanationSectionStack.addArrangedSubviews(
            explanationTitleLabel,
            explanationSeparator,
            explanationsStack
        )
        
        // Explanation - 섹션 2
        nonWorkingExplanationSectionStack.addArrangedSubviews(
            nonWorkingExplanationTitleLabel,
            nonWorkingExplanationSeparator,
            nonWorkingExplanationsStack
        )
    
        explanationContentStack.addArrangedSubviews(
            explanationSectionStack,
            nonWorkingExplanationSectionStack
        )
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        // detail
        detailCardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        detailSeparator.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        detailStack.snp.makeConstraints {
            $0.top.equalTo(detailSeparator.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        // explanation
        explanationCardView.snp.makeConstraints {
            $0.top.equalTo(detailCardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        explanationContentStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupLabelStyles() {
        // 본문 라벨 스타일 통일
        let labels: [UILabel] = [
            accrualPeriodLabel,
            availablePeriodLabel,
            serviceYearsLabel,
            attendanceRateLabel,
            prescribedWorkingRatioLabel,
            baseAnnualLeaveLabel,
            additionalLeaveLabel,
            totalLeaveDaysLabel
        ]
        labels.forEach {
            $0.font = .pretendard(style: .regular, size: 13)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        detailSeparatorBottom.snp.makeConstraints { $0.height.equalTo(1) }
        totalLeaveDaysLabel.font = .pretendard(style: .bold, size: 14)
    }
    
    // MARK: - Bind
    private func bindCalculationDetail() {
        let detail = result.calculationDetail
        
        if let accrualPeriod = detail.accrualPeriod {
            accrualPeriodLabel.text = "연차 산정 기간:  \(accrualPeriod.startDate) ~ \(accrualPeriod.endDate)"
        } else {
            accrualPeriodLabel.text = "연차 산정 기간:  -"
        }
        
        if let availablePeriod = detail.availablePeriod {
            availablePeriodLabel.text = "연차 가용 기간:  \(availablePeriod.startDate) ~ \(availablePeriod.endDate)"
        } else {
            availablePeriodLabel.text = "연차 가용 기간:  -"
        }
        
        serviceYearsLabel.text = "근속연수:  \(detail.serviceYears)년"
        
        if let rate = detail.attendanceRate {
            attendanceRateLabel.text = "출근율:  \(formatPercent(rate))"
        } else {
            attendanceRateLabel.text = "출근율:  -"
        }
        
        if let ratio = detail.prescribedWorkingRatio {
            prescribedWorkingRatioLabel.text = "소정근로비율:  \(formatPercent(ratio))"
        } else {
            prescribedWorkingRatioLabel.text = "소정근로비율:  -"
        }
        
        if let base = detail.baseAnnualLeave {
            baseAnnualLeaveLabel.text = "기본 연차:  \(base)일"
        } else {
            baseAnnualLeaveLabel.text = "기본 연차:  -"
        }
        
        if let add = detail.additionalLeave {
            additionalLeaveLabel.text = "가산 연차:  \(add)일"
        } else {
            additionalLeaveLabel.text = "가산 연차:  -"
        }
        
        totalLeaveDaysLabel.text = "총 발생 연차:  \(detail.totalLeaveDays)일"
    }
    
    private func bindExplanation() {
        // 계산 기준 설명
        let explanations = result.explanations
        applyBullets(explanations, to: explanationsStack)
        let hasExplanations = explanations.isEmpty == false
        explanationSectionStack.isHidden = !hasExplanations
        
        // 특이사항 관련 설명 (옵셔널)
        let nonWorking = result.nonWorkingExplanations ?? []
        applyBullets(nonWorking, to: nonWorkingExplanationsStack)
        let hasNonWorking = nonWorking.isEmpty == false
        nonWorkingExplanationSectionStack.isHidden = !hasNonWorking
    }
    
    // 불릿 라벨 생성 & 스택 채우기
    private func applyBullets(_ lines: [String], to stack: UIStackView) {
        // 기존 항목 제거
        stack.arrangedSubviews.forEach { v in
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        for text in lines {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .pretendard(style: .regular, size: 13)
            label.textColor = .secondaryLabel
            label.text = "• \(text)"
            stack.addArrangedSubview(label)
        }
    }
    
    // 백분율 포맷 헬퍼 (0~1이면 ×100, 아니면 그대로 % 처리)
    private func formatPercent(_ value: Double) -> String {
        let percent = value <= 1.0 ? value * 100.0 : value
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let str = formatter.string(from: NSNumber(value: percent)) ?? "\(percent)"
        return "\(str)%"
    }
}
