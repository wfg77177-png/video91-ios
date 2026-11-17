import SwiftUI
import WebKit

// 91 私有视频站地址：甲骨文东京 Tailscale 内网 IP
// 如需改走公网，把下面改成 http://161.33.213.248:9191/（需先在甲骨文控制台放行 9191 端口）
let serverURL = "http://100.79.223.77:9191/"

class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var isLoading = true
    @Published var loadFailed = false
    @Published var reloadToken = 0
    weak var webView: WKWebView?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        loadFailed = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        loadFailed = true
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        loadFailed = true
    }
}

struct WebView: UIViewRepresentable {
    let url: String
    @ObservedObject var model: WebViewModel

    func makeCoordinator() -> WebViewModel { model }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = true
        wv.isOpaque = false
        wv.backgroundColor = .black
        model.webView = wv
        if let u = URL(string: url) {
            wv.load(URLRequest(url: u))
        }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if model.reloadToken > 0 {
            if let u = URL(string: url) {
                uiView.load(URLRequest(url: u))
            }
            DispatchQueue.main.async {
                model.reloadToken = 0
                model.isLoading = true
                model.loadFailed = false
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var model = WebViewModel()

    var body: some View {
        ZStack {
            WebView(url: serverURL, model: model)
                .ignoresSafeArea(edges: .bottom)
            if model.isLoading {
                Color.black
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("正在加载…")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
            }
            if model.loadFailed {
                Color.black
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("打不开 91")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("请确认手机已连接 Tailscale，\n然后点下面重试。")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("重新加载") {
                        model.reloadToken = 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("91")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    model.reloadToken = 1
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let u = URL(string: serverURL) {
                        UIApplication.shared.open(u)
                    }
                }) {
                    Image(systemName: "safari")
                }
            }
        }
    }
}
