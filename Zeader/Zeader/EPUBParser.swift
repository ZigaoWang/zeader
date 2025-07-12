import Foundation

/// Parses the EPUB container.xml to find the rootfile path.
class ContainerParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    var rootfilePath: String = ""

    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }

    func parse() throws {
        if !parser.parse(), let error = parser.parserError {
            throw error
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "rootfile", let path = attributeDict["full-path"] {
            rootfilePath = path
        }
    }
}

/// Parses the OPF package to extract the manifest and spine.
class OPFParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser
    var manifest: [String: String] = [:]
    var spine: [String] = []

    init(data: Data) {
        parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
    }

    func parse() throws {
        if !parser.parse(), let error = parser.parserError {
            throw error
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item", let id = attributeDict["id"], let href = attributeDict["href"] {
            manifest[id] = href
        } else if elementName == "itemref", let idref = attributeDict["idref"],
                  let href = manifest[idref] {
            spine.append(href)
        }
    }
} 