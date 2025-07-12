import SwiftUI

struct ReaderSettingsView: View {
    @ObservedObject var settings: ReaderSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Theme")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(ReaderTheme.allCases, id: \.self) { theme in
                                ThemePreviewButton(
                                    theme: theme,
                                    isSelected: settings.theme == theme
                                ) {
                                    settings.theme = theme
                                    settings.updateSettings()
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    
                    // Brightness
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brightness")
                            .font(.subheadline)
                        Slider(value: $settings.brightness, in: 0.3...1.0, step: 0.1)
                            .onChange(of: settings.brightness) { _ in
                                settings.updateSettings()
                            }
                    }
                }
                
                Section("Typography") {
                    // Font Family
                    Picker("Font", selection: $settings.fontFamily) {
                        ForEach(settings.availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    .onChange(of: settings.fontFamily) { _ in
                        settings.updateSettings()
                    }
                    
                    // Font Size
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Font Size: \(Int(settings.fontSize))pt")
                            .font(.subheadline)
                        Slider(value: $settings.fontSize, in: 12...28, step: 1)
                            .onChange(of: settings.fontSize) { _ in
                                settings.updateSettings()
                            }
                    }
                    
                    // Line Height
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Line Spacing: \(settings.lineHeight, specifier: "%.1f")")
                            .font(.subheadline)
                        Slider(value: $settings.lineHeight, in: 1.0...2.5, step: 0.1)
                            .onChange(of: settings.lineHeight) { _ in
                                settings.updateSettings()
                            }
                    }
                    
                    // Margin
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Margin: \(Int(settings.margin))px")
                            .font(.subheadline)
                        Slider(value: $settings.margin, in: 10...40, step: 5)
                            .onChange(of: settings.margin) { _ in
                                settings.updateSettings()
                            }
                    }
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sample Text")
                            .font(.headline)
                        
                        Text("The quick brown fox jumps over the lazy dog. This is a sample text to preview your reading settings. You can adjust the font, size, spacing, and theme to create your perfect reading experience.")
                            .font(.custom(settings.fontFamily, size: settings.fontSize))
                            .lineSpacing(settings.fontSize * (settings.lineHeight - 1))
                            .foregroundColor(settings.theme.textColor)
                            .padding(settings.margin)
                            .background(settings.theme.backgroundColor)
                            .cornerRadius(12)
                    }
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ThemePreviewButton: View {
    let theme: ReaderTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                    .overlay(
                        VStack(spacing: 6) {
                            Text("Aa")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(theme.textColor)
                            
                            VStack(spacing: 2) {
                                Rectangle()
                                    .fill(theme.textColor)
                                    .frame(height: 2)
                                    .frame(maxWidth: 40)
                                Rectangle()
                                    .fill(theme.textColor.opacity(0.7))
                                    .frame(height: 2)
                                    .frame(maxWidth: 30)
                                Rectangle()
                                    .fill(theme.textColor.opacity(0.5))
                                    .frame(height: 2)
                                    .frame(maxWidth: 35)
                            }
                        }
                        .padding(16)
                    )
                    .frame(height: 80)
                
                Text(theme.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
} 