//
//  FiscalButton.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/27/25.
//

import UIKit
import SnapKit

// MARK: - FiscalButton
final class FiscalButton: UIButton {

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M월 d일"
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        return df
    }()

    private(set) var currentDate: Date = {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        var comps = calendar.dateComponents([.year, .month], from: now)
        comps.month = 1 // 보통 1월임
        
        return calendar.date(from: comps)! // 항상 1일
    }() {
        didSet { updateConfigurationText() }
    }

    var onMonthChanged: ((Date) -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConfiguration()
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfiguration()
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    private func setupConfiguration() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray6
        config.cornerStyle = .medium
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.pretendard(style: .medium, size: 14)
            return out
        }
        
        self.configuration = config
        self.configuration = config
        updateConfigurationText()
    }

    private func updateConfigurationText() {
        guard var config = self.configuration else { return }
        
        config.title = dateFormatter.string(from: currentDate)
        config.baseForegroundColor = .label
        
        self.configuration = config
    }

    public func setMonth(_ date: Date) {
        self.currentDate = date
        onMonthChanged?(date)
    }

    @objc private func didTapButton() {
        guard let parentVC = self.parentViewController else { return }
        let pickerVC = MonthPickerSheetController(initialDate: currentDate)

        pickerVC.onMonthSelected = { [weak self] newDate in
            self?.setMonth(newDate)
        }

        if let sheet = pickerVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 200 }]
            sheet.prefersGrabberVisible = true
        }
        parentVC.present(pickerVC, animated: true)
    }
}

// MARK: - MonthPickerSheetController
final class MonthPickerSheetController: UIViewController {

    var onMonthSelected: ((Date) -> Void)?

    private let picker = UIPickerView()
    private let confirmButton = ConfirmButton(title: "확인")

    private var selectedMonth: Int
    private let months = Array(1...12)

    private let calendar = Calendar(identifier: .gregorian)
    private let currentYear: Int

    init(initialDate: Date) {
        self.currentYear = Calendar.current.component(.year, from: initialDate)
        self.selectedMonth = Calendar.current.component(.month, from: initialDate)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        picker.delegate = self
        picker.dataSource = self

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        view.addSubviews(picker, confirmButton)

        picker.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(picker.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-30)
            $0.height.equalTo(50)
        }

        if let monthIndex = months.firstIndex(of: selectedMonth) {
            picker.selectRow(monthIndex, inComponent: 0, animated: false)
        }
    }

    @objc private func confirmTapped() {
        var comps = DateComponents()
        comps.year = currentYear
        comps.month = selectedMonth
        comps.day = 1

        if let date = calendar.date(from: comps) {
            onMonthSelected?(date)
        }
        dismiss(animated: true)
    }
}

extension MonthPickerSheetController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { months.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(months[row])월"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMonth = months[row]
    }
}
