//
//  DateButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/19/25.
//

import UIKit
import SnapKit

// MARK: - DateButton
final class DateButton: UIButton {
    
    private let dateFormatter: DateFormatter = .korea(format: "yyyy.MM.dd")

    private let placeholderText = "YYYY.MM.DD"   // 선택 전 표시
    private var hasUserSelected = false          // 선택 여부

    private(set) var currentDate: Date? {
        didSet { updateConfigurationText() }
    }
    
    /// 외부에서 날짜 변경 이벤트 받기
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfiguration()
        addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfiguration()
        addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
    }
    
    // MARK: - UI 설정
    private func setupConfiguration() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "calendar")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = .secondaryLabel   // 선택 전 회색
        config.baseBackgroundColor = .systemGray6
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.pretendard(style: .medium, size: 14)
            return out
        }
        self.configuration = config

        updateConfigurationText()
    }
    
    private func updateConfigurationText() {
        guard var config = self.configuration else { return }
        if hasUserSelected, let date = currentDate {
            config.title = dateFormatter.string(from: date)
            config.baseForegroundColor = .label
        } else {
            config.title = placeholderText
            config.baseForegroundColor = .secondaryLabel
        }
        self.configuration = config
    }
    
    // MARK: - Public
    public func setDate(_ date: Date) {
        hasUserSelected = true
        self.currentDate = date
        onDateChanged?(date)
    }

    public func clearSelection() {
        hasUserSelected = false
        self.currentDate = nil
    }
    
    // MARK: - Actions
    @objc private func didTapButton() {
        guard let parentVC = self.parentViewController else { return }

        // 🔧 CHANGED: initialDate를 Optional로 전달
        let pickerVC = DatePickerSheetController(initialDate: currentDate)
        
        pickerVC.onDateSelected = { [weak self] newDate in
            self?.setDate(newDate) // 버튼 텍스트 + currentDate 업데이트
        }
        
        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return 250 // 원하는 높이
            }]
            sheet.prefersGrabberVisible = true
        }
        
        parentVC.present(pickerVC, animated: true)
    }
}

// UIView → 소속 VC 찾기
extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}

// MARK: - DatePickerSheetController
final class DatePickerSheetController: UIViewController {
    
    // MARK: - Properties
    var onDateSelected: ((Date) -> Void)?
    
    private let picker = UIPickerView()
    private let confirmButton: ConfirmButton = ConfirmButton(title: "확인")
    
    private var selectedYear: Int
    private var selectedMonth: Int
    private var selectedDay: Int
    
    private let years = Array(1980...2035)
    private let months = Array(1...12)
    private var days: [Int] {
        let comps = DateComponents(
            year: selectedYear,
            month: selectedMonth
        )
        let calendar = Calendar.korea
        let date = calendar.date(from: comps)!
        let range = calendar.range(
            of: .day,
            in: .month,
            for: date
        )!
        return Array(range)
    }
    
    // MARK: - Init
    init(initialDate: Date?) {
        let base = initialDate ?? Date() // 선택 전이면 오늘 날짜로 '표시만' 초기화
        let calendar = Calendar.korea
        self.selectedYear = calendar.component(.year, from: base)
        self.selectedMonth = calendar.component(.month, from: base)
        self.selectedDay = calendar.component(.day, from: base)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        picker.delegate = self
        picker.dataSource = self
        
        setupLayout()
        setupConstraints()
        setupInitialSelection()
        
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup
    private func setupLayout() {
        view.addSubviews(
            picker,
            confirmButton
        )
    }
    
    private func setupConstraints() {
        picker.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(30)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(picker.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-30)
            $0.height.equalTo(50)
        }
    }
    
    private func setupInitialSelection() {
        if let yearIndex = years.firstIndex(of: selectedYear) {
            picker.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        picker.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
        picker.selectRow(selectedDay - 1, inComponent: 2, animated: false)
    }
    
    // MARK: - Confirm
    @objc private func confirmTapped() {
        let comps = DateComponents(
            year: selectedYear,
            month: selectedMonth,
            day: selectedDay
        )
        
        if let date = Calendar.korea.date(from: comps) {
            onDateSelected?(date) // 확인 시에만 실제 값 전달
        }
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension DatePickerSheetController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return years.count
        case 1: return months.count
        default: return days.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(years[row])년"
        case 1: return "\(months[row])월"
        default: return "\(days[row])일"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                      viewForRow row: Int,
                      forComponent component: Int,
                      reusing view: UIView?) -> UIView {
          let label = (view as? UILabel) ?? UILabel()
          label.textAlignment = .center
          label.font = UIFont.pretendard(style: .medium, size: 23) 
          label.textColor = .label

          switch component {
          case 0: label.text = "\(years[row])년"
          case 1: label.text = "\(months[row])월"
          default: label.text = "\(days[row])일"
          }
          return label
      }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: selectedYear = years[row]
        case 1: selectedMonth = months[row]
        case 2: selectedDay = days[row]
        default: break
        }
        
        if component != 2 {
            picker.reloadComponent(2)
            if selectedDay > days.count {
                selectedDay = days.last ?? 1
                picker.selectRow(days.count - 1, inComponent: 2, animated: true)
            }
        }
    }
}
