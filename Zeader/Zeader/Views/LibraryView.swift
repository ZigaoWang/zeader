import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @StateObject private var library = BookLibrary()
    @State private var showImporter = false
    @State private var selectedBook: Book?
    
    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 160), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(library.books) { book in
                        BookCoverView(book: book)
                            .onTapGesture {
                                selectedBook = book
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Book") {
                        showImporter = true
                    }
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [UTType(filenameExtension: "epub")!],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .fullScreenCover(item: $selectedBook) { book in
                ReaderContainerView(book: book, library: library)
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let document = try EPUBDocument(url: url)
                let fileName = "\(UUID().uuidString).epub"
                let destinationURL = library.getBookPath(Book(
                    title: document.title,
                    author: document.author,
                    coverImageData: document.coverImageData,
                    filePath: fileName,
                    dateAdded: Date()
                ))
                
                try FileManager.default.copyItem(at: url, to: destinationURL)
                
                let book = Book(
                    title: document.title,
                    author: document.author,
                    coverImageData: document.coverImageData,
                    filePath: fileName,
                    dateAdded: Date()
                )
                
                library.addBook(book)
                
            } catch {
                print("Failed to import book: \(error)")
            }
            
        case .failure(let error):
            print("Failed to select file: \(error)")
        }
    }
}

struct BookCoverView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover Image
            Group {
                if let coverImage = book.coverImage {
                    coverImage
                        .resizable()
                        .aspectRatio(0.7, contentMode: .fit)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(0.7, contentMode: .fit)
                        .overlay(
                            VStack {
                                Image(systemName: "book.closed")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                Text(book.title)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                        )
                }
            }
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // Book Info
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(book.author)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: 160)
    }
}

#Preview {
    LibraryView()
} 