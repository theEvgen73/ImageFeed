import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {

    @IBOutlet private weak var webView: WKWebView?
    @IBOutlet private weak var progressView: UIProgressView?

    weak var delegate: WebViewViewControllerDelegate?
    
    private var estimatedProgressObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let webView = webView, let progressView = progressView else { return }
        
        webView.navigationDelegate = self
        progressView.progress = 0.0
        progressView.isHidden = false
        loadAuthView()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateProgress()
            }
        )
    }

    private func updateProgress() {
        guard let webView = webView, let progressView = progressView else { return }
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func loadAuthView() {
        guard let webView = webView else { return }
        
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("[WebViewViewController]: loadAuthView - Ошибка: Не удалось создать URLComponents")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            print("[WebViewViewController]: loadAuthView - Ошибка: Не удалось получить URL")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
