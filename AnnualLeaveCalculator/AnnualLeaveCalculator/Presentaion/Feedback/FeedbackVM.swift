//
//  FeedbackVM.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/25/25.
//

import Foundation
import Combine
import Foundation
import Combine

/// 피드백 화면용 ViewModel
/// - 입력: 유형 인덱스, 메시지, 이메일, 첨부 여부, 평점, 계산ID, 전송 트리거
/// - 출력: 제출 가능 여부, 로딩, 성공 시그널, 에러
final class FeedbackViewModel {
    
    // MARK: - Inputs
    /// 세그먼트 인덱스(0: 오류 제보, 1: 서비스 문의, 2: 개선 요청, 3: 기타)
    let setSelectedTypeIndex = CurrentValueSubject<Int, Never>(0)
    
    /// 본문 메시지
    let setMessage = CurrentValueSubject<String, Never>("")
    
    /// 답변 받을 이메일(선택)
    let setReplyEmail = CurrentValueSubject<String?, Never>(nil)
    
    /// 현재 계산 정보를 첨부할지 여부(체크 스위치)
    let setAttachCurrentCalculationInfo = CurrentValueSubject<Bool, Never>(true)
    
    /// 만족도 등 평점(선택)
    let setRating = CurrentValueSubject<Int?, Never>(nil)
    
    /// 첨부할 계산 결과의 식별자(옵션)
    /// - setAttachCurrentCalculationInfo가 true라도 값이 nil이면 첨부 없이 전송됨
    let setCalculationID = CurrentValueSubject<String?, Never>(nil)
    
    /// 전송 트리거
    let submitTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    /// 제출 버튼 활성화 여부(기본 규칙: 메시지 비어 있지 않아야 함 + 이메일 형식 검증)
    @Published private(set) var isSubmitEnabled: Bool = false
    
    /// 로딩 스피너 표시 여부
    @Published private(set) var isSubmitting: Bool = false
    
    /// 성공 시 true로 한 번 방출(화면에서는 이 신호를 받아 뒤로 가기, 토스트 등)
    @Published private(set) var didSubmit: Bool = false
    
    /// 실제로 서버에 보낼 계산ID(첨부 스위치와 ID를 합성한 결과)
    @Published private(set) var effectiveCalculationID: String?
    
    /// 에러 스트림
    let error = PassthroughSubject<Error, Never>()
    
    // MARK: - Private
    private let useCase: AnnualLeaveCalculatorUseCase
    private var cancellables = Set<AnyCancellable>()
    
    /// 플레이스홀더 문구에 맞춰 최소 5자로 설정
    private let minimumMessageLength: Int = 5
    
    // MARK: - Init
    init(useCase: AnnualLeaveCalculatorUseCase) {
        self.useCase = useCase
        bind()
    }
    
    // MARK: - Bind
    private func bind() {
        // 제출 가능 여부 계산
        Publishers.CombineLatest(setMessage, setReplyEmail)
            .map { [weak self] message, optionalEmail in
                guard let self = self else { return false }
                let messageOK = message.trimmingCharacters(in: .whitespacesAndNewlines).count >= self.minimumMessageLength
                let emailOK: Bool = {
                    guard let email = optionalEmail, email.isEmpty == false else { return true } // 비워두면 통과
                    return Self.isValidEmail(email)
                }()
                return messageOK && emailOK
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: &$isSubmitEnabled)
        
        // 첨부 스위치 + 계산ID -> effectiveCalculationID
        Publishers.CombineLatest(setAttachCurrentCalculationInfo, setCalculationID)
            .map { attach, id in attach ? id : nil }
            .removeDuplicates { $0 == $1 }
            .receive(on: RunLoop.main)
            .assign(to: &$effectiveCalculationID)
        
        // 제출
        submitTapped
            .sink { [weak self] in
                self?.handleSubmit()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Submit Flow
    private func handleSubmit() {
        // 1) 사전 검증
        guard isSubmitEnabled else {
            error.send(FeedbackValidationError.invalidForm)
            return
        }
        
        guard let type = FeedbackType(selectedIndex: setSelectedTypeIndex.value) else {
            error.send(FeedbackValidationError.invalidTypeIndex)
            return
        }
        
        let message = setMessage.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let replyEmail: String? = {
            guard let raw = setReplyEmail.value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  raw.isEmpty == false else { return nil }
            return raw
        }()
        
        let rating = setRating.value
        
        // 첨부 플래그에 따라 calculationID를 보낼지 결정
        let calculationID: String? = {
            let attach = setAttachCurrentCalculationInfo.value
            guard attach else { return nil }
            return setCalculationID.value
        }()
        
        // 2) 전송
        isSubmitting = true
        didSubmit = false
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.useCase.submitFeedback(
                    type: type,
                    content: message,
                    email: replyEmail,
                    rating: rating,
                    calculationId: calculationID
                )
                await MainActor.run {
                    self.isSubmitting = false
                    self.didSubmit = true
                }
            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    self.error.send(error)
                }
            }
        }
    }
    
    // MARK: - Utilities
    private static func isValidEmail(_ email: String) -> Bool {
        // 간단한 RFC 5322 근사치(필요 시 프로젝트 공용 Validator로 교체)
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Errors
enum FeedbackValidationError: LocalizedError {
    case invalidForm
    case invalidTypeIndex
    
    var errorDescription: String? {
        switch self {
        case .invalidForm:
            return "필수 항목을 확인해주세요. (내용을 입력하고 이메일 형식을 확인하세요)"
        case .invalidTypeIndex:
            return "잘못된 피드백 유형입니다."
        }
    }
}

// MARK: - FeedbackType mapping (UI index → Domain)
extension FeedbackType {
    /// UI 세그먼트 인덱스를 도메인 타입으로 변환
    /// ["오류 제보", "서비스 문의", "개선 요청", "기타"] 기준
    init?(selectedIndex: Int) {
        switch selectedIndex {
        case 0: self = .errorReport
        case 1: self = .question
        case 2: self = .improvement
        case 3: self = .other
        default: return nil
        }
    }
}
