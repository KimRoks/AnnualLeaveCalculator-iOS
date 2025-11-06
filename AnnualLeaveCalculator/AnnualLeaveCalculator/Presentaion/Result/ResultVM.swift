//
//  ResultVM.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/7/25.
//

import Foundation

public final class ResultViewModel {
    
    // MARK: - Domain-ish enums (UI 텍스트 아님)
    public enum CalculationType {
        case hireDate
        case fiscalYear
        case unknown(String)
        
        init(raw: String) {
            switch raw {
            case "HIRE_DATE":   self = .hireDate
            case "FISCAL_YEAR": self = .fiscalYear
            default:            self = .unknown(raw)
            }
        }
    }
    
    public enum LeaveKind {
        case monthly
        case annual
        case prorated
        case monthlyAndProrated
        case unknown(String)
        
        init(raw: String) {
            switch raw {
            case "MONTHLY":                self = .monthly
            case "ANNUAL":                 self = .annual
            case "PRORATED":               self = .prorated
            case "MONTHLY_AND_PRORATED":   self = .monthlyAndProrated
            default:                       self = .unknown(raw)
            }
        }
    }
    
    // MARK: - Raw backing (필요 시 전체 DTO 접근)
    public let dto: CalculationResultDTO
    
    // MARK: - Top-level
    public let calculationType: CalculationType
    public let fiscalYear: String?          // "MM-dd"
    public let hireDate: String             // "yyyy-MM-dd"
    public let referenceDate: String        // "yyyy-MM-dd"
    public let leaveType: LeaveKind
    
    // MARK: - Detail (Top-level calculationDetail)
    public let accrualPeriod: CalculationResultDTO.Period?
    public let availablePeriod: CalculationResultDTO.Period?
    public let attendanceRate: Double?
    public let prescribedWorkingRatio: Double?
    public let serviceYears: Int
    public let totalLeaveDays: Double
    public let baseAnnualLeave: Int?
    public let additionalLeave: Int?
    
    /// 상단 records(월별 내역) – 없으면 []
    public let records: [CalculationResultDTO.Record]
    
    /// 서브 디테일 (있을 수도, 없을 수도)
    public let monthlyDetail: CalculationResultDTO.MonthlyDetail?
    public let proratedDetail: CalculationResultDTO.ProratedDetail?
    
    // MARK: - Etc
    public let nonWorkingPeriods: [CalculationResultDTO.NonWorkingPeriod]
    public let companyHolidays: [String]
    public let explanations: [String]
    public let nonWorkingExplanations: [String]
    
    // MARK: - Flags (VC에서 섹션 노출 분기용)
    public var hasRecords: Bool { !records.isEmpty }
    public var hasMonthlyDetail: Bool { monthlyDetail != nil }
    public var hasProratedDetail: Bool { proratedDetail != nil }
    
    // 필요시: “주요” 기간(예: summary 상단)에 무엇을 쓸지 선택 로직도 제공 가능하지만,
    // 포맷/정책은 VC에서 결정한다는 원칙에 맞춰 여기선 노출만 한다.
    
    // MARK: - Init
    public init(dto: CalculationResultDTO) {
        self.dto = dto
        
        // enums 정규화 (서버가 새로운 값 추가해도 unknown으로 보존)
        self.calculationType = CalculationType(raw: dto.calculationType)
        self.leaveType = LeaveKind(raw: dto.leaveType.rawValue)
        
        // 기본 필드
        self.fiscalYear = dto.fiscalYear
        self.hireDate = dto.hireDate
        self.referenceDate = dto.referenceDate
        
        // Detail
        let detail = dto.calculationDetail
        self.accrualPeriod = detail.accrualPeriod
        self.availablePeriod = detail.availablePeriod
        self.attendanceRate = detail.attendanceRate?.rate
        self.prescribedWorkingRatio = detail.prescribedWorkingRatio?.rate
        self.serviceYears = detail.serviceYears
        self.totalLeaveDays = detail.totalLeaveDays
        self.baseAnnualLeave = detail.baseAnnualLeave
        self.additionalLeave = detail.additionalLeave
        
        // Optional → 안전 기본값
        self.records = detail.records ?? []
        self.monthlyDetail = detail.monthlyDetail
        self.proratedDetail = detail.proratedDetail
        
        self.nonWorkingPeriods = dto.nonWorkingPeriod ?? []
        self.companyHolidays = dto.companyHolidays ?? []
        self.explanations = dto.explanations
        self.nonWorkingExplanations = dto.nonWorkingExplanations ?? []
    }
}

