import Foundation
import SwiftUI

struct Book: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let coverImageData: Data?
    let filePath: String
    let dateAdded: Date
    var lastReadDate: Date?
    var currentChapter: Int = 0
    var readingProgress: Double = 0.0
    
    var coverImage: Image? {
        guard let coverImageData = coverImageData,
              let uiImage = UIImage(data: coverImageData) else { return nil }
        return Image(uiImage: uiImage)
    }
}

class BookLibrary: ObservableObject {
    @Published var books: [Book] = []
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let booksPath: URL
    
    init() {
        booksPath = documentsPath.appendingPathComponent("Books")
        try? FileManager.default.createDirectory(at: booksPath, withIntermediateDirectories: true)
        loadBooks()
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    private func saveBooks() {
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: "SavedBooks")
        }
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: "SavedBooks"),
           let savedBooks = try? JSONDecoder().decode([Book].self, from: data) {
            books = savedBooks
        }
    }
    
    func getBookPath(_ book: Book) -> URL {
        return booksPath.appendingPathComponent(book.filePath)
    }
} 