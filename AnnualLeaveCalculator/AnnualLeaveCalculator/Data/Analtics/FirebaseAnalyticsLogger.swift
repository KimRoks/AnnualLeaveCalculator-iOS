//
//  FirebaseAnalyticsLogger.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/31/25.
//

import Foundation

import FirebaseAnalytics

final class FirebaseAnalyticsLogger: AnalyticsLogging {
    func log(_ event: AppEvent) {
        switch event {
        case .tapCalculate:
            Analytics.logEvent(
                "tap_calculate",
                parameters: nil
            )
        case .calculateFailed(error: let error):
            let info = FirebaseAnalyticsLogger.errorInfo(from: error)
            Analytics.logEvent(
                "calculate_Failed",
                parameters: [
                    "error_domain": info.domain,
                    "error_code": NSNumber(value: info.code),
                    "error_type": info.type,
                    "error_desc": info.descriptionShort
                ]
            )
        case .calculateSucceeded:
            Analytics.logEvent(
                "calculate_Succeeded",
                parameters: nil
            )
            
        case .tapSubmitFeedback:
            Analytics.logEvent(
                "tap_submit_feedback",
                parameters: nil
            )
        case .feedbackSucceeded:
            Analytics.logEvent(
                "feedback_Succeeded",
                parameters: nil
            )
        case .feedbackFailed(error: let error):
            let info = FirebaseAnalyticsLogger.errorInfo(from: error)
            Analytics.logEvent(
                "feedback_Failed",
                parameters: [
                    "error_domain": info.domain,
                    "error_code": NSNumber(value: info.code),
                    "error_type": info.type,
                    "error_desc": info.descriptionShort
                ]
            )
        case .ratingSubmitted(score: let score):
            Analytics.logEvent(
                "rating_submitted",
                parameters: [
                    "score": NSNumber(value: score)
                ]
            )
        case .ratingDismissed:
            Analytics.logEvent(
                "rating_dismissed",
                parameters: nil
            )
        }
    }
    
    private static func errorInfo(from error: Error) -> (domain: String, code: Int, type: String, descriptionShort: String) {
        if let ne = error as? NetworkError {
            let ns = ne as NSError
            return (
                domain: ns.domain,
                code: ns.code,
                type: "NetworkError",
                descriptionShort: ns.localizedDescription
            )
        }
        
        // 2) 그 외(URLError, DecodingError, etc.)
        let ns = error as NSError
        let errorType: String = {
            if ns.domain == NSURLErrorDomain { return "URLError" }
            if error is DecodingError { return "DecodingError" }
            return String(describing: type(of: error))
        }()
        return (
            domain: ns.domain,
            code: ns.code,
            type: errorType,
            descriptionShort: ns.localizedDescription
        )
    }
}
