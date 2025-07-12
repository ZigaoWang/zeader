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
        context.coordinator.settings = settings
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.settings = settings
        
        // Only reload if URL changed
        if context.coordinator.lastURL != url {
            uiView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            context.coordinator.lastURL = url
            context.coordinator.isPageLoaded = false
        } else {
            // Same page, just update styles
            context.coordinator.applyStyles()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var lastURL: URL?
        var isPageLoaded = false
        var settings: ReaderSettings?
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            // Apply styles immediately after page loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.applyStyles()
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isPageLoaded = false
        }
        
        func applyStyles() {
            guard let webView = webView, 
                  let settings = settings,
                  isPageLoaded else { return }
            
            let cssInjection = """
            (function() {
                // Remove existing custom styles
                var existingStyles = document.querySelectorAll('#zeader-custom-style');
                existingStyles.forEach(function(style) {
                    style.remove();
                });
                
                // Create new style element
                var style = document.createElement('style');
                style.id = 'zeader-custom-style';
                style.type = 'text/css';
                style.innerHTML = `\(settings.cssString.replacingOccurrences(of: "`", with: "\\`"))`;
                document.head.appendChild(style);
                
                // Apply styles to body immediately
                document.body.style.fontFamily = '\(settings.fontFamily), serif';
                document.body.style.fontSize = '\(settings.fontSize)px';
                document.body.style.lineHeight = '\(settings.lineHeight)';
                document.body.style.color = '\(settings.theme.textHex)';
                document.body.style.backgroundColor = '\(settings.theme.backgroundHex)';
                document.body.style.margin = '0';
                document.body.style.padding = '\(settings.margin)px';
                
                // Force style recalculation
                document.body.offsetHeight;
                
                console.log('Zeader styles applied');
            })();
            """
            
            webView.evaluateJavaScript(cssInjection) { result, error in
                if let error = error {
                    print("CSS injection error: \(error)")
                } else {
                    print("CSS applied successfully")
                }
            }
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
        context.coordinator.settings = settings
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        context.coordinator.settings = settings
        
        // Only reload if URL changed
        if context.coordinator.lastURL != url {
            nsView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            context.coordinator.lastURL = url
            context.coordinator.isPageLoaded = false
        } else {
            // Same page, just update styles
            context.coordinator.applyStyles()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var lastURL: URL?
        var isPageLoaded = false
        var settings: ReaderSettings?
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            // Apply styles immediately after page loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.applyStyles()
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isPageLoaded = false
        }
        
        func applyStyles() {
            guard let webView = webView, 
                  let settings = settings,
                  isPageLoaded else { return }
            
            let cssInjection = """
            (function() {
                // Remove existing custom styles
                var existingStyles = document.querySelectorAll('#zeader-custom-style');
                existingStyles.forEach(function(style) {
                    style.remove();
                });
                
                // Create new style element
                var style = document.createElement('style');
                style.id = 'zeader-custom-style';
                style.type = 'text/css';
                style.innerHTML = `\(settings.cssString.replacingOccurrences(of: "`", with: "\\`"))`;
                document.head.appendChild(style);
                
                // Apply styles to body immediately
                document.body.style.fontFamily = '\(settings.fontFamily), serif';
                document.body.style.fontSize = '\(settings.fontSize)px';
                document.body.style.lineHeight = '\(settings.lineHeight)';
                document.body.style.color = '\(settings.theme.textHex)';
                document.body.style.backgroundColor = '\(settings.theme.backgroundHex)';
                document.body.style.margin = '0';
                document.body.style.padding = '\(settings.margin)px';
                
                // Force style recalculation
                document.body.offsetHeight;
                
                console.log('Zeader styles applied');
            })();
            """
            
            webView.evaluateJavaScript(cssInjection) { result, error in
                if let error = error {
                    print("CSS injection error: \(error)")
                } else {
                    print("CSS applied successfully")
                }
            }
        }
    }
}
#endif 