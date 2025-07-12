import SwiftUI

struct ReaderContainerView: View {
    let book: Book
    let library: BookLibrary
    
    @StateObject private var document: EPUBDocument
    @StateObject private var settings = ReaderSettings()
    @State private var showSettings = false
    @State private var showChapterList = false
    @Environment(\.dismiss) private var dismiss
    
    init(book: Book, library: BookLibrary) {
        self.book = book
        self.library = library
        
        // Initialize document
        let bookURL = library.getBookPath(book)
        do {
            let doc = try EPUBDocument(url: bookURL)
            doc.currentIndex = book.currentChapter
            self._document = StateObject(wrappedValue: doc)
        } catch {
            // Fallback to empty document
            self._document = StateObject(wrappedValue: try! EPUBDocument(url: bookURL))
        }
    }
    
    var body: some View {
        ZStack {
            settings.theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button("Library") {
                        saveProgress()
                        dismiss()
                    }
                    
                    Spacer()
                    
                    Text(document.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { showChapterList = true }) {
                            Image(systemName: "list.bullet")
                        }
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "textformat.size")
                        }
                    }
                }
                .padding()
                .background(settings.theme.backgroundColor.opacity(0.9))
                
                // Reader View
                ReaderView(document: document, settings: settings)
                
                // Bottom Navigation
                HStack {
                    Button(action: { document.previousChapter() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .disabled(!document.hasPrevious)
                    
                    Spacer()
                    
                    // Progress indicator
                    VStack(spacing: 4) {
                        Text("\(document.currentIndex + 1) of \(document.totalChapters)")
                            .font(.caption)
                        
                        ProgressView(value: document.progress)
                            .frame(width: 100)
                    }
                    
                    Spacer()
                    
                    Button(action: { document.nextChapter() }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                    .disabled(!document.hasNext)
                }
                .padding()
                .background(settings.theme.backgroundColor.opacity(0.9))
            }
        }
        .preferredColorScheme(settings.theme == .dark ? .dark : .light)
        .brightness(settings.brightness - 1.0)
        .sheet(isPresented: $showSettings) {
            ReaderSettingsView(settings: settings)
        }
        .sheet(isPresented: $showChapterList) {
            ChapterListView(document: document)
        }
    }
    
    private func saveProgress() {
        var updatedBook = book
        updatedBook.currentChapter = document.currentIndex
        updatedBook.readingProgress = document.progress
        updatedBook.lastReadDate = Date()
        library.updateBook(updatedBook)
    }
} 