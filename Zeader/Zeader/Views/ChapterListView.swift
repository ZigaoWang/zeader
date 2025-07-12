import SwiftUI

struct ChapterListView: View {
    @ObservedObject var document: EPUBDocument
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<document.totalChapters, id: \.self) { index in
                    ChapterRowView(
                        index: index,
                        chapterName: document.getChapterName(at: index),
                        isCurrentChapter: index == document.currentIndex
                    )
                    .onTapGesture {
                        document.currentIndex = index
                        dismiss()
                    }
                }
            }
            .navigationTitle("Chapters")
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

struct ChapterRowView: View {
    let index: Int
    let chapterName: String
    let isCurrentChapter: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Chapter \(index + 1)")
                    .font(.headline)
                Text(chapterName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCurrentChapter {
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
    }
} 