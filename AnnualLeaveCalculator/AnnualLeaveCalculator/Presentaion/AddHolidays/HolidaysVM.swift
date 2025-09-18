//
//  HolidaysVM.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/14/25.
//

import Foundation
import Combine

// MARK: - Errors
enum HolidayError: LocalizedError {
    case limitReached
    case duplicateDate

    var errorDescription: String? {
        switch self {
        case .limitReached:   return "휴일은 최대 3개까지 추가할 수 있습니다."
        case .duplicateDate:  return "이미 추가된 날짜와 겹칩니다."
        }
    }
}

// MARK: - Model
struct HolidayItem: Equatable {
    let reason: String
    let date: Date
}

// MARK: - ViewModel
/// 하루짜리 공휴일 외 회사휴일을 관리
/// - 추가/삭제 가능
/// - 최대 3개
/// - 같은 '날짜' 중복 불가(사유는 중복 허용)
final class HolidaysViewModel {

    // MARK: Inputs
    /// (reason, date) 한 번에 추가
    let add = PassthroughSubject<HolidayItem, Never>()
    let remove = PassthroughSubject<IndexPath, Never>()

    // MARK: Outputs
    @Published private(set) var rows: [HolidayItem]
    /// 기존 상위 화면 호환용: 날짜 배열만 필요할 때 사용
    var dates: [Date] { rows.map(\.date) }

    let error = PassthroughSubject<HolidayError, Never>()
    let didAdd = PassthroughSubject<Void, Never>()

    // MARK: Private
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init
    init(initialRows: [HolidayItem] = []) {
        // 내부적으로 날짜는 모두 startOfDay로 정규화
        let calendar = Calendar.korea
        let normalized = initialRows.map { HolidayItem(reason: $0.reason, date: calendar.startOfDay(for: $0.date)) }
        // 날짜 기준으로 유니크, 최대 3개
        self.rows = normalized.uniqued(by: { $0.date }).prefix(3).map { $0 }
        bind()
    }

    // MARK: Bind
    private func bind() {
        add
            .sink { [weak self] item in
                guard let self else { return }
                let day = Calendar.korea.startOfDay(for: item.date)

                guard self.rows.count < 3 else {
                    self.error.send(.limitReached); return
                }
                guard self.contains(day) == false else {
                    self.error.send(.duplicateDate); return
                }

                self.rows.append(.init(reason: item.reason, date: day))
                self.rows.sort { $0.date < $1.date }
                self.didAdd.send(())
            }
            .store(in: &cancellables)

        remove
            .sink { [weak self] indexPath in
                guard let self, self.rows.indices.contains(indexPath.row) else { return }
                self.rows.remove(at: indexPath.row)
            }
            .store(in: &cancellables)
    }

    // MARK: Helpers
    /// 같은 날 포함 여부
    private func contains(_ date: Date) -> Bool {
        let cal = Calendar.korea
        return rows.contains(where: { cal.isDate($0.date, inSameDayAs: date) })
    }

    /// 셀 표시용: "yyyy-MM-dd"
    func dateText(for date: Date, format: String = "yyyy-MM-dd") -> String {
        let df = DateFormatter()
        df.calendar = .korea
        df.locale = .init(identifier: "ko_KR")
        df.timeZone = .korea
        df.dateFormat = format
        return df.string(from: date)
    }
}

// MARK: - Utilities
extension Array {
    /// keyPath/클로저로 유니크(순서 유지)
    fileprivate func uniqued<T: Hashable>(by key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        var result: [Element] = []
        for e in self {
            let k = key(e)
            if seen.insert(k).inserted { result.append(e) }
        }
        return result
    }
}
