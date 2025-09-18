//
//  AnnualLeaveCalculatorUseCase.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/23/25.
//

import Foundation

public struct NonWorkingPeriod {
    let type: Int
    let startDate: String
    let endDate: String
    
    var asDictionary: [String: Any] {
        [
            "type": type,
            "startDate": startDate,
            "endDate": endDate
        ]
    }
}

public protocol AnnualLeaveCalculatorUseCase {
    func calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]?,
        companyHolidays: [String]?
    ) async throws -> CalculationResultDTO
}

final class DefaultAnnualLeaveCalculatorUseCase: AnnualLeaveCalculatorUseCase {
    private let annualLeaveRepository: AnnualLeaveRepository
    
    init(annualLeaveRepository: AnnualLeaveRepository) {
        self.annualLeaveRepository = annualLeaveRepository
    }
    
    func calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]?,
        companyHolidays: [String]?
    ) async throws -> CalculationResultDTO {
        do {
            return try await annualLeaveRepository.calculate(
                calculationType: calculationType,
                fiscalYear: fiscalYear,
                hireDate: hireDate,
                referenceDate: referenceDate,
                nonWorkingPeriods: nonWorkingPeriods,
                companyHolidays: companyHolidays
            )
        } catch {
            throw error
        }
    }
}
