import SwiftUI

struct ReaderView: View {
    @ObservedObject var document: EPUBDocument

    var body: some View {
        VStack(spacing: 0) {
            WebView(url: document.currentChapterURL)
            HStack {
                Button(action: {
                    document.previousChapter()
                }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!document.hasPrevious)

                Text(document.currentChapterTitle)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity)

                Button(action: {
                    document.nextChapter()
                }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!document.hasNext)
            }
            .padding()
        }
    }
} 