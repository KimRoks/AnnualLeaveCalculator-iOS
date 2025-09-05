//
//  MainViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import UIKit
import Combine
import SnapKit

class MainViewController: BaseViewController {

    private let viewModel: MainViewModel = MainViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: Container
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()

    // MARK: FirstCard
    private let firstCardStackView: CardStackView = CardStackView()
    private let calculationTypeView: UIView = UIView()
    private let calculationTypeLabel = SubtitleLabel(title: "산정 방식")
    private let caculatationTypeButton = CalculationTypeButton(items: ["입사일", "회계연도"])
    private let helpButton1: HelpButton = HelpButton()

    // 가로 레이아웃용 StackViews
    private let hireStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        return sv
    }()
    private let hireDateLabel = SubtitleLabel(title: "입사일")
    private let hireDateButton = DateButton()

    private let referenceStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        return sv
    }()
    private let referenceDateLabel = SubtitleLabel(title: "계산 기준일")
    private let referenceDateButton = DateButton()

    private let fiscalYearStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 30
        sv.alignment = .center
        sv.isHidden = true
        return sv
    }()
    private let fiscalYearLabel = SubtitleLabel(title: "회계연도 시작일")
    private let fiscalYearButton = FiscalButton()

    // MARK: SecondCard
    private let secondCardStackView: CardStackView = CardStackView()
    private let calculationDetailView: UIView = UIView()
    private let calculationDetailLabel: SubtitleLabel = SubtitleLabel(title: "특이 사항이 있는 기간")
    private let helpButton2: HelpButton = HelpButton()
    private let addDetailButton: ChevronButton = ChevronButton(title: "추가하기")
    private let detailTableView: UITableView = UITableView()
    private let optionalInfoLabel: OptionalLabel = OptionalLabel()

    // MARK: ThirdCard
    private let thirdCardStackView: CardStackView = CardStackView()
    private let companyHolidaysView: UIView = UIView()
    private let companyHolidaysLabel: SubtitleLabel = SubtitleLabel(title: "회사 자체 휴일")
    private let helpButton3: HelpButton = HelpButton()
    private let holidaysOptionalLabel: OptionalLabel = OptionalLabel()
    private let addHolidayButton: ChevronButton = ChevronButton(title: "추가하기")
    private let holidayListTableView: UITableView = UITableView()

    private let confirmButton = ConfirmButton(title: "계산하기")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        setupLayout()
        setupConstraints()
        setupActions()
        setupDetailTableView()
        setupHolidayTableView()
        bind()

        // 회계연도 버튼이 MM.01 형태라면 month/day만 사용 → Date 자체를 넘겨두고 VM에서 "MM-dd"로 변환
        viewModel.setFiscalYearDate.send(fiscalYearButton.currentDate)
        // 초기 산정 방식(세그먼트 0: 입사일 기반)
        viewModel.setCalculationType.send(caculatationTypeButton.selectedSegmentIndex == 0 ? 1 : 2)
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerStackView)

        // Container
        containerStackView.addArrangedSubviews(
            firstCardStackView,
            secondCardStackView,
            thirdCardStackView,
            confirmButton
        )

        // Card1
        firstCardStackView.addArrangedSubviews(
            calculationTypeView,
            hireStackView,
            referenceStackView,
            fiscalYearStackView
        )

        calculationTypeView.addSubviews(
            calculationTypeLabel,
            helpButton1,
            caculatationTypeButton
        )

        // 가로 Row 구성: [Label] [Button]
        hireStackView.addArrangedSubviews(
            hireDateLabel,
            hireDateButton
        )

        referenceStackView.addArrangedSubviews(
            referenceDateLabel,
            referenceDateButton
        )

        fiscalYearStackView.addArrangedSubviews(
            fiscalYearLabel,
            fiscalYearButton
        )

        // 버튼이 우측으로 자연스럽게 늘어나도록 우선순위 조정
        [hireDateButton, referenceDateButton, fiscalYearButton].forEach {
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        [hireDateLabel, referenceDateLabel, fiscalYearLabel].forEach {
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        // Card2
        secondCardStackView.addArrangedSubviews(
            calculationDetailView
        )

        calculationDetailView.addSubviews(
            calculationDetailLabel,
            helpButton2,
            optionalInfoLabel,
            addDetailButton,
            detailTableView
        )

        // Card3
        thirdCardStackView.addArrangedSubviews(
            companyHolidaysView
        )

        companyHolidaysView.addSubviews(
            companyHolidaysLabel,
            helpButton3,
            holidaysOptionalLabel,
            addHolidayButton,
            holidayListTableView
        )
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        containerStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }

        calculationTypeLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview()
        }

        caculatationTypeButton.snp.makeConstraints {
            $0.top.equalTo(calculationTypeLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        helpButton1.snp.makeConstraints {
            $0.centerY.equalTo(calculationTypeLabel)
            $0.leading.equalTo(calculationTypeLabel.snp.trailing).offset(5)
            $0.width.height.equalTo(20)
        }

        // Card2
        calculationDetailLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        helpButton2.snp.makeConstraints {
            $0.centerY.equalTo(calculationDetailLabel)
            $0.leading.equalTo(calculationDetailLabel.snp.trailing).offset(5)
            $0.width.height.equalTo(20)
        }

        optionalInfoLabel.snp.makeConstraints {
            $0.top.equalTo(calculationDetailLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview()
        }

        addDetailButton.snp.makeConstraints {
            $0.centerY.equalTo(calculationDetailLabel)
            $0.trailing.equalToSuperview()
        }

        detailTableView.snp.makeConstraints {
            $0.top.equalTo(optionalInfoLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0) // 초기값(내용 바인딩 후 동적 업데이트)
            $0.bottom.equalToSuperview()
        }

        // Card3
        companyHolidaysLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        holidaysOptionalLabel.snp.makeConstraints {
            $0.top.equalTo(companyHolidaysLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview()
        }

        helpButton3.snp.makeConstraints {
            $0.centerY.equalTo(companyHolidaysLabel)
            $0.leading.equalTo(companyHolidaysLabel.snp.trailing).offset(5)
            $0.width.height.equalTo(20)
        }

        addHolidayButton.snp.makeConstraints {
            $0.centerY.equalTo(companyHolidaysLabel)
            $0.trailing.equalToSuperview()
        }

        holidayListTableView.snp.makeConstraints {
            $0.top.equalTo(holidaysOptionalLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0) // 내용 기반으로 갱신
        }

        confirmButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        hireDateButton.snp.makeConstraints {
            $0.width.equalTo(fiscalYearButton)
        }
        
        referenceDateButton.snp.makeConstraints {
            $0.width.equalTo(fiscalYearButton)
        }
    }

    private func setupDetailTableView() {
        detailTableView.delegate = self
        detailTableView.dataSource = self

        detailTableView.register(
            DetailCell.self,
            forCellReuseIdentifier: DetailCell.reuseIdentifier
        )
        detailTableView.isScrollEnabled = false
        detailTableView.rowHeight = UITableView.automaticDimension
        detailTableView.estimatedRowHeight = 60
    }

    private func setupHolidayTableView() {
        holidayListTableView.delegate = self
        holidayListTableView.dataSource = self

        holidayListTableView.register(
            HolidaysTableViewCell.self,
            forCellReuseIdentifier: HolidaysTableViewCell.reuseIdentifier
        )
        holidayListTableView.isScrollEnabled = false
        holidayListTableView.rowHeight = UITableView.automaticDimension
        holidayListTableView.estimatedRowHeight = 60
    }

    // MARK: - Actions
    private func setupActions() {
        caculatationTypeButton.addTarget(self, action: #selector(segmentedChanged(_:)), for: .valueChanged)
        addHolidayButton.addTarget(self, action: #selector(addHolidayTapped), for: .touchUpInside)
        addDetailButton.addTarget(self, action: #selector(pushToDetailView), for: .touchUpInside)
        helpButton1.addTarget(self, action: #selector(pushToHelp1View), for: .touchUpInside)
        
        
        // DateButton 값 변경을 VM에 반영
        hireDateButton.onDateChanged = { [weak self] date in
            self?.viewModel.setHireDate.send(date)
        }
        referenceDateButton.onDateChanged = { [weak self] date in
            self?.viewModel.setReferenceDate.send(date)
        }
        // Fiscal(회계연도 시작일)
        fiscalYearButton.onMonthChanged = { [weak self] date in
            self?.viewModel.setFiscalYearDate.send(date)
        }

        // 확인(계산하기) → 요청 빌드
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    @objc private func didTapConfirm() {
        // 최신 UI 상태를 VM에 보장
        viewModel.setCalculationType.send(caculatationTypeButton.selectedSegmentIndex == 0 ? 1 : 2)
        
        guard let hireDate = hireDateButton.currentDate else {
            showAlert(message: "입사일을 선택해주세요.")
            return
        }
        
        guard let referenceDate = referenceDateButton.currentDate else {
            showAlert(message: "계산 기준일을 선택해주세요.")
            return
        }
        
        viewModel.setHireDate.send(hireDate)
        viewModel.setReferenceDate.send(referenceDate)
        viewModel.setFiscalYearDate.send(fiscalYearButton.currentDate)

        // 요청 빌드 트리거
        viewModel.buildRequest.send(())

        // 빌드된 요청 확인(여기선 프린트; 네트워킹 레이어로 넘기면 됨)
        if let req = viewModel.lastBuiltRequest,
           let json = try? JSONEncoder.prettyK.encode(req),
           let text = String(data: json, encoding: .utf8) {
            print("🚀 Request JSON\n\(text)")
        } else {
            print("⚠️ 요청 생성 실패")
        }
    }

    @objc private func segmentedChanged(_ sender: UISegmentedControl) {
        fiscalYearStackView.isHidden = (sender.selectedSegmentIndex == 0)
        viewModel.setCalculationType.send(sender.selectedSegmentIndex == 0 ? 1 : 2)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func pushToHelp1View() {
        let help1VC = Help1ViewController()
        help1VC.modalPresentationStyle = .overCurrentContext
        help1VC.modalTransitionStyle = .crossDissolve

        navigationController?.present(help1VC, animated: true)
    }

    @objc
    private func pushToDetailView() {
        let detailVM = DetailViewModel(initialRows: viewModel.details)
        let detailVC = DetailViewController(viewModel: detailVM)

        // DetailVC의 ViewModel.rows를 실시간 구독해서 MainViewModel에 반영
        detailVC.viewModel.$rows
            .receive(on: RunLoop.main)
            .sink { [weak self] rows in
                self?.viewModel.setDetails.send(rows)
            }
            .store(in: &cancellables)

        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc
    private func addHolidayTapped() {
        let picker = DatePickerSheetController(initialDate: Date())
        picker.onDateSelected = { [weak self] date in
            self?.viewModel.addHoliday.send(date)
        }
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.custom { _ in 250 }]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true)
    }

    // MARK: - Bind
    private func bind() {
        // 회사 자체 휴일 바인딩
        viewModel.$companyHolidays
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.holidayListTableView.reloadData()
                self.updateHolidayTableHeight()
            }
            .store(in: &cancellables)

        // 디테일(특이사항) 표 바인딩
        viewModel.$details
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.detailTableView.reloadData()
                self.updateDetailTableHeight()
            }
            .store(in: &cancellables)
    }

    private func updateHolidayTableHeight() {
        holidayListTableView.layoutIfNeeded()
        let contentHeight = holidayListTableView.contentSize.height
        holidayListTableView.snp.updateConstraints { $0.height.equalTo(contentHeight) }
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    private func updateDetailTableHeight() {
        detailTableView.layoutIfNeeded()
        let contentHeight = detailTableView.contentSize.height
        detailTableView.snp.updateConstraints { $0.height.equalTo(contentHeight) }
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}

// MARK: - TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch tableView {
        case detailTableView:
            return viewModel.details.count
        case holidayListTableView:
            return viewModel.companyHolidays.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case detailTableView:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailCell.reuseIdentifier,
                for: indexPath
            ) as? DetailCell else {
                return UITableViewCell()
            }
            let item = viewModel.details[indexPath.row]
            let duration = viewModel.durationText(for: item)
            cell.configureCell(title: item.reason, duration: duration)
            return cell

        case holidayListTableView:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: HolidaysTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? HolidaysTableViewCell else { return UITableViewCell() }

            let holidayDate = viewModel.companyHolidays[indexPath.row]
            cell.configureCell(with: holidayDate.toKoreanDateString())

            cell.onDeleteTapped = { [weak self, weak cell] in
                guard
                    let self = self,
                    let cell = cell,
                    let currentIndexPath = tableView.indexPath(for: cell)
                else { return }
                self.viewModel.removeHoliday.send(currentIndexPath)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - JSONEncoder prettify helper
extension JSONEncoder {
    static var prettyK: JSONEncoder {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        return enc
    }
}
