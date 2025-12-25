//
//  LawdingServiceTarget.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import Foundation

enum LawdingServiceTarget {
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

extension LawdingServiceTarget: TargetType {
    var basePath: String? {
        return nil
    }
    
    var method: HTTPMethods {
        switch self {
        case .submitFeedback:
            return .post
        case .submitRating:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .submitFeedback:
            return "/v1/feedback"
        case .submitRating:
            return "/v1/feedback"
        }
    }
    
    var headers: [String: String]? {
        
        switch self {
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
