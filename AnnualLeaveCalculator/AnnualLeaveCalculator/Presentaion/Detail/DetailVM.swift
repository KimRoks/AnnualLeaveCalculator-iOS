//
//  DetailVM.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/31/25.
//

import Foundation
import Combine

struct DetailRow: Equatable {
    let reason: String
    let start: Date
    let end: Date
}

enum DetailError: LocalizedError {
    case limitReached
    case invalidRange
    case overlap

    var errorDescription: String? {
        switch self {
        case .limitReached:  return "항목은 최대 3개까지 추가할 수 있습니다."
        case .invalidRange:  return "종료일은 시작일보다 앞설 수 없습니다."
        case .overlap:       return "기간이 기존 항목과 겹칩니다."
        }
    }
}

final class DetailViewModel {

    // Inputs
    let add = PassthroughSubject<DetailRow, Never>()
    let remove = PassthroughSubject<IndexPath, Never>()

    // Outputs
    @Published private(set) var rows: [DetailRow]
    let error = PassthroughSubject<DetailError, Never>()
    let didAdd = PassthroughSubject<Void, Never>()

    private var cancellables = Set<AnyCancellable>()

    /// ✅ Main에서 기존 rows를 넣어 재진입 시 상태 복원
    init(initialRows: [DetailRow] = []) {
        self.rows = initialRows
        bind()
    }

    private func bind() {
        add
            .sink { [weak self] item in
                guard let self else { return }

                let (normalizedStart, normalizedEnd) = self.normalizedRange(start: item.start, end: item.end)

                if normalizedEnd < normalizedStart {
                    self.error.send(.invalidRange); return
                }
                guard self.rows.count < 3 else {
                    self.error.send(.limitReached); return
                }
                if self.hasAnyOverlap(withStart: normalizedStart, end: normalizedEnd) {
                    self.error.send(.overlap); return
                }

                self.rows.append(.init(reason: item.reason, start: normalizedStart, end: normalizedEnd))
                self.didAdd.send(())
            }
            .store(in: &cancellables)

        remove
            .sink { [weak self] indexPath in
                guard let self, rows.indices.contains(indexPath.row) else { return }
                self.rows.remove(at: indexPath.row)
            }
            .store(in: &cancellables)
    }

    func durationText(for item: DetailRow) -> String {
        let df = DateFormatter()
        df.calendar = .korea
        df.locale = .init(identifier: "ko_KR")
        df.timeZone = .korea
        df.dateFormat = "yyyy-MM-dd"

        let startStr = df.string(from: item.start)
        let endStr = df.string(from: item.end)
        let days = Calendar.korea.dateComponents([.day], from: item.start, to: item.end).day ?? 0
        let inclusive = days + 1
        return "\(startStr) ~ \(endStr) • \(inclusive)일"
    }

    private func normalizedRange(start: Date, end: Date) -> (Date, Date) {
        let cal = Calendar.korea
        return (cal.startOfDay(for: start), cal.startOfDay(for: end))
    }

    private func hasAnyOverlap(withStart newStart: Date, end newEnd: Date) -> Bool {
        let cal = Calendar.korea
        for existing in rows {
            let es = cal.startOfDay(for: existing.start)
            let ee = cal.startOfDay(for: existing.end)
            if newStart <= ee && newEnd >= es { return true }
        }
        return false
    }
}
