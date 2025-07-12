import SwiftUI

struct ReaderView: View {
    @ObservedObject var document: EPUBDocument
    @ObservedObject var settings: ReaderSettings
    
    var body: some View {
        WebView(url: document.currentChapterURL, settings: settings)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // Swipe right to go to previous chapter
                        if value.translation.width > 100 && abs(value.translation.height) < 50 {
                            document.previousChapter()
                        }
                        // Swipe left to go to next chapter
                        else if value.translation.width < -100 && abs(value.translation.height) < 50 {
                            document.nextChapter()
                        }
                    }
            )
    }
} 