//
//  ResultDetailViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/19/25.
//

import UIKit
import SnapKit

final class ResultDetailViewController: BaseViewController {
    override var navigationTitle: String { "상세보기" }
    private let result: CalculationResultDTO
    
    // MARK: - Segmented
    private enum DetailMode { case monthly, prorated }
    private var segmentedControl: UISegmentedControl?
    private var detailTopConstraint: Constraint?
    
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
    
    // MARK: - Records (월별 발생 현황)
    private let recordsCardView: CardView = CardView()
    private let recordsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "월별 발생 현황"
        label.font = .pretendard(style: .bold, size: 15)
        return label
    }()
    private let recordsSeparator: Separator = Separator()
    private let recordsListStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    private let recordsSeparatorBotton: Separator = Separator()
    private let recordsTotalLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(style: .bold, size: 14)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private var explanationTopConstraint: Constraint?

    // MARK: - Explanations
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
        setupSegmentIfNeeded()
        
        if segmentedControl != nil {
            // 세그먼트가 있는 경우: 기본 탭은 연차(月次)
            render(for: .monthly)
        } else {
            // 기존 동작 유지
            bindCalculationDetail()
            bindRecords()
        }
        bindExplanation()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Order: (segmented?) → detail → records → explanation
        contentView.addSubview(detailCardView)
        contentView.addSubview(recordsCardView)
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
        
        // records card
        recordsCardView.addSubviews(
            recordsTitleLabel,
            recordsSeparator,
            recordsListStack,
            recordsSeparatorBotton,
            recordsTotalLabel
        )
        
        // explanation card (섹션 스택으로 구성)
        explanationCardView.addSubview(explanationContentStack)
        explanationSectionStack.addArrangedSubviews(
            explanationTitleLabel,
            explanationSeparator,
            explanationsStack
        )
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
            // 기본: 최상단에서 시작 (세그먼트가 생기면 변경)
            self.detailTopConstraint = $0.top.equalToSuperview().offset(20).constraint
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
        detailSeparatorBottom.snp.makeConstraints { $0.height.equalTo(1) }
        
        // records
        recordsCardView.snp.makeConstraints {
            $0.top.equalTo(detailCardView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        recordsTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        recordsSeparator.snp.makeConstraints {
            $0.top.equalTo(recordsTitleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        recordsListStack.snp.makeConstraints {
            $0.top.equalTo(recordsSeparator.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        recordsSeparatorBotton.snp.makeConstraints {
            $0.top.equalTo(recordsListStack.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        recordsTotalLabel.snp.makeConstraints {
            $0.top.equalTo(recordsSeparatorBotton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        // explanation (records 아래에 기본 연결)
        explanationCardView.snp.makeConstraints {
            self.explanationTopConstraint = $0.top.equalTo(recordsCardView.snp.bottom).offset(16).constraint
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
        totalLeaveDaysLabel.font = .pretendard(style: .bold, size: 14)
    }
    
    // MARK: - Segment Setup (only for MONTHLY_AND_PRORATED)
    private func setupSegmentIfNeeded() {
        guard result.leaveType == .monthlyAndProrated else { return }
        
        let control = UISegmentedControl(items: ["월차", "비례연차"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedChanged(_:)), for: .valueChanged)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style: .bold, size: 16),
            .foregroundColor: UIColor.gray
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style: .bold, size: 16),
            .foregroundColor: UIColor.black
        ]

        control.setTitleTextAttributes(normalAttributes, for: .normal)
        control.setTitleTextAttributes(selectedAttributes, for: .selected)

        segmentedControl = control
        contentView.addSubview(control)
        control.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // detailCardView top 재연결
        detailTopConstraint?.deactivate()
        detailCardView.snp.makeConstraints {
            self.detailTopConstraint = $0.top.equalTo(control.snp.bottom).offset(12).constraint
        }
    }

    
    @objc private func segmentedChanged(_ sender: UISegmentedControl) {
        let mode: DetailMode = (sender.selectedSegmentIndex == 0) ? .monthly : .prorated
        render(for: mode)
    }
    
    // MARK: - Render for Mode (Segmented)
    private func render(for mode: DetailMode) {
        switch mode {
        case .monthly:
            // monthlyDetail 우선 사용
            if let monthly = result.calculationDetail.monthlyDetail {
                // 라벨
                accrualPeriodLabel.text = "연차 산정 기간:  \(monthly.accrualPeriod.startDate) ~ \(monthly.accrualPeriod.endDate)"
                availablePeriodLabel.text = "연차 사용 기간:  \(monthly.availablePeriod.startDate) ~ \(monthly.availablePeriod.endDate)"
                totalLeaveDaysLabel.text = "연차 합계:  \(formatNumber(monthly.totalLeaveDays))일"
                
                // 월차 탭에서는 출근율/소정근로비율 감춤 (월차에는 해당 값 없음)
                attendanceRateLabel.text = nil
                attendanceRateLabel.isHidden = true
                prescribedWorkingRatioLabel.text = nil
                prescribedWorkingRatioLabel.isHidden = true
            } else {
                accrualPeriodLabel.text = "월차 산정 기간:  -"
                availablePeriodLabel.text = "월차 사용 기간:  -"
                totalLeaveDaysLabel.text = "월차 합계:  -"
                attendanceRateLabel.isHidden = true
                prescribedWorkingRatioLabel.isHidden = true
            }
            // 공통(근속/기본/가산)은 CalculationDetail에서 노출 (값 없으면 "-")
            bindCommonFields()
            // 기록(월별) 노출
            let records = result.calculationDetail.monthlyDetail?.records
                        ?? result.calculationDetail.records
                        ?? []
            bindRecords(records: records, anchorForExplanation: records.isEmpty ? detailCardView : recordsCardView)
            
        case .prorated:
            if let prorated = result.calculationDetail.proratedDetail {
                accrualPeriodLabel.text = "비례연차 산정 기간:  \(prorated.accrualPeriod.startDate) ~ \(prorated.accrualPeriod.endDate)"
                availablePeriodLabel.text = "비례연차 사용 기간:  \(prorated.availablePeriod.startDate) ~ \(prorated.availablePeriod.endDate)"
                totalLeaveDaysLabel.text = "비례연차 합계:  \(formatNumber(prorated.totalLeaveDays))일"
                
                // 비례 값 표시
                if let rate = prorated.attendanceRate {
                    attendanceRateLabel.text = "출근율:  \(formatPercent(rate))"
                    attendanceRateLabel.isHidden = false
                } else {
                    attendanceRateLabel.text = "출근율:  -"
                    attendanceRateLabel.isHidden = false
                }
                if let ratio = prorated.prescribedWorkingRatio {
                    prescribedWorkingRatioLabel.text = "소정근로비율:  \(formatPercent(ratio))"
                    prescribedWorkingRatioLabel.isHidden = false
                } else {
                    prescribedWorkingRatioLabel.text = "소정근로비율:  -"
                    prescribedWorkingRatioLabel.isHidden = false
                }
            } else {
                accrualPeriodLabel.text = "비례연차 산정 기간:  -"
                availablePeriodLabel.text = "비례연차 사용 기간:  -"
                totalLeaveDaysLabel.text = "비례연차 합계:  -"
                attendanceRateLabel.text = "출근율:  -"
                prescribedWorkingRatioLabel.text = "소정근로비율:  -"
                attendanceRateLabel.isHidden = false
                prescribedWorkingRatioLabel.isHidden = false
            }
            // 공통(근속/기본/가산)
            bindCommonFields()
            // 비례 탭에서는 월별 기록 숨김
            bindRecords(records: [], anchorForExplanation: detailCardView)
        }
    }
    
    private func bindCommonFields() {
        let detail = result.calculationDetail
        serviceYearsLabel.text = "근속연수:  \(detail.serviceYears)년"
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
    }
    
    // MARK: - 기존 바인딩(세그먼트 없는 경우 그대로 유지)
    private func bindCalculationDetail() {
        let detail = result.calculationDetail
        
        if let accrualPeriod = detail.accrualPeriod {
            accrualPeriodLabel.text = "연차 산정 기간:  \(accrualPeriod.startDate) ~ \(accrualPeriod.endDate)"
        } else {
            accrualPeriodLabel.text = "연차 산정 기간:  -"
        }
        
        if let availablePeriod = detail.availablePeriod {
            availablePeriodLabel.text = "연차 사용 기간:  \(availablePeriod.startDate) ~ \(availablePeriod.endDate)"
        } else {
            availablePeriodLabel.text = "연차 사용 기간:  -"
        }
        
        serviceYearsLabel.text = "근속연수:  \(detail.serviceYears)년"
        
        if let rate = detail.attendanceRate {
            attendanceRateLabel.text = "출근율:  \(formatPercent(rate))"
            attendanceRateLabel.isHidden = false
        } else {
            attendanceRateLabel.text = "출근율:  -"
            attendanceRateLabel.isHidden = true
        }
        
        if let ratio = detail.prescribedWorkingRatio {
            prescribedWorkingRatioLabel.text = "소정근로비율:  \(formatPercent(ratio))"
            prescribedWorkingRatioLabel.isHidden = false
        } else {
            prescribedWorkingRatioLabel.text = "소정근로비율:  -"
            prescribedWorkingRatioLabel.isHidden = true
        }
        
        totalLeaveDaysLabel.text = "총 발생 연차:  \(formatNumber(detail.totalLeaveDays))일"
        
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
    }
    
    private func attachExplanationTop(to anchorView: UIView) {
        explanationTopConstraint?.deactivate()
        explanationCardView.snp.makeConstraints { make in
            self.explanationTopConstraint = make.top.equalTo(anchorView.snp.bottom).offset(16).constraint
        }
    }
    
    // MARK: - Records
    private func bindRecords() {
        let records = result.calculationDetail.monthlyDetail?.records
                    ?? result.calculationDetail.records
                    ?? []
        bindRecords(records: records, anchorForExplanation: records.isEmpty ? detailCardView : recordsCardView)
    }
    
    private func bindRecords(records: [CalculationResultDTO.Record], anchorForExplanation: UIView) {
        // 기존 행 제거
        recordsListStack.arrangedSubviews.forEach { v in
            recordsListStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        if records.isEmpty {
            recordsCardView.isHidden = true
            recordsTotalLabel.text = nil
            attachExplanationTop(to: anchorForExplanation) // 일반적으로 detailCardView
            return
        }

        recordsCardView.isHidden = false
        attachExplanationTop(to: anchorForExplanation) // 일반적으로 recordsCardView

        var totalDays: Double = 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1

        for record in records {
            totalDays += record.monthlyLeave

            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .firstBaseline
            row.spacing = 8
            row.distribution = .fill

            let periodLabel = UILabel()
            periodLabel.font = .pretendard(style: .regular, size: 13)
            periodLabel.textColor = .label
            periodLabel.text = "\(record.period.startDate) ~ \(record.period.endDate)"

            let spacer = UIView()

            let daysLabel = UILabel()
            daysLabel.font = .pretendard(style: .bold, size: 13)
            daysLabel.textColor = .label
            daysLabel.setContentHuggingPriority(.required, for: .horizontal)
            daysLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            daysLabel.text = "\(formatNumber(record.monthlyLeave))일"

            row.addArrangedSubview(periodLabel)
            row.addArrangedSubview(spacer)
            row.addArrangedSubview(daysLabel)
            recordsListStack.addArrangedSubview(row)
        }
        
        recordsTotalLabel.text = "월별 합계: \(formatNumber(totalDays))일"
    }
    
    // MARK: - Explanations
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
        stack.arrangedSubviews.forEach { v in
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        for text in lines {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .pretendard(style: .regular, size: 13)
            label.textColor = .label
            label.text = "• \(text)"
            stack.addArrangedSubview(label)
        }
    }
    
    // MARK: - Format helpers
    private func formatPercent(_ value: Double) -> String {
        let percent = value <= 1.0 ? value * 100.0 : value
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let str = formatter.string(from: NSNumber(value: percent)) ?? "\(percent)"
        return "\(str)%"
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
