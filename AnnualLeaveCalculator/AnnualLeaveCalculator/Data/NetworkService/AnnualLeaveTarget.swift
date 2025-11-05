//
//  AnnualLeaveTarget.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import Foundation

enum AnnualLeaveTarget {
    case calculate(
        calculationType: Int,
        fiscalYear: String?,
        hireDate: String,
        referenceDate: String,
        nonWorkingPeriods: [NonWorkingPeriod]?,
        companyHolidays: [String]?
    )
    case submitFeedback(
        type: String,
        content: String,
        email: String?,
        rating: Int?,
        calculationId: String?
    )
    case submitRating(
        type: String,
        content: String?,
        email: String?,
        rating: Int,
        calculationId: String?
    )
}

extension AnnualLeaveTarget: TargetType {
    var method: HTTPMethods {
        switch self {
        case .calculate:
            return .post
        case .submitFeedback:
            return .post
        case .submitRating:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .calculate:
            return "/calculate"
        case .submitFeedback:
            return "/feedback"
        case .submitRating:
            return "/feedback"
        }
    }
    
    private var xTestFlag: String {
        #if DEBUG
            return "true"
        #else
            return "false"
        #endif
    }
    
    var headers: [String: String]? {
        
        switch self {
            
        case .calculate:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Platform": "ios",
                "X-Test": xTestFlag
            ]
        case .submitFeedback:
            return [
                "Content-Type": "application/json",
                "X-Platform": "ios",
                "X-Test": xTestFlag
            ]
        case .submitRating:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Platform": "ios",
                "X-Test": xTestFlag
            ]
        }
    }
    
    var parameters: [String: Any]? {
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
            
        case .submitFeedback(
            type: let type,
            content: let content,
            email: let email,
            rating: let rating,
            calculationId: let calculationId
        ):
            var dict: [String: Any] = [
                "type": type,
                "content": content,
            ]
            
            if let email = email {
                dict["email"] = email
            }
            
            if let rating = rating {
                dict["rating"] = rating
            }
            
            if let calculationId = calculationId {
                dict["calculationId"] = calculationId
            }
            
            return dict
        case .submitRating(
            type: _,
            content: let content,
            email: let email,
            rating: let rating,
            calculationId: let calculationId
        ):
            var dict: [String: Any] = [
                "type": "SATISFACTION",
                "rating": rating
            ]
            
            if let email = email {
                dict["email"] = email
            }
                        
            if let content = content {
                dict["content"] = content
            }
            
            if let calculationId = calculationId {
                dict["calculationId"] = calculationId
            }
            
            return dict
        }
    }
}
