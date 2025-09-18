//
//  NetworkError.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/23/25.
//

import Foundation
public enum NetworkError: LocalizedError {
    case invalidURLError
    case requestFailed
    case decodingFailed
    case noData
    case unauthorized
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURLError:
            return "잘못된 URL입니다."
        case .requestFailed:
            return "네트워크 요청에 실패했습니다."
        case .decodingFailed:
            return "데이터 디코딩에 실패했습니다."
        case .noData:
            return "응답 데이터가 없습니다."
        case .unauthorized:
            return "인증에 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
