//
//  ContentView.swift
//  Zeader
//
//  Created by Zigao Wang on 7/9/25.
//

import SwiftUI
import UniformTypeIdentifiers
import ZIPFoundation
import WebKit

struct ContentView: View {
    @State private var showImporter = false
    @State private var epubDocument: EPUBDocument? = nil

    var body: some View {
        Group {
            if let document = epubDocument {
                ReaderView(document: document)
            } else {
                VStack {
                    Text("Welcome to Zeader")
                        .font(.title)
                        .padding()
                    Button("Import ePub") {
                        showImporter = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [UTType(filenameExtension: "epub")!],
                      allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    do {
                        let doc = try EPUBDocument(url: url)
                        epubDocument = doc
                    } catch {
                        print("Failed to open ePub: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to import file: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
