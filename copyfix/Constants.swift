import SwiftUI


//extension UserDefaults {
//    @objc dynamic var checkInterval: Double {
//        get { double(forKey: "checkInterval") }
//        set { set(newValue, forKey: "checkInterval") }
//    }
//}

enum PBConstants {
    static let publicURL = "public.url"
    static let publicTIFF = "public.tiff"
}

struct PBItem: Identifiable {
    let id = UUID()
    let pasteboardType: NSPasteboard.PasteboardType
    let displayName: String
    let data: Data
    var isSelected: Bool = false
}
