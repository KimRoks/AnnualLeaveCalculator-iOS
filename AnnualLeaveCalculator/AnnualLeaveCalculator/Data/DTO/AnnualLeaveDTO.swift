//
//  AnnualLeaveDTO.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/23/25.
//

import Foundation

public struct CalculationResultDTO: Decodable {
    public let calculationId: String
    public let calculationType: String
    public let fiscalYear: String?
    public let hireDate: String
    public let referenceDate: String
    public let nonWorkingPeriod: [NonWorkingPeriod]?
    public let companyHolidays: [String]?
    public let leaveType: LeaveType
    public let calculationDetail: CalculationDetail
    public let explanations: [String]
    public let nonWorkingExplanations: [String]?
    
    public enum CodingKeys: String, CodingKey {
        case calculationId
        case calculationType
        case fiscalYear
        case hireDate
        case referenceDate
        case nonWorkingPeriod
        case companyHolidays
        case leaveType
        case calculationDetail
        case explanations
        case nonWorkingExplanations
    }
    
    public enum LeaveType: String, Decodable {
        case monthly = "MONTHLY"
        case annual = "ANNUAL"
        case prorated = "PRORATED"
        case monthlyAndProrated = "MONTHLY_AND_PRORATED"
    }
    
    public struct NonWorkingPeriod: Decodable {
        public let type: Int
        public let startDate: String
        public let endDate: String
        
        public enum CodingKeys: String, CodingKey {
            case type
            case startDate
            case endDate
        }
    }
    
    public struct CalculationDetail: Decodable {
        public let accrualPeriod: Period?
        public let availablePeriod: Period?
        public let attendanceRate: Double?
        public let prescribedWorkingRatio: Double?
        
        public let serviceYears: Int
        public let totalLeaveDays: Double
        
        public let baseAnnualLeave: Int?
        public let additionalLeave: Int?
        
        public let records: [Record]?
        
        public let monthlyDetail: MonthlyDetail?
        public let proratedDetail: ProratedDetail?
        public let prescribedWorkingRatioForProrated: Double?

        public enum CodingKeys: String, CodingKey {
            case accrualPeriod
            case availablePeriod
            case attendanceRate
            case prescribedWorkingRatio
            case serviceYears
            case totalLeaveDays
            case baseAnnualLeave
            case additionalLeave
            case records
            case monthlyDetail
            case proratedDetail
            case prescribedWorkingRatioForProrated
        }
    }
    
    public struct MonthlyDetail: Decodable {
        public let accrualPeriod: Period
        public let availablePeriod: Period
        public let totalLeaveDays: Double
        public let records: [Record]
        
        public enum CodingKeys: String, CodingKey {
            case accrualPeriod
            case availablePeriod
            case totalLeaveDays
            case records
        }
    }
    
    public struct ProratedDetail: Decodable {
        public let accrualPeriod: Period
        public let availablePeriod: Period
        public let attendanceRate: Double?
        public let prescribedWorkingRatio: Double?
        public let totalLeaveDays: Double
        
        public enum CodingKeys: String, CodingKey {
            case accrualPeriod
            case availablePeriod
            case attendanceRate
            case prescribedWorkingRatio
            case totalLeaveDays
        }
    }
    
    public struct Period: Decodable {
        public let startDate: String
        public let endDate: String
        
        public enum CodingKeys: String, CodingKey {
            case startDate
            case endDate
        }
    }
    
    public struct Record: Decodable {
        public let period: Period
        public let monthlyLeave: Double
        
        public enum CodingKeys: String, CodingKey {
            case period
            case monthlyLeave
        }
    }
}
