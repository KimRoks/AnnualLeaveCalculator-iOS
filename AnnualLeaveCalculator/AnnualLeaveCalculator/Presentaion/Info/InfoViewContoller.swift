//  InfoViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/23/25.
//
//
//  InfoViewController.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 9/xx/25.
//

import UIKit
import WebKit
import SnapKit
// TODO: 당장은 웹뷰로 처리, 추후 개선

final class InfoViewController: BaseViewController {
        override var navigationTitle: String? { "이용 약관" }

    private let defaultURLString = "https://maze-palladium-edf.notion.site/Lawding-273c4b24d2e2805f99f5f0eba1645a96?source=copy_link"
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = true
        return wv
    }()
    
    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.isHidden = true
        return pv
    }()
    
    private var progressObservation: NSKeyValueObservation?
    private var titleObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupObservers()
        loadIfPossible()
    }
    
    deinit {
        progressObservation = nil
        titleObservation = nil
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(progressView)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // 필요하면 우측 상단에 새로고침 버튼 추가
        let refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        navigationItem.rightBarButtonItem = refreshItem
    }
    
    private func setupConstraints() {
        progressView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalTo(view)
            $0.height.equalTo(2)
        }
        webView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view)
        }
    }
    
    private func setupObservers() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            self.progressView.isHidden = webView.estimatedProgress >= 1.0
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.progressView.setProgress(0, animated: false)
                }
            }
        }
        
        titleObservation = webView.observe(\.title, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            if self.navigationTitle == nil {
                self.navigationItem.title = webView.title
            }
        }
    }
    
    // MARK: - Load
    private func loadIfPossible() {
        guard let url = URL(string: defaultURLString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    // MARK: - Actions
    @objc private func refreshTapped() {
        if webView.url != nil {
            webView.reload()
        } else {
            loadIfPossible()
        }
    }
}

// MARK: - WKNavigationDelegate / WKUIDelegate
extension InfoViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        showAlert(message: "페이지를 불러오지 못했어요.\n\(error.localizedDescription)", title: "로드 실패")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        showAlert(message: "페이지를 불러오지 못했어요.\n\(error.localizedDescription)", title: "로드 실패")
    }
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
