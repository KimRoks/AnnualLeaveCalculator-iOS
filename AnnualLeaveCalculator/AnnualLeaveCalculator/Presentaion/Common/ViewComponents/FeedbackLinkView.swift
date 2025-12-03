//
//  FeedbackLinkView.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/26/25.
//

import UIKit
import SnapKit

final class FeedbackLinkView: UIView {
    var onTapFeedback: (() -> Void)?

    private let fullText = "여러분의 소중한 의견을 피드백을 통해 보내주세요."
    private let target = "피드백"
    private var linkRange: NSRange = .init(location: NSNotFound, length: 0)

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isSelectable = false          // 선택/복사 비활성
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.textAlignment = .right
        tv.adjustsFontForContentSizeCategory = true
        
        return tv
    }()

    // 제스처용 TextKit
    private let layoutManager = NSLayoutManager()
    private let textStorage = NSTextStorage()
    private let textContainer = NSTextContainer(size: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textView)
        textView.snp.makeConstraints { $0.edges.equalToSuperview() }

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = 0
        textContainer.lineBreakMode = .byWordWrapping

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        textView.addGestureRecognizer(tap)

        configureTextLikeTermsViewStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = textView.bounds.size
    }

    private func configureTextLikeTermsViewStyle() {
        let base = [
            NSAttributedString.Key.font: UIFont.pretendard(style: .regular, size: 13),
            .foregroundColor: UIColor(hex: "#BEC1C8")
        ] as [NSAttributedString.Key : Any]

        let attr = NSMutableAttributedString(string: fullText, attributes: base)

        let ns = fullText as NSString
        let range = ns.range(of: target)
        linkRange = range

        if range.location != NSNotFound {
            attr.addAttributes([
                .font: UIFont.pretendard(style: .bold, size: 13),
                .foregroundColor: UIColor.brandColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: range)
        }

        textView.attributedText = attr
        textView.tintColor = .systemBlue

        textStorage.setAttributedString(attr)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard linkRange.location != NSNotFound else { return }

        let point = gesture.location(in: textView)
        let index = characterIndex(at: point)

        if index != NSNotFound, NSLocationInRange(index, linkRange) {
            onTapFeedback?()
        }
    }

    private func characterIndex(at point: CGPoint) -> Int {
        guard textView.bounds.size != .zero else { return NSNotFound }

        let glyphRange = layoutManager.glyphRange(for: textContainer)
        var textRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        let horizontalInset = max(0, textView.bounds.width - textRect.width)
        if textView.textAlignment == .right {
            textRect.origin.x = horizontalInset
        } else if textView.textAlignment == .center {
            textRect.origin.x = horizontalInset / 2
        } else {
            textRect.origin.x = 0
        }

        let location = CGPoint(x: point.x - textRect.origin.x,
                               y: point.y - textRect.origin.y)

        let glyphIndex = layoutManager.glyphIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceThroughGlyph: nil
        )

        let glyphRect = layoutManager.boundingRect(
            forGlyphRange: NSRange(location: glyphIndex, length: 1),
            in: textContainer
        )
        guard glyphRect.contains(location) else { return NSNotFound }

        return layoutManager.characterIndexForGlyph(at: glyphIndex)
    }
}
