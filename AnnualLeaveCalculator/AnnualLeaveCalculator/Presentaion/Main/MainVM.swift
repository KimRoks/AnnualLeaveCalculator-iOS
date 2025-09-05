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

// Detail 화면에서 사용하는 모델이 이미 있음
// 여기서는 reason(String)만 넘어와도 매핑 가능하도록 처리
// NonWorkingType.from(title:) 을 사용
// (프로젝트에 이미 추가되어 있다고 전제)
final class MainViewModel {

    // MARK: - Inputs
    let addHoliday = PassthroughSubject<Date, Never>()
    let removeHoliday = PassthroughSubject<IndexPath, Never>()
    /// Detail 화면에서 넘어온 전체 rows를 세팅
    let setDetails = PassthroughSubject<[DetailRow], Never>()

    /// UI에서 바뀌는 기본 입력들
    let setCalculationType = CurrentValueSubject<Int, Never>(1)  // 1: 입사일, 2: 회계연도(가정)
    let setHireDate = CurrentValueSubject<Date, Never>(Date())
    let setReferenceDate = CurrentValueSubject<Date, Never>(Date())
    /// 회계연도 시작일 → "MM-dd" 로 보낼 예정이라 Date로 받고 포맷에서 MM-dd 사용
    let setFiscalYearDate = CurrentValueSubject<Date?, Never>(nil)

    // MARK: - Outputs (상태)
    @Published private(set) var companyHolidays: [Date] = []
    @Published private(set) var details: [DetailRow] = []

    // 요청 트리거 & 결과
    let buildRequest = PassthroughSubject<Void, Never>()
    @Published private(set) var lastBuiltRequest: CalculationRequest?

    private var cancellables = Set<AnyCancellable>()

    init() {
        bind()
    }

    private func bind() {
        // 휴일 추가(중복 방지: 하루 단위)
        addHoliday
            .sink { [weak self] date in
                guard let self = self else { return }
                let cal = Calendar.korea
                if self.companyHolidays.contains(where: { cal.startOfDay(for: $0) == cal.startOfDay(for: date) }) == false {
                    self.companyHolidays.append(date)
                }
            }
            .store(in: &cancellables)

        // 휴일 삭제
        removeHoliday
            .sink { [weak self] indexPath in
                self?.companyHolidays.remove(at: indexPath.row)
            }
            .store(in: &cancellables)

        // 디테일 세팅
        setDetails
            .sink { [weak self] newRows in
                self?.details = newRows
            }
            .store(in: &cancellables)

        // 요청 빌드 트리거
        buildRequest
            .sink { [weak self] in
                guard let self = self else { return }
                self.lastBuiltRequest = self.makeRequest()
            }
            .store(in: &cancellables)
    }

    // MARK: - Build Request

    /// 현재 보유 상태로 CalculationRequest 생성
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
            // reason → type(int)
            let typeInt: Int
            if let t = NonWorkingType.from(title: row.reason)?.rawValue {
                typeInt = t
            } else {
                // 매칭 실패 시 서버 규격상 타입이 필수이므로, 안전하게 제외(혹은 기본값 할당)
                // 여기서는 제외
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
}
