import SwiftUI
import WebKit

class ScrollDelegate: NSObject, UIScrollViewDelegate {
    @Binding var isScrolling: Bool
    @Binding var shouldRefresh: Bool

    init(isScrolling: Binding<Bool>, shouldRefresh: Binding<Bool>) {
        _isScrolling = isScrolling
        _shouldRefresh = shouldRefresh
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isScrolling = false
            if shouldRefresh && scrollView.contentOffset.y < -100 {
                shouldRefresh = false
                print("Refreshing...")
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
        if shouldRefresh && scrollView.contentOffset.y < -100 {
            shouldRefresh = false
            print("Refreshing...")
        }
    }
}

struct ContentView: View {
    let defaultURL = "https://www.google.com"

    @State private var urlString = ""
    @State private var isScrolling = false
    @State private var shouldRefresh = false
    @State private var isKeyboardActive = false

    struct BrowserView: View {
        let urlString: String

        var body: some View {
            WebView(urlString: urlString)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HStack {
                        Spacer()

                        TextField("Enter URL", text: $urlString, onEditingChanged: { editing in
                            isKeyboardActive = editing
                        }, onCommit: {
                            openURL()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(Color.gray.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                        .offset(y: isKeyboardActive ? -30 : 0)
                        .animation(.easeInOut(duration: 0.3))

                        Button(action: {
                            refresh()
                        }) {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                        .opacity(isScrolling || isKeyboardActive ? 0 : 1)
                        .animation(.easeInOut(duration: 0.3))
                    }
                    .frame(height: 50)
                    .background(Color.black.opacity(isScrolling || isKeyboardActive ? 0.8 : 1.0))

                    BrowserView(urlString: urlString)
                        .frame(width: geometry.size.width, height: geometry.size.height - geometry.safeAreaInsets.top - 100)

                    Spacer()

                    HStack {
                        Button(action: {
                            navigateBack()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 22))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.leading, 10)
                        .opacity(0.3)
                        .animation(.easeInOut(duration: 0.3))

                        Spacer()

                        Button(action: {
                            navigateForward()
                        }) {
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 22))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                        .opacity(0.3)
                        .animation(.easeInOut(duration: 0.3))
                    }
                    .frame(height: 50)
                    .background(Color.white)
                }
            }
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        }
        .onAppear {
            UIScrollView.appearance().delegate = ScrollDelegate(isScrolling: $isScrolling, shouldRefresh: $shouldRefresh)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refresh()
        }
    }

    private func openURL() {
        if urlString.isEmpty {
            urlString = defaultURL
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func refresh() {
        shouldRefresh = true
    }

    private func navigateBack() {
        // Implement your logic to navigate back in WebView
    }

    private func navigateForward() {
        // Implement your logic to navigate forward in WebView
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

@main
struct BrowserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

