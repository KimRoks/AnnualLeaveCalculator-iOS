//
//  ResultViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/5/25.
//

import UIKit

import SnapKit

final class ResultViewController: BaseViewController {
    private let result: CalculationResultDTO
    
    private let titleLabel: SubtitleLabel = {
        let label = SubtitleLabel(title: "연차 계산 결과")
        
        return label
    }()
    
    private let subtitleLabel: OptionalLabel = {
        let label = OptionalLabel(title: "계산 결과는 참고용이며, 실제 회사 규정과 다를 수 있습니다.")
        
        return label
    }()
    
    // MARK: ResultCard
    
    private let resultCardView: CardView = CardView()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "계산 결과"
        label.font = .pretendard(style: .bold, size: 15)
        
        return label
    }()
    
    private let resultBadgeButton: ResultBadgeButton = ResultBadgeButton()
    
    private let resultDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        label.text = "약 n연간 열일한 당신의 가용 연차는.."
        let baseFont = UIFont.pretendard(style: .medium, size: 12)
        label.textColor = UIColor(hex: "#8E8E93")
        label.font = baseFont
        
        return label
    }()
    
    private let resultSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F2F2F2")
        
        return view
    }()
    
    private let resultCardLabel: PaddedLabel = {
        let label = PaddedLabel(insets: .init(top: 6, left: 10, bottom: 6, right: 10))
        label.backgroundColor = UIColor(hex: "#E7F2FF")
        label.textColor = UIColor(hex: "#153BD3")
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = .pretendard(style: .bold, size: 30)
        return label
    }()
    
    private let availabilityPeriodLabel: PaddedLabel = {
        let label = PaddedLabel(insets: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        label.font = .pretendard(style: .medium, size: 13)
        label.textColor = UIColor(hex: "#8E8E93")
        label.numberOfLines = 1
        label.backgroundColor = UIColor(hex: "#F7F7F7")
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: InfoCard
    
    private let infoCardView: CardView = CardView()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "계산 정보"
        label.font = .pretendard(style: .bold, size: 15)
        
        return label
    }()
    
    private let infoSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F2F2F2")
        
        return view
    }()
    
    private let calculationTypeLabel: OptionalLabel = OptionalLabel(title: "산정 기준")
    private let calculationTypeResultLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(style: .regular, size: 12)
        
        return label
    }()
    
    private let hireDateLabel: OptionalLabel = OptionalLabel(title: "입사일")
    private let hireDateResultLabel: UILabel = {
        let label = UILabel()
        label.text = "2025-02-01"
        label.font = .pretendard(style: .regular, size: 12)
        
        return label
    }()
    
    private let fiscalDateLabel: OptionalLabel = OptionalLabel(title: "회계연도 시작일")
    private let fiscalDateResultLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = .pretendard(style: .regular, size: 12)
        
        return label
    }()
    
    private let referenceDateLabel: OptionalLabel = OptionalLabel(title: "기준일")
    private let referenceDateResultLabel: UILabel = {
        let label = UILabel()
        label.text = "2025-02-01"
        label.font = .pretendard(style: .regular, size: 12)
        
        return label
    }()
    
    private let infoSeparator2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F2F2F2")
        
        return view
    }()
    
    // MARK: DetailCard
    
    private let detailCardView: CardView = CardView()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "상세보기"
        label.font = .pretendard(style: .bold, size: 15)
        
        return label
    }()
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        configureUI()
    }
    
    // MARK: init
    
    init(result: CalculationResultDTO) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ConfigureUI
    
    private func configureUI() {
        resultBadgeButton.configure(type: result.leaveType)
        bindResultDescriptionLabel()
        resultCardLabel.text = "총 \(result.calculationDetail.totalLeaveDays)일"
        bindAvailabilityPeriodLabel()
        bindInfoCard()
    }
    
    private func setupLayout() {
        view.addSubviews(
            titleLabel,
            subtitleLabel,
            resultCardView,
            infoCardView,
            detailCardView
        )
        
        resultCardView.addSubviews(
            resultLabel,
            resultBadgeButton,
            resultSeparator,
            resultDescriptionLabel,
            resultCardLabel,
            availabilityPeriodLabel
        )
        
        infoCardView.addSubviews(
            infoLabel,
            infoSeparator,
            calculationTypeLabel,
            calculationTypeResultLabel,
            fiscalDateLabel,
            fiscalDateResultLabel,
            hireDateLabel,
            hireDateResultLabel,
            referenceDateLabel,
            referenceDateResultLabel,
            infoSeparator2
        )
        
        detailCardView.addSubviews(
            detailLabel
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        resultCardView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        resultLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        resultBadgeButton.snp.makeConstraints {
            $0.centerY.equalTo(resultLabel)
            $0.leading.equalTo(resultLabel.snp.trailing).offset(2)
        }
        
        resultSeparator.snp.makeConstraints {
            $0.top.equalTo(resultLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        resultDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(resultSeparator.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        resultCardLabel.snp.makeConstraints {
            $0.top.equalTo(resultDescriptionLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        availabilityPeriodLabel.snp.makeConstraints {
            $0.top.equalTo(resultCardLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        infoCardView.snp.makeConstraints {
            $0.top.equalTo(resultCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        infoSeparator.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        calculationTypeLabel.snp.makeConstraints {
            $0.top.equalTo(infoSeparator.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
        }
        
        calculationTypeResultLabel.snp.makeConstraints {
            $0.top.equalTo(calculationTypeLabel)
            $0.leading.equalTo(calculationTypeLabel.snp.trailing).offset(15)
        }
        
        hireDateLabel.snp.makeConstraints {
            $0.top.equalTo(calculationTypeLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
        }
        
        hireDateResultLabel.snp.makeConstraints {
            $0.top.equalTo(hireDateLabel)
            $0.leading.equalTo(calculationTypeResultLabel)
        }
        
        fiscalDateLabel.snp.makeConstraints {
            $0.top.equalTo(calculationTypeLabel)
            $0.leading.equalTo(view.snp.centerX)
        }
        
        fiscalDateResultLabel.snp.makeConstraints {
            $0.top.equalTo(fiscalDateLabel)
            $0.leading.equalTo(fiscalDateLabel.snp.trailing).offset(15)
        }
        
        referenceDateLabel.snp.makeConstraints {
            $0.top.equalTo(hireDateLabel)
            $0.leading.equalTo(view.snp.centerX)
        }
        
        referenceDateResultLabel.snp.makeConstraints {
            $0.top.equalTo(referenceDateLabel)
            $0.leading.equalTo(fiscalDateResultLabel)
        }
        
        infoSeparator2.snp.makeConstraints {
            $0.top.equalTo(referenceDateResultLabel.snp.bottom).offset(10)
            $0.height.equalTo(1)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.snp.width).multipliedBy(0.4)
        }
        
        detailCardView.snp.makeConstraints {
            $0.top.equalTo(infoCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func bindResultDescriptionLabel() {
        guard let period = result.calculationDetail.availablePeriod else {
            resultDescriptionLabel.text = "열심히 일한 당신의 총 연차는"
            return
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard
            let start = formatter.date(from: period.startDate),
            let end = formatter.date(from: period.endDate)
        else {
            resultDescriptionLabel.text = "열심히 일한 당신의 총 연차는"
            return
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let diff = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        let days = max(0, diff) + 1
        
        resultDescriptionLabel.text = "\(days)일간 열심히 일한 당신의 총 연차는"
    }
    
    private func formatKRDate(_ iso: String) -> String {
        let inF = DateFormatter()
        inF.calendar = .init(identifier: .gregorian)
        inF.locale = Locale(identifier: "ko_KR")
        inF.timeZone = .init(secondsFromGMT: 0)
        inF.dateFormat = "yyyy-MM-dd"
        
        let outF = DateFormatter()
        outF.calendar = .init(identifier: .gregorian)
        outF.locale = Locale(identifier: "ko_KR")
        outF.timeZone = .current
        outF.dateFormat = "yyyy년 MM월 dd일"
        
        guard let d = inF.date(from: iso) else { return iso }
        return outF.string(from: d)
    }
    
    private func bindAvailabilityPeriodLabel() {
        let font = availabilityPeriodLabel.font ?? .systemFont(ofSize: 10)
        let color = availabilityPeriodLabel.textColor ?? .label
        
        let periodText: String = {
            if let period = result.calculationDetail.availablePeriod {
                return "사용 가능 기간:  \(period.startDate) ~ \(period.endDate)"
            } else {
                return "사용 가능 기간:  -"
            }
        }()
        
        let symConfig = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .medium)
        let symbol = UIImage(systemName: "calendar", withConfiguration: symConfig)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
        
        let att = NSMutableAttributedString()
        
        if let symbol = symbol {
            let attachment = NSTextAttachment()
            attachment.image = symbol
            let yOffset = (font.capHeight - symbol.size.height) / 2
            attachment.bounds = CGRect(x: 0, y: yOffset, width: symbol.size.width, height: symbol.size.height)
            
            att.append(NSAttributedString(attachment: attachment))
            att.append(NSAttributedString(string: " "))
        }
        
        att.append(NSAttributedString(
            string: periodText,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        ))
        
        availabilityPeriodLabel.attributedText = att
    }
    
    private func bindInfoCard() {
        calculationTypeResultLabel.text = result.calculationType
        hireDateResultLabel.text = result.hireDate
        referenceDateResultLabel.text = result.referenceDate
        if let fiscalYear = result.fiscalYear {
            fiscalDateResultLabel.text = fiscalYear
        } else {
            fiscalDateResultLabel.text = "-"
        }
    }
}
