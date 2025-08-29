//
//  AnnualLeaveRepository.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/23/25.
//

import Foundation

public protocol AnnualLeaveRepository {
    func calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]?,
        companyHolidays: [String]?
    ) async throws -> AnnualLeaveDTO
}
