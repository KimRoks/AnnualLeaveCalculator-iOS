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
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    private let contentView = UIView()
    
    // MARK: - 상세보기
    private let detailCardView: CardView = CardView()
    
    private let detailLable: UILabel =  {
        let label = UILabel()
        label.text = "상세 정보"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    
    // MARK: CalculationDetail
    private let detailSeparator: Separator = Separator()
    
    private let detailStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private let accrualPeriodLabel: UILabel = UILabel()
    private let availablePeriodLabel: UILabel = UILabel()
    private let serviceYearsLabel: UILabel = UILabel()
    private let attendanceRateLabel: UILabel = UILabel()
    private let prescribedWorkingRatioLabel: UILabel = UILabel()
    private let baseAnnualLeaveLabel: UILabel = UILabel()
    private let additionalLeaveLabel: UILabel = UILabel()
    private let totalLeaveDaysLabel: UILabel = UILabel()
    private let detialSeparatorBottom: Separator = Separator()
    
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
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(detailCardView)
        
        // 카드 내부에 헤더, 구분선, 상세 스택뷰 순서로 배치
        detailCardView.addSubviews(
            detailLable,
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
            detialSeparatorBottom,
            totalLeaveDaysLabel
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
        
        detailCardView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        detailLable.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        detailSeparator.snp.makeConstraints {
            $0.top.equalTo(detailLable.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        detailStack.snp.makeConstraints {
            $0.top.equalTo(detailSeparator.snp.bottom).offset(12)
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
            $0.numberOfLines = 1
        }
    
        totalLeaveDaysLabel.font = .pretendard(style: .bold, size: 14)
    }
    
    // MARK: - Bind
    private func bindCalculationDetail() {
        let detail = result.calculationDetail
        
        // 연차 산정 기간: yyyy-MM-dd ~ yyyy-MM-dd
        if let accrualPeriod = detail.accrualPeriod {
            accrualPeriodLabel.text = "연차 산정 기간:  \(accrualPeriod.startDate) ~ \(accrualPeriod.endDate)"
        } else {
            accrualPeriodLabel.text = "연차 산정 기간:  -"
        }
        
        // 가용 기간: yyyy-MM-dd ~ yyyy-MM-dd
        if let availablePerriod = detail.availablePeriod {
            availablePeriodLabel.text = "연차 가용 기간:  \(availablePerriod.startDate) ~ \(availablePerriod.endDate)"
        } else {
            availablePeriodLabel.text = "연차 가용 기간:  -"
        }
        
        // 근속연수: N년
        serviceYearsLabel.text = "근속연수:  \(detail.serviceYears)년"
        
        // 출근율: xx.x%
        if let rate = detail.attendanceRate {
            attendanceRateLabel.text = "출근율:  \(formatPercent(rate))"
        } else {
            attendanceRateLabel.text = "출근율:  -"
        }
        
        // 소정근로비율: xx.x%
        if let ratio = detail.prescribedWorkingRatio {
            prescribedWorkingRatioLabel.text = "소정근로비율:  \(formatPercent(ratio))"
        } else {
            prescribedWorkingRatioLabel.text = "소정근로비율:  -"
        }
        
        // 기본 연차: N일
        if let base = detail.baseAnnualLeave {
            baseAnnualLeaveLabel.text = "기본 연차:  \(base)일"
        } else {
            baseAnnualLeaveLabel.text = "기본 연차:  -"
        }
        
        // 가산 연차: N일
        if let add = detail.additionalLeave {
            additionalLeaveLabel.text = "가산 연차:  \(add)일"
        } else {
            additionalLeaveLabel.text = "가산 연차:  -"
        }
        
        // 총 발생 연차: N일 (항상 존재)
        totalLeaveDaysLabel.text = "총 발생 연차:  \(detail.totalLeaveDays)일"
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
