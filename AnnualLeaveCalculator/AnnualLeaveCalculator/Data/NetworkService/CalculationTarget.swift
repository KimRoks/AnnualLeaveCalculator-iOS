//
//  CalculationTarget.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 12/25/25.
//

import Foundation

enum CalculationTarget {
    case calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]?,
        companyHolidays: [String]?
    )
}

extension CalculationTarget: TargetType {
    var basePath: String? {
        switch self {
        case .calculate:
            return "/annual-leaves"
        }
    }
    
    var method: HTTPMethods {
        .post
    }
    
    var path: String {
        return "/calculate"
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Platform": "ios",
            "X-Test": xTestFlag
        ]
    }
    
    var parameters: [String : Any]? {
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
