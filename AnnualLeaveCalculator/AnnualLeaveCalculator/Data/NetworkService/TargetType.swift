//
//  TargetType.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import Foundation

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol TargetType {
    var basePath: String? { get }
    var method: HTTPMethods { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    
    func asURLRequest() throws -> URLRequest
}

extension TargetType {
    var xTestFlag: String {
    #if DEBUG
        return "true"
    #else
        return "false"
    #endif
    }
    
    var baseURL: String {
        if let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String {
            return baseURL
        } else {
            print("Base URL Missing")
            return ""
        }
    }
    
    var basePath: String? {
        return nil
    }
    
    func asURLRequest() throws -> URLRequest {
        // basePath 옵셔널 처리
        let fullPath = (basePath ?? "") + path
        guard let fullUrl = URL(string: baseURL + fullPath) else {
            throw NetworkError.invalidURLError
        }
        
        var urlRequest = URLRequest(url: fullUrl)
        urlRequest.httpMethod = method.rawValue
        
        // 헤더 세팅
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // 파라미터 인코딩
        switch method {
        case .get:
            // GET은 URL 쿼리 인코딩
            if let params = parameters {
                var components = URLComponents(url: fullUrl, resolvingAgainstBaseURL: false)
                components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                if let urlWithQuery = components?.url {
                    urlRequest.url = urlWithQuery
                }
            }
        default:
            // POST, PATCH, DELETE 등은 JSON 바디 인코딩
            if let params = parameters {
                // headers에 Content-Type이 없을 때만 추가
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            }
        }
        
        return urlRequest
    }
}
