//  MainVM.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/29/25.
//

import Foundation
import Combine

// 휴일 화면 표시 전용
struct CompanyHolidayRow: Equatable {
    let reason: String
    let date: Date
}

struct CalculationRequest: Encodable {
    let calculationType: Int
    let fiscalYear: String?
    let hireDate: String?
    let referenceDate: String?
    let nonWorkingPeriods: [NonWorkingPeriodDTO]
    let companyHolidays: [String]
}

struct NonWorkingPeriodDTO: Encodable {
    let type: Int
    let startDate: String
    let endDate: String
}

// ✅ 확인 버튼 누를 때만 사용할 검증 에러
enum MainValidationError: LocalizedError {
    case hireAfterReference
    case detailsOutOfRange
    case holidaysOutOfRange
    case referenceOutOfRange
    
    var errorDescription: String? {
        switch self {
        case .hireAfterReference:
            return "입사일은 계산 기준일보다 늦을 수 없습니다."
        case .detailsOutOfRange:
            return "특이 사항의 기간을 다시 확인해주세요."
        case .holidaysOutOfRange:
            return "공휴일 외 회사휴일의 기간을 다시 확인해주세요."
        case .referenceOutOfRange:
            return "계산 기준일을 2017년 5월 30일 이후로 설정해주세요."
        }
    }
}

final class MainViewModel {

    // MARK: - Inputs
    let removeHoliday = PassthroughSubject<IndexPath, Never>()
    let removeDetails = PassthroughSubject<IndexPath, Never>()
    let setDetails = PassthroughSubject<[DetailRow], Never>()
    let setHolidays = PassthroughSubject<[CompanyHolidayRow], Never>()
    let confirmTapped = PassthroughSubject<Void, Never>()

    // MARK: - Inputs (기본값)
    let setCalculationType = CurrentValueSubject<Int, Never>(1)
    let setHireDate = CurrentValueSubject<Date, Never>(Date())
    let setReferenceDate = CurrentValueSubject<Date, Never>(Date())
    let setFiscalYearDate = CurrentValueSubject<Date?, Never>(nil)

    // MARK: - Outputs (상태)
    /// 서버 요청용(yyyy-MM-dd로 변환해서 보냄) – 과거 코드 호환 위해 유지
    @Published private(set) var companyHolidays: [Date] = []
    /// 화면 표시용(사유 + 날짜)
    @Published private(set) var companyHolidayRows: [CompanyHolidayRow] = []

    @Published private(set) var details: [DetailRow] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastResult: CalculationResultDTO?
    let error = PassthroughSubject<Error, Never>()

    @Published private(set) var lastBuiltRequest: CalculationRequest?

    private var cancellables = Set<AnyCancellable>()
    private let calculatorUseCase: AnnualLeaveCalculatorUseCase
    private let calendar = Calendar.korea
    
    
    private static let referenceBaselineDate: Date = {
            var components = DateComponents()
            components.year = 2017
            components.month = 5
            components.day = 30
            let calendar = Calendar.korea
            // 2017-05-30 00:00 KST
            return calendar.date(from: components)!
        }()
    

    init(calculatorUseCase: AnnualLeaveCalculatorUseCase) {
        self.calculatorUseCase = calculatorUseCase
        bind()
    }

    private func bind() {
        // 삭제
        removeHoliday
            .sink { [weak self] indexPath in
                guard let self = self else { return }
                if self.companyHolidays.indices.contains(indexPath.row) {
                    self.companyHolidays.remove(at: indexPath.row)
                }
                if self.companyHolidayRows.indices.contains(indexPath.row) {
                    self.companyHolidayRows.remove(at: indexPath.row)
                }
            }
            .store(in: &cancellables)

        removeDetails
            .sink { [weak self] indexPath in
                guard let self = self,
                      self.details.indices.contains(indexPath.row) else { return }
                self.details.remove(at: indexPath.row)
            }
            .store(in: &cancellables)
        
        setDetails
            .sink { [weak self] newRows in
                self?.details = newRows
            }
            .store(in: &cancellables)

        setHolidays
            .sink { [weak self] rows in
                guard let self = self else { return }
                self.companyHolidayRows = rows
                self.companyHolidays   = rows.map { $0.date }
                self.sortHolidaysInPlace()
            }
            .store(in: &cancellables)

        confirmTapped
            .sink { [weak self] in
                guard let self = self else { return }

                let hireDate = self.setHireDate.value
                let referenceDate = self.setReferenceDate.value

                // 1) 입사일 ≤ 기준일
                guard self.isHireBeforeOrEqual(hireDate, referenceDate) else {
                    self.error.send(MainValidationError.hireAfterReference)
                    return
                }
                
                // 1-b) 기준일이 2017-05-30 '이후'인지
                guard self.isReferenceAfterBaseline(referenceDate) else {
                    self.error.send(MainValidationError.referenceOutOfRange)
                    return
                }

                // 2) 특이사항 전체가 기간 내에 있는지
                let invalidDetailsCount = self.details.filter {
                    !self.isPeriodInRange(
                        start: $0.start,
                        end: $0.end,
                        hireDate: hireDate,
                        referenceDate: referenceDate
                    )
                }.count
                
                guard invalidDetailsCount == 0 else {
                    self.error.send(MainValidationError.detailsOutOfRange)
                    return
                }

                // 3) 회사 휴일 전체가 기간 내에 있는지
                let invalidHolidaysCount = self.companyHolidayRows.filter {
                    !self.isDateInRange(
                        $0.date,
                        hireDate: hireDate,
                        referenceDate: referenceDate
                    )
                }.count
                
                guard invalidHolidaysCount == 0 else {
                    self.error.send(MainValidationError.holidaysOutOfRange)
                    return
                }

                // ✅ 모두 통과 → 요청
                let request = self.makeRequest()
                self.lastBuiltRequest = request
                self.requestCalculate(with: request)
            }
            .store(in: &cancellables)
    }

