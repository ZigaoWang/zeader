import Foundation
import ZIPFoundation

/// Represents an EPUB document and provides access to its chapters.
class EPUBDocument: ObservableObject {
    private let extractionURL: URL
    private let packageURL: URL
    private var manifest: [String: String] = [:]
    private var spine: [String] = []

    @Published var currentIndex: Int = 0

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

        // Base path for content files
        packageURL = opfURL.deletingLastPathComponent()
    }

    /// URL for the current chapter's HTML file.
    var currentChapterURL: URL {
        packageURL.appendingPathComponent(spine[currentIndex])
    }

    /// Title (filename) of the current chapter.
    var currentChapterTitle: String {
        spine[currentIndex]
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
} 