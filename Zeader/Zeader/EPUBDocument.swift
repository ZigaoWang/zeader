import Foundation
import ZIPFoundation
import UIKit

/// Represents an EPUB document and provides access to its chapters.
class EPUBDocument: ObservableObject {
    private let extractionURL: URL
    private let packageURL: URL
    private var manifest: [String: String] = [:]
    private var spine: [String] = []
    
    @Published var currentIndex: Int = 0
    @Published var title: String = "Unknown Title"
    @Published var author: String = "Unknown Author"
    @Published var coverImageData: Data?
    
    /// Initializes and extracts the EPUB at the given URL.
    init(url: URL) throws {
        let fileManager = FileManager.default
        extractionURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: extractionURL, withIntermediateDirectories: true)

        guard let archive = Archive(url: url, accessMode: .read) else {
            throw NSError(domain: "EPUBDocument", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to read EPUB archive"])
        }

        for entry in archive {
            let destinationURL = extractionURL.appendingPathComponent(entry.path)
            try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            _ = try archive.extract(entry, to: destinationURL)
        }

        // Parse container.xml
        let containerURL = extractionURL.appendingPathComponent("META-INF/container.xml")
        let containerData = try Data(contentsOf: containerURL)
        let containerParser = ContainerParser(data: containerData)
        try containerParser.parse()
        let rootfilePath = containerParser.rootfilePath

        // Parse OPF
        let opfURL = extractionURL.appendingPathComponent(rootfilePath)
        let opfData = try Data(contentsOf: opfURL)
        let opfParser = OPFParser(data: opfData)
        try opfParser.parse()
        manifest = opfParser.manifest
        spine = opfParser.spine
        title = opfParser.title
        author = opfParser.author

        // Base path for content files
        packageURL = opfURL.deletingLastPathComponent()
        
        // Extract cover image
        extractCoverImage()
    }
    
    private func extractCoverImage() {
        // Look for cover image in manifest
        for (_, href) in manifest {
            if href.lowercased().contains("cover") && (href.lowercased().hasSuffix(".jpg") || href.lowercased().hasSuffix(".jpeg") || href.lowercased().hasSuffix(".png")) {
                let coverURL = packageURL.appendingPathComponent(href)
                coverImageData = try? Data(contentsOf: coverURL)
                return
            }
        }
        
        // Fallback: look for any image in the root
        let imageExtensions = ["jpg", "jpeg", "png", "gif"]
        for ext in imageExtensions {
            let possibleCover = packageURL.appendingPathComponent("cover.\(ext)")
            if FileManager.default.fileExists(atPath: possibleCover.path) {
                coverImageData = try? Data(contentsOf: possibleCover)
                return
            }
        }
    }

    /// URL for the current chapter's HTML file.
    var currentChapterURL: URL {
        packageURL.appendingPathComponent(spine[currentIndex])
    }

    /// Title (filename) of the current chapter.
    var currentChapterTitle: String {
        let filename = spine[currentIndex]
        return filename.replacingOccurrences(of: ".xhtml", with: "").replacingOccurrences(of: ".html", with: "")
    }

    /// Whether there is a next chapter.
    var hasNext: Bool {
        currentIndex + 1 < spine.count
    }

    /// Whether there is a previous chapter.
    var hasPrevious: Bool {
        currentIndex > 0
    }

    /// Move to the next chapter if available.
    func nextChapter() {
        if hasNext { currentIndex += 1 }
    }

    /// Move to the previous chapter if available.
    func previousChapter() {
        if hasPrevious { currentIndex -= 1 }
    }
    
    /// Total number of chapters
    var totalChapters: Int {
        spine.count
    }
    
    /// Current reading progress (0.0 to 1.0)
    var progress: Double {
        guard totalChapters > 0 else { return 0.0 }
        return Double(currentIndex) / Double(totalChapters)
    }
    
    /// Get the chapter name at a specific index
    func getChapterName(at index: Int) -> String {
        guard index >= 0 && index < spine.count else { return "" }
        let filename = spine[index]
        return filename
            .replacingOccurrences(of: ".xhtml", with: "")
            .replacingOccurrences(of: ".html", with: "")
    }
} 