    // MARK: - Range helpers
    private func isHireBeforeOrEqual(_ hireDate: Date, _ referenceDate: Date) -> Bool {
        let startOfDayHireDate = calendar.startOfDay(for: hireDate)
        let startOfDayReferenceDate = calendar.startOfDay(for: referenceDate)
        return startOfDayHireDate <= startOfDayReferenceDate
    }

    private func isDateInRange(_ date: Date, hireDate: Date, referenceDate: Date) -> Bool {
        let startOfDayDate = calendar.startOfDay(for: date)
        let startOfDayHireDate = calendar.startOfDay(for: hireDate)
        let startOfDayReferenceDate = calendar.startOfDay(for: referenceDate)
        return startOfDayDate >= startOfDayHireDate && startOfDayDate <= startOfDayReferenceDate
    }
    
    private func isReferenceAfterBaseline(_ referenceDate: Date) -> Bool {
        let startOfDayReferenceDate = calendar.startOfDay(for: referenceDate)
        let startOfDayBaselineDate = calendar.startOfDay(for: MainViewModel.referenceBaselineDate)
        return startOfDayReferenceDate > startOfDayBaselineDate
    }
    
    private func isPeriodInRange(
        start startDate: Date,
        end endDate: Date,
        hireDate: Date,
        referenceDate: Date
    ) -> Bool {
        let startOfDayStartDate = calendar.startOfDay(for: startDate)
        let startOfDayEndDate = calendar.startOfDay(for: endDate)
        let startOfDayHireDate = calendar.startOfDay(for: hireDate)
        let startOfDayReferenceDate = calendar.startOfDay(for: referenceDate)
        // 전체 기간이 경계 안에 “완전히” 들어와야 함
        return startOfDayStartDate >= startOfDayHireDate && startOfDayEndDate <= startOfDayReferenceDate
    }

    // MARK: - Build Request
    private func makeRequest() -> CalculationRequest {
        let calculationType = setCalculationType.value
        let hireDate = setHireDate.value
        let referenceDate = setReferenceDate.value
        let fiscalYearDate = setFiscalYearDate.value

        let formatterYYYYMMDD = Self.dateFormatter("yyyy-MM-dd")
        let formatterMMDD = Self.dateFormatter("MM-dd")

        let nonWorkingPeriods: [NonWorkingPeriodDTO] = details.compactMap { row in
            guard let typeInt = NonWorkingType.from(title: row.reason)?.serverCode else {
                return nil
            }
            return NonWorkingPeriodDTO(
                type: typeInt,
                startDate: formatterYYYYMMDD.string(from: row.start),
                endDate: formatterYYYYMMDD.string(from: row.end)
            )
        }

        let holidays: [String] = companyHolidayRows
            .sorted { $0.date < $1.date }
            .map { formatterYYYYMMDD.string(from: $0.date) }

        let fiscalYearString = fiscalYearDate.map { formatterMMDD.string(from: $0) }

        return CalculationRequest(
            calculationType: calculationType,
            fiscalYear: fiscalYearString,
            hireDate: formatterYYYYMMDD.string(from: hireDate),
            referenceDate: formatterYYYYMMDD.string(from: referenceDate),
            nonWorkingPeriods: nonWorkingPeriods,
            companyHolidays: holidays
        )
    }

    func durationText(for item: DetailRow) -> String {
        let formatter = Self.dateFormatter("yyyy-MM-dd")
        let startString = formatter.string(from: item.start)
        let endString = formatter.string(from: item.end)
        let dayCount = Calendar.korea.dateComponents([.day], from: item.start, to: item.end).day ?? 0
        return "\(startString) ~ \(endString) • \(dayCount + 1)일"
    }

    // “YYYY-MM-DD” 한 줄 출력용
    func holidayDisplayText(for row: CompanyHolidayRow) -> String {
        let formatter = Self.dateFormatter("yyyy-MM-dd")
        return "\(formatter.string(from: row.date)) • \(row.reason)"
    }

    private static func dateFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = .korea
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .korea
        formatter.dateFormat = format
        return formatter
    }

    private func requestCalculate(with request: CalculationRequest) {
        guard let hireDateString = request.hireDate,
              let referenceDateString = request.referenceDate else {
            self.error.send(NSError(domain: "MainVM", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "입사일/기준일이 비어 있습니다."]))
            return
        }

        let mappedNonWorking: [NonWorkingPeriod]? = request.nonWorkingPeriods.map {
            NonWorkingPeriod(type: $0.type, startDate: $0.startDate, endDate: $0.endDate)
        }

        isLoading = true
        lastResult = nil

        Task { [weak self] in
            guard let self = self else { return }
            do {
                let result = try await calculatorUseCase.calculate(
                    calculationType: request.calculationType,
                    fiscalYear: request.fiscalYear,
                    hireDate: hireDateString,
                    referenceDate: referenceDateString,
                    nonWorkingPeriods: mappedNonWorking,
                    companyHolidays: request.companyHolidays
                )
                await MainActor.run {
                    self.lastResult = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.error.send(error)
                }
            }
        }
    }

    private func sortHolidaysInPlace() {
        companyHolidays.sort()
        companyHolidayRows.sort { $0.date < $1.date }
    }
}
