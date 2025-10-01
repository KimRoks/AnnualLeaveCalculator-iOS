//
//  AnnualLeaveTarget.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import Foundation

enum AnnualLeaveTarget {
    case calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]?,
        companyHolidays: [String]?
    )
}

extension AnnualLeaveTarget: TargetType {
    var method: HTTPMethods {
        switch self {
        case .calculate:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .calculate:
            return "/calculate"
        }
    }
    
    private var xTestFlag: String {
        #if DEBUG
            return "true"
        #else
            return "false"
        #endif
    }
    
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Platform": "ios",
            "X-Test": xTestFlag
        ]
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .calculate(
            let calculationType,
            let fiscalYear,
            let hireDate,
            let referenceDate,
            let nonWorkingPeriods,
            let companyHolidays
        ):
            var dict: [String: Any] = [
                "calculationType": calculationType,
                "hireDate": hireDate,
                "referenceDate": referenceDate
            ]
            if let fiscalYear = fiscalYear {
                dict["fiscalYear"] = fiscalYear
            }
            if let nonWorkingPeriods = nonWorkingPeriods {
                dict["nonWorkingPeriods"] = nonWorkingPeriods.map { $0.asDictionary }
            }
            if let companyHolidays = companyHolidays {
                dict["companyHolidays"] = companyHolidays
            }
            return dict
        }
    }
}
