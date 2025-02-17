import SwiftUI

@main
struct copyingApp: App {
    @StateObject private var viewModel = ClipboardMonitorViewModel()
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        MenuBarExtra("copyfix", systemImage: "clipboard") {
            DropdownView()
        }.menuBarExtraStyle(.window)
    }
}
