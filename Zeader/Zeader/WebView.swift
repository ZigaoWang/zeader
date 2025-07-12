import SwiftUI
import WebKit

#if os(iOS)
struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var settings: ReaderSettings
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Enable swipe gestures
        webView.allowsBackForwardNavigationGestures = true
        
        // Disable zoom and selection
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bouncesZoom = false
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        
        // Store reference for updates
        context.coordinator.webView = webView
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if URL changed
        if context.coordinator.lastURL != url {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            context.coordinator.lastURL = url
        }
        
        // Always update CSS when settings change
        context.coordinator.applyStyles(settings: settings)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var lastURL: URL?
        private var isPageLoaded = false
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            // Apply styles after page loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let settings = self.getCurrentSettings() {
                    self.applyStyles(settings: settings)
                }
            }
        }
        
        func applyStyles(settings: ReaderSettings) {
            guard let webView = webView, isPageLoaded else { return }
            
            let cssInjection = """
            (function() {
                // Remove existing custom styles
                var existingStyle = document.getElementById('zeader-custom-style');
                if (existingStyle) {
                    existingStyle.remove();
                }
                
                // Create new style element
                var style = document.createElement('style');
                style.id = 'zeader-custom-style';
                style.innerHTML = `\(settings.cssString)`;
                document.head.appendChild(style);
                
                // Force repaint
                document.body.style.display = 'none';
                document.body.offsetHeight;
                document.body.style.display = 'block';
            })();
            """
            
            webView.evaluateJavaScript(cssInjection) { result, error in
                if let error = error {
                    print("CSS injection error: \(error)")
                }
            }
        }
        
        private func getCurrentSettings() -> ReaderSettings? {
            // This is a workaround since we can't directly access settings from coordinator
            // The updateUIView will call applyStyles with the current settings
            return nil
        }
    }
}

#elseif os(macOS)
struct WebView: NSViewRepresentable {
    let url: URL
    @ObservedObject var settings: ReaderSettings
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Only reload if URL changed
        if context.coordinator.lastURL != url {
            nsView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            context.coordinator.lastURL = url
        }
        
        // Always update CSS when settings change
        context.coordinator.applyStyles(settings: settings)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var lastURL: URL?
        private var isPageLoaded = false
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            // Apply styles after page loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let settings = self.getCurrentSettings() {
                    self.applyStyles(settings: settings)
                }
            }
        }
        
        func applyStyles(settings: ReaderSettings) {
            guard let webView = webView, isPageLoaded else { return }
            
            let cssInjection = """
            (function() {
                // Remove existing custom styles
                var existingStyle = document.getElementById('zeader-custom-style');
                if (existingStyle) {
                    existingStyle.remove();
                }
                
                // Create new style element
                var style = document.createElement('style');
                style.id = 'zeader-custom-style';
                style.innerHTML = `\(settings.cssString)`;
                document.head.appendChild(style);
                
                // Force repaint
                document.body.style.display = 'none';
                document.body.offsetHeight;
                document.body.style.display = 'block';
            })();
            """
            
            webView.evaluateJavaScript(cssInjection) { result, error in
                if let error = error {
                    print("CSS injection error: \(error)")
                }
            }
        }
        
        private func getCurrentSettings() -> ReaderSettings? {
            return nil
        }
    }
}
#endif 