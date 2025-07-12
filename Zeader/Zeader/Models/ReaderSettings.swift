import Foundation
import SwiftUI

enum ReaderTheme: String, CaseIterable {
    case light = "Light"
    case sepia = "Sepia"
    case dark = "Dark"
    case night = "Night"
    
    var backgroundColor: Color {
        switch self {
        case .light: return Color.white
        case .sepia: return Color(red: 0.98, green: 0.94, blue: 0.86)
        case .dark: return Color(red: 0.2, green: 0.2, blue: 0.2)
        case .night: return Color.black
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return Color.black
        case .sepia: return Color(red: 0.3, green: 0.2, blue: 0.1)
        case .dark: return Color.white
        case .night: return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
    }
    
    var backgroundHex: String {
        switch self {
        case .light: return "#FFFFFF"
        case .sepia: return "#FAF0DC"
        case .dark: return "#333333"
        case .night: return "#000000"
        }
    }
    
    var textHex: String {
        switch self {
        case .light: return "#000000"
        case .sepia: return "#4D3319"
        case .dark: return "#FFFFFF"
        case .night: return "#E6E6E6"
        }
    }
}

class ReaderSettings: ObservableObject {
    @Published var fontSize: CGFloat = 18
    @Published var fontFamily: String = "Georgia"
    @Published var theme: ReaderTheme = .light
    @Published var lineHeight: CGFloat = 1.6
    @Published var brightness: Double = 1.0
    @Published var margin: CGFloat = 20
    
    let availableFonts = [
        "Georgia",
        "Times New Roman", 
        "Palatino",
        "Baskerville",
        "Helvetica Neue",
        "San Francisco",
        "Avenir",
        "Charter"
    ]
    
    init() {
        loadSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(fontSize, forKey: "ReaderFontSize")
        UserDefaults.standard.set(fontFamily, forKey: "ReaderFontFamily")
        UserDefaults.standard.set(theme.rawValue, forKey: "ReaderTheme")
        UserDefaults.standard.set(lineHeight, forKey: "ReaderLineHeight")
        UserDefaults.standard.set(brightness, forKey: "ReaderBrightness")
        UserDefaults.standard.set(margin, forKey: "ReaderMargin")
    }
    
    private func loadSettings() {
        fontSize = UserDefaults.standard.object(forKey: "ReaderFontSize") as? CGFloat ?? 18
        fontFamily = UserDefaults.standard.string(forKey: "ReaderFontFamily") ?? "Georgia"
        if let themeString = UserDefaults.standard.string(forKey: "ReaderTheme"),
           let savedTheme = ReaderTheme(rawValue: themeString) {
            theme = savedTheme
        }
        lineHeight = UserDefaults.standard.object(forKey: "ReaderLineHeight") as? CGFloat ?? 1.6
        brightness = UserDefaults.standard.double(forKey: "ReaderBrightness")
        if brightness == 0 { brightness = 1.0 }
        margin = UserDefaults.standard.object(forKey: "ReaderMargin") as? CGFloat ?? 20
    }
    
    func updateSettings() {
        saveSettings()
        objectWillChange.send()
    }
    
    // Generate CSS for the current settings
    var cssString: String {
        return """
        * {
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            -khtml-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }
        
        html, body {
            font-family: '\(fontFamily)', serif !important;
            font-size: \(fontSize)px !important;
            line-height: \(lineHeight) !important;
            color: \(theme.textHex) !important;
            background-color: \(theme.backgroundHex) !important;
            margin: 0 !important;
            padding: \(margin)px !important;
            text-align: justify !important;
            -webkit-text-size-adjust: none !important;
            -webkit-font-smoothing: antialiased !important;
        }
        
        body {
            max-width: 100% !important;
            overflow-x: hidden !important;
        }
        
        p, div, span, li, td, th {
            font-family: '\(fontFamily)', serif !important;
            font-size: \(fontSize)px !important;
            line-height: \(lineHeight) !important;
            color: \(theme.textHex) !important;
            text-align: justify !important;
        }
        
        h1, h2, h3, h4, h5, h6 {
            font-family: '\(fontFamily)', serif !important;
            color: \(theme.textHex) !important;
            font-weight: bold !important;
            margin-top: 1.5em !important;
            margin-bottom: 0.5em !important;
        }
        
        h1 { font-size: \(fontSize * 1.8)px !important; }
        h2 { font-size: \(fontSize * 1.6)px !important; }
        h3 { font-size: \(fontSize * 1.4)px !important; }
        h4 { font-size: \(fontSize * 1.2)px !important; }
        h5 { font-size: \(fontSize * 1.1)px !important; }
        h6 { font-size: \(fontSize)px !important; }
        
        a {
            color: \(theme.textHex) !important;
            text-decoration: underline !important;
        }
        
        img {
            max-width: 100% !important;
            height: auto !important;
            display: block !important;
            margin: 1em auto !important;
        }
        
        blockquote {
            margin: 1em 0 !important;
            padding: 0 2em !important;
            border-left: 3px solid \(theme.textHex) !important;
            font-style: italic !important;
        }
        
        code, pre {
            font-family: 'Menlo', 'Monaco', monospace !important;
            background-color: rgba(128, 128, 128, 0.1) !important;
            padding: 0.2em 0.4em !important;
            border-radius: 3px !important;
        }
        
        table {
            width: 100% !important;
            border-collapse: collapse !important;
            margin: 1em 0 !important;
        }
        
        th, td {
            border: 1px solid \(theme.textHex) !important;
            padding: 0.5em !important;
        }
        """
    }
} 