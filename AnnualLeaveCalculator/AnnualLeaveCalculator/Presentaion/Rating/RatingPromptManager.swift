//
//  RatingPromptManager.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 11/6/25.
//

import Foundation
/// 별점 팝업 노출 규칙
/// - 기본: 항상 노출
/// - 제출 성공: 28일 동안 비노출(영구 저장)
/// - 스킵: 현재 앱 세션 동안만 비노출(메모리)
final class RatingPromptManager {
    
    private let cooldownDays: Int = 28
    
    private struct Keys {
        static let cooldownUntil = "rating.cooldownUntil"
        static let lastSubmittedMajor = "rating.lastSubmittedMajor"
    }
    
    private let userDefaults: UserDefaults
    private let calendar: Calendar
    
    // 세션(앱 실행 중) 동안만 유지되는 스킵 플래그
    private var dismissedThisSession: Bool = false
    
    init(userDefaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.userDefaults = userDefaults
        self.calendar = calendar
    }
    
    /// 지금 보여도 되는가?
    func canShowPrompt() -> Bool {
        // 세션 스킵이면 이번 실행 동안은 숨김
        if dismissedThisSession { return false }
        
        // 제출 성공 쿨다운 체크
        if let until = userDefaults.object(forKey: Keys.cooldownUntil) as? Date {
            if Date() < until { return false }
        }
        return true
    }
    
    /// 제출 성공 시 호출: 28일 쿨다운 시작
    func markSubmitted() {
        if let next = calendar.date(byAdding: .day, value: cooldownDays, to: Date()) {
            userDefaults.set(next, forKey: Keys.cooldownUntil)
        }
        // 메이저 버전 기록(옵션)
        if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let major = Int(v.split(separator: ".").first ?? "0") {
            userDefaults.set(major, forKey: Keys.lastSubmittedMajor)
        }
    }
    
    /// 스킵(별점 없이 닫기) 시 호출: 이번 세션에서만 숨김
    func markDismissedThisSession() {
        dismissedThisSession = true
    }
    
    /// 앱 시작 시 한 번: 메이저 버전이 올라가면 쿨다운 해제(바로 노출)
    func clearCooldownIfMajorBumped() {
        guard
            let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let currentMajor = Int(v.split(separator: ".").first ?? "0")
        else { return }
        
        let lastMajor = userDefaults.integer(forKey: Keys.lastSubmittedMajor)
        if currentMajor > lastMajor {
            userDefaults.removeObject(forKey: Keys.cooldownUntil)
        }
        // 세션은 새로 시작이므로 자동으로 dismissedThisSession = false 상태
    }
}
