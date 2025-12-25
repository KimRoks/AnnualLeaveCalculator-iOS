//
//  AnnualLeaveRepositoryImpl.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/23/25.
//

import Foundation

struct AnnualLeaveRepositoryImpl: AnnualLeaveRepository {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]? = [],
        companyHolidays: [String]? = []
    ) async throws -> CalculationResultDTO {
        guard let request = try? CalculationTarget.calculate(
            calculationType: calculationType,
            fiscalYear: fiscalYear,
            hireDate: hireDate,
            referenceDate: referenceDate,
            nonWorkingPeriods: nonWorkingPeriods,
            companyHolidays: companyHolidays
        ).asURLRequest() else {
            throw NetworkError.invalidURLError
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.requestFailed
        }

        do {
            let decoded = try JSONDecoder().decode(CalculationResultDTO.self, from: data)
                        
            return decoded
        } catch {
            print(NetworkError.decodingFailed.errorDescription ?? "디코딩 실패")
            throw NetworkError.decodingFailed
        }
    }
    
    func sendFeedback(
        type: FeedbackType,
        content: String,
        email: String?,
        rating: Int?,
        calculationId: String?
    ) async throws {
        guard let request = try? LawdingServiceTarget.submitFeedback(
            type: type.apiString,
            content: content,
            email: email,
            rating: rating,
            calculationId: calculationId
        ).asURLRequest() else {
            throw NetworkError.invalidURLError
        }

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.requestFailed
        }
    }
    
    func sendRating(
        type: FeedbackType,
        content: String?,
        email: String?,
        rating: Int,
        calculationId: String?
    ) async throws {
        guard let request = try? LawdingServiceTarget.submitRating(
            type: type.apiString,
            content: content,
            email: email,
            rating: rating,
            calculationId: calculationId
        ).asURLRequest() else {
            throw NetworkError.invalidURLError
        }
        
        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.requestFailed
        }
    }
}
