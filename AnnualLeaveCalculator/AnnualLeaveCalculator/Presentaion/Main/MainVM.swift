//
//  MainVM.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/29/25.
//

import Foundation
import Combine

// 서버 요청 DTO
struct CalculationRequest: Encodable {
    let calculationType: Int
    let fiscalYear: String?          // "MM-dd"
    let hireDate: String?           // "yyyy-MM-dd"
    let referenceDate: String?        // "yyyy-MM-dd"
    let nonWorkingPeriods: [NonWorkingPeriodDTO]
    let companyHolidays: [String]    // "yyyy-MM-dd"
}

struct NonWorkingPeriodDTO: Encodable {
    let type: Int
    let startDate: String            // "yyyy-MM-dd"
    let endDate: String              // "yyyy-MM-dd"
}

final class MainViewModel {
    
    // MARK: - Inputs
    let addHoliday = PassthroughSubject<Date, Never>()
    let removeHoliday = PassthroughSubject<IndexPath, Never>()
    let setDetails = PassthroughSubject<[DetailRow], Never>()
    let confirmTapped = PassthroughSubject<Void, Never>()
    
    /// UI에서 바뀌는 기본 입력들
    let setCalculationType = CurrentValueSubject<Int, Never>(1)  // 1: 입사일, 2: 회계연도
    let setHireDate = CurrentValueSubject<Date, Never>(Date())
    let setReferenceDate = CurrentValueSubject<Date, Never>(Date())
    /// 회계연도 시작일 → "MM-dd" 로 보낼 예정이라 Date로 받고 포맷에서 MM-dd 사용
    let setFiscalYearDate = CurrentValueSubject<Date?, Never>(nil)
    
    // MARK: - Outputs (상태)
    @Published private(set) var companyHolidays: [Date] = []
    @Published private(set) var details: [DetailRow] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastResult: CalculationResultDTO?
    let error = PassthroughSubject<Error, Never>()
    
    // 요청 트리거 & 결과
    @Published private(set) var lastBuiltRequest: CalculationRequest?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let calculatorUseCase: AnnualLeaveCalculatorUseCase
    
    // MARK: Init
    
    init(calculatorUseCase: AnnualLeaveCalculatorUseCase) {
        self.calculatorUseCase = calculatorUseCase
        bind()
    }
    
    private func bind() {
        addHoliday
            .sink { [weak self] date in
                guard let self = self else { return }
                let cal = Calendar.korea
                if self.companyHolidays.contains(where: { cal.startOfDay(for: $0) == cal.startOfDay(for: date) }) == false {
                    self.companyHolidays.append(date)
                }
            }
            .store(in: &cancellables)
        
        removeHoliday
            .sink { [weak self] indexPath in
                self?.companyHolidays.remove(at: indexPath.row)
            }
            .store(in: &cancellables)
        
        setDetails
            .sink { [weak self] newRows in
                self?.details = newRows
            }
            .store(in: &cancellables)
        
        confirmTapped
            .sink { [weak self] in
                guard let self = self else { return }
                let req = self.makeRequest()
                self.lastBuiltRequest = req
                self.requestCalculate(with: req)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Build Request
    
    private func makeRequest() -> CalculationRequest {
        let calculationType = setCalculationType.value
        
        let hireDate = setHireDate.value
        let referenceDate = setReferenceDate.value
        let fiscalDate = setFiscalYearDate.value
        
        // 포맷터
        let ymd = Self.dateFormatter("yyyy-MM-dd")
        let md = Self.dateFormatter("MM-dd")
        
        // nonWorkingPeriods 매핑
        let nonWorking: [NonWorkingPeriodDTO] = details.compactMap { row in
            let typeInt: Int
            if let t = NonWorkingType.from(title: row.reason)?.rawValue {
                typeInt = t
            } else {
                return nil
            }
            return NonWorkingPeriodDTO(
                type: typeInt,
                startDate: ymd.string(from: row.start),
                endDate: ymd.string(from: row.end)
            )
        }
        
        // companyHolidays 문자열 배열
        let holidays = companyHolidays
            .sorted()
            .map { ymd.string(from: $0) }
        
        // fiscalYear는 선택 사항
        let fiscalYearString = fiscalDate.map { md.string(from: $0) }
        
        return CalculationRequest(
            calculationType: calculationType,
            fiscalYear: fiscalYearString,
            hireDate: ymd.string(from: hireDate),
            referenceDate: ymd.string(from: referenceDate),
            nonWorkingPeriods: nonWorking,
            companyHolidays: holidays
        )
    }
    
    // 루트 화면의 디테일 테이블에서 쓰는 포맷
    func durationText(for item: DetailRow) -> String {
        let df = Self.dateFormatter("yyyy-MM-dd")
        let startStr = df.string(from: item.start)
        let endStr = df.string(from: item.end)
        let days = Calendar.korea.dateComponents([.day], from: item.start, to: item.end).day ?? 0
        return "\(startStr) ~ \(endStr) • \(days + 1)일"
    }
    
    // MARK: - Helpers
    
    private static func dateFormatter(_ format: String) -> DateFormatter {
        let df = DateFormatter()
        df.calendar = .korea
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = .korea
        df.dateFormat = format
        return df
    }
    
    private func requestCalculate(with request: CalculationRequest) {
        // 필수 문자열 체크 (hire/reference는 nil이 아니게 생성되지만, 방어적으로 확인)
        guard let hire = request.hireDate, let ref = request.referenceDate else {
            self.error.send(NSError(domain: "MainVM", code: -1, userInfo: [NSLocalizedDescriptionKey: "입사일/기준일이 비어 있습니다."]))
            return
        }
        
        // DTO -> 서버 UseCase 파라미터로 변환
        let mappedNonWorking: [NonWorkingPeriod]? = request.nonWorkingPeriods.map {
            NonWorkingPeriod(
                type: $0.type,
                startDate: $0.startDate,
                endDate: $0.endDate
            )
        }
        
        isLoading = true
        lastResult = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await calculatorUseCase.calculate(
                    calculationType: request.calculationType,
                    fiscalYear: request.fiscalYear,
                    hireDate: hire,
                    referenceDate: ref,
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
}
