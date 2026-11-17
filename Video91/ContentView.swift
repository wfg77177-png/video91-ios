import SwiftUI
import WebKit

// 91 私有视频站地址：甲骨文东京 Tailscale 内网 IP
// 如需改走公网，把下面改成 http://161.33.213.248:9191/（需先在甲骨文控制台放行 9191 端口）
let serverURL = "http://100.79.223.77:9191/"

struct WebView: UIViewRepresentable {
    let url: String
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = true
        if let u = URL(string: url) {
            wv.load(URLRequest(url: u))
        }
        return wv
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        WebView(url: serverURL)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("91")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
