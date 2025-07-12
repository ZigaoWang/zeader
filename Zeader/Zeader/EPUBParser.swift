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
    var title: String = "Unknown Title"
    var author: String = "Unknown Author"
    
    private var currentElement: String = ""
    private var currentText: String = ""

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
        currentElement = elementName
        currentText = ""
        
        if elementName == "item", let id = attributeDict["id"], let href = attributeDict["href"] {
            manifest[id] = href
        } else if elementName == "itemref", let idref = attributeDict["idref"],
                  let href = manifest[idref] {
            spine.append(href)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "dc:title", "title":
            title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "dc:creator", "creator":
            author = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            break
        }
        currentText = ""
    }
} 