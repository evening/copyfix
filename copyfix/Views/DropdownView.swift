import SwiftUI

struct DropdownView: View {
    @StateObject private var viewModel = ClipboardMonitorViewModel()
    
    var body: some View {
        ZStack {
            TransparentBackgroundView()
            
            VStack(spacing: 16) {
                Toggle("enable auto fix", isOn: $viewModel.autoFilter)
                    .toggleStyle(.switch)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
                
                // ehh. hardcoding 0.5 seems fine
                
                //                HStack(spacing: 12) {
                //                    Button(action: { viewModel.checkInterval = max(0.1, viewModel.checkInterval - 0.1) }) {
                //                        Image(systemName: "minus.circle.fill")
                //                            .resizable()
                //                            .frame(width: 20, height: 20)
                //                            .foregroundColor(.primary)
                //
                //                    }
                //                    .buttonStyle(ScaleButtonStyle())
                //                    .contentShape(Rectangle())
                //
                //                    Text("\(viewModel.checkInterval, specifier: "%.1f")s")
                //                        .monospacedDigit()
                //                        .frame(minWidth: 40, alignment: .center)
                //
                //                    Button(action: { viewModel.checkInterval = min(10.0, viewModel.checkInterval + 0.1) }) {
                //                        Image(systemName: "plus.circle.fill")
                //                            .resizable()
                //                            .frame(width: 20, height: 20)
                //                            .foregroundColor(.primary)
                //                    }
                //                    .buttonStyle(ScaleButtonStyle())
                //                    .contentShape(Rectangle())
                //                }
                
                Button("close app") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                VStack(spacing: 2) {
                    Text("made with ")
                        .foregroundColor(.secondary) +
                    Text("♥")
                        .foregroundColor(.red)
                    
                    HStack(spacing: 0) {
                        
                        Text("by ").foregroundColor(.secondary)
                        Button(action: {
                            NSWorkspace.shared.open(URL(string: "https://emily.systems")!)
                        }) {
                            Text("emily.systems")
                                .underline()
                        }
                        
                    }.buttonStyle(.link)
                    
                    
                }
            }
            .padding(.vertical, 20)
            .background(.clear)
            
        }.frame(width: 200)
        
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct TransparentBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .fullScreenUI
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}


#Preview {
    DropdownView()
}

