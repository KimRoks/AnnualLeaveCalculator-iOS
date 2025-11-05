//
//  AnalyticsLogging.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/31/25.
//

import Foundation

public protocol AnalyticsLogging {
    func log(_ event: AppEvent)
}

public enum AppEvent {
    case tapCalculate
    case calculateSucceeded
    case calculateFailed(error: Error)
    
    case tapSubmitFeedback
    case feedbackSucceeded
    case feedbackFailed(error: Error)
    
    case ratingSubmitted(score: Int)
    case ratingDismissed
}
