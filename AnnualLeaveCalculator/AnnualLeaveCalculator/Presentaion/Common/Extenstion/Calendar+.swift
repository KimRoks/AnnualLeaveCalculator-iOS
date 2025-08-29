//
//  Calendar+.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/27/25.
//

import Foundation

extension Calendar {
    static var korea: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }
}

extension DateFormatter {
    static func korea(format: String) -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = format
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return df
    }
}

extension Date {
    func toKoreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.korea
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")!
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
