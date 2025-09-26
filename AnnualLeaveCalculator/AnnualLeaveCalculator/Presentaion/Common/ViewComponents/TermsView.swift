//
//  TermsView.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/26/25.
//


import UIKit
import SnapKit
import WebKit

final class TermsView: UIView, UITextViewDelegate {

    var onTapTerms: (() -> Void)?

    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textAlignment = .right
        textView.adjustsFontForContentSizeCategory = true
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        textView.delegate = self
        textView.snp.makeConstraints { $0.edges.equalToSuperview() }
        configureText()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureText() {
        let fullText = "계산하기 버튼을 통해 앱 이용약관에 동의한걸로 간주됩니다."
        let attr = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.pretendard(style: .regular, size: 13),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        // '이용약관'만 링크/강조
        let target = "이용약관"
        let nsFullText = fullText as NSString
        let range = nsFullText.range(of: target)
        if range.location != NSNotFound {
            attr.addAttribute(.link, value: "lawding://terms", range: range)
            
            attr.addAttributes([
                .font: UIFont.pretendard(style: .bold, size: 13),
                .foregroundColor: UIColor.label
            ], range: range)
        }
        textView.attributedText = attr
        textView.tintColor = .systemBlue
    }
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if URL.scheme == "lawding" {
            onTapTerms?()
            return false
        }
        return true
    }
}
