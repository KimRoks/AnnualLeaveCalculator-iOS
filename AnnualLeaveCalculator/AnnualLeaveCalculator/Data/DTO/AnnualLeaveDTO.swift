//
//  AnnualLeaveDTO.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/23/25.
//

import Foundation

public struct AnnualLeaveDTO: Decodable {
    let calculationType: String
        let annualLeaveResultType: String
        let fiscalYear: String
        let hireDate: String
        let referenceDate: String
        let calculationDetail: CalculationDetail
        let explanation: String

        struct CalculationDetail: Decodable {
            let monthlyLeaveAccrualPeriod: AccrualPeriod
            let monthlyLeaveDays: Double
            let proratedLeaveAccrualPeriod: AccrualPeriod
            let proratedLeaveDays: Double
            let totalLeaveDays: Double

            struct AccrualPeriod: Decodable {
                let startDate: String
                let endDate: String
            }
        }
}
