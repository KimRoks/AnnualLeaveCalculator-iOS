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

public enum FeedbackType: Codable {
    case errorReport
    case improvement
    case question
    case satisfaction
    case other
    
    var apiString: String {
        switch self {
        case .errorReport:  return "ERROR_REPORT"
        case .improvement:  return "IMPROVEMENT"
        case .question:     return "QUESTION"
        case .satisfaction: return "SATISFACTION"
        case .other:        return "OTHER"
        }
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
    
    func submitFeedback(
        type: FeedbackType,
        content: String,
        email: String?,
        rating: Int?,
        calculationId: String?
    ) async throws
    
    func submitRating(
        type: FeedbackType,
        content: String?,
        email: String?,
        rating: Int,
        calculationId: String?
    ) async throws
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
    
    func submitFeedback(
        type: FeedbackType,
        content: String,
        email: String?,
        rating: Int?,
        calculationId: String?
    ) async throws {
        do {
            try await annualLeaveRepository.sendFeedback(
                type: type,
                content: content,
                email: email,
                rating: nil,
                calculationId: calculationId
            )
        } catch {
            throw error
        }
    }
    
    func submitRating(
        type: FeedbackType,
        content: String?,
        email: String?,
        rating: Int,
        calculationId: String?
    ) async throws {
        do {
            try await annualLeaveRepository.sendRating(
                type: type,
                content: content,
                email: email,
                rating: rating,
                calculationId: calculationId
            )
        } catch {
            throw error
        }
    }
}
