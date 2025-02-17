import AppKit
import UniformTypeIdentifiers

class ClipboardService {
    static let shared = ClipboardService()
    private let pasteboard = NSPasteboard.general
    
    func readClipboard() -> [PBItem] {
        guard let types = pasteboard.types else { return [] }
        
        return types.compactMap { type in
            guard let data = pasteboard.data(forType: type) else { return nil }
            return createPBItem(type: type, data: data)
        }
    }
    
    func writeToClipboard(_ items: [PBItem]) {
        pasteboard.clearContents()
        let pbItems = items.map { item in
            let pbItem = NSPasteboardItem()
            pbItem.setData(item.data, forType: item.pasteboardType)
            return pbItem
        }
        pasteboard.writeObjects(pbItems)

    }
    
    func getChangeCount() -> Int {
        return pasteboard.changeCount
    }

    func checkForURLAndTIFF() -> (hasURL: Bool, hasTIFF: Bool, urlData: Data?) {
        let types = pasteboard.types ?? []
        let hasURL = types.contains(.URL)
        let hasTIFF = types.contains(.tiff)
        let urlData = hasURL ? pasteboard.data(forType: .URL) : nil
        return (hasURL, hasTIFF, urlData)
    }

    
    private func createPBItem(type: NSPasteboard.PasteboardType, data: Data) -> PBItem {
        if let string = String(data: data, encoding: .utf8) {
            return PBItem(
                pasteboardType: type,
                displayName: "string => \(string)",
                data: data
            )
        }
        return createBinaryPBItem(type: type, data: data)
    }
    
    private func createBinaryPBItem(type: NSPasteboard.PasteboardType, data: Data) -> PBItem {
        let displayName: String
        
        // todo, could be better
        switch type {
        case .rtf:
            displayName = "rtf => length = \(data.count)"
        case .html:
            displayName = "html => length = \(data.count)"
        case .tiff:
            displayName = "tiff => length = \(data.count)"
        case .fileURL:
            let urlString = String(data: data, encoding: .utf8) ?? ""
            displayName = "file url => \(urlString)"
        default:
            displayName = "binary => length = \(data.count) bytes"
        }
        
        return PBItem(pasteboardType: type,
                     displayName: displayName,
                     data: data)
    }
}
