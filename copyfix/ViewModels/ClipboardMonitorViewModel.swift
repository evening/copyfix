import SwiftUI
import Combine

class ClipboardMonitorViewModel: ObservableObject {
    @Published var autoFilter: Bool = false {
        didSet {
            if oldValue != autoFilter {
                print("[monitor-vm] [auto-filter] changed to: \(autoFilter)")
            }
        }
    }

//    @AppStorage("checkInterval") var checkInterval: Double = 1.0
    private let checkInterval: Double = 0.5

    private var lastChangeCount: Int = 0
    
    private let clipboardService: ClipboardService
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(clipboardService: ClipboardService = .shared) {
        self.clipboardService = clipboardService
        setupTimerSubscription()
    }
    
    private func setupTimerSubscription() {
        $autoFilter
            .handleEvents(receiveOutput: { [weak self] isActive in
                print("[monitor-vm] [setup-timer-subscription] timer config updated - active: \(isActive), interval: \(self?.checkInterval ?? 0)s")
            })
            .map { isActive -> AnyPublisher<Date, Never> in
                guard isActive else {
                    print("[monitor-vm] [setup-timer-subscription] monitoring inactive")
                    return Empty().eraseToAnyPublisher()
                }
                print("[monitor-vm] [setup-timer-subscription] creating new timer with interval: 0.5s")
                return Timer.publish(
                    every: 0.5,
//                    tolerance: 0.05, // 0.5 * 0.1
                    on: .main,
                    in: .common
                )
                .autoconnect()
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] _ in
                self?.checkAndRemoveURLIfNeeded()
            }
            .store(in: &cancellables)
    }

    
//    private func setupTimerSubscription() {
//        $autoFilter
//            .combineLatest(UserDefaults.standard.publisher(for: \.checkInterval))
//            .handleEvents(receiveOutput: { [weak self] isActive, interval in
//                print("[monitor-vm] timer config updated - Active: \(isActive), Interval: \(interval)s")
//            })
//            .map { isActive, interval -> AnyPublisher<Date, Never> in
//                guard isActive else {
//                    print("[monitor-vm] monitoring inactive")
//                    return Empty().eraseToAnyPublisher()
//                }
//                print("[monitor-vm] Creating new timer with interval: \(interval)s")
//                return Timer.publish(
//                    every: interval,
//                    tolerance: interval * 0.1,
//                    on: .main,
//                    in: .common
//                )
//                .autoconnect()
//                .eraseToAnyPublisher()
//            }
//            .switchToLatest()
//            .sink { [weak self] _ in
//                self?.checkAndRemoveURLIfNeeded()
//            }
//            .store(in: &cancellables)
//    }

    private func checkAndRemoveURLIfNeeded() {
        guard autoFilter else { return }

        let currentChangeCount = clipboardService.getChangeCount()

        print("[monitor-vm] [check-and-remove-url] current change count: \(currentChangeCount), last change count: \(lastChangeCount)")
        if currentChangeCount == lastChangeCount {
            let currentTime = Date()
            print("[monitor-vm] [check-and-remove-url] \(currentTime) - clipboard hasn't changed, skipping...")
            return
        }
        print("[monitor-vm] [check-and-remove-url] clipboard has changed, processing...")
                
        print("[monitor-vm] [check-and-remove-url] checking for URL and TIFF data...")
        let (hasURL, hasTIFF, urlData) = clipboardService.checkForURLAndTIFF()
        print("[monitor-vm] [check-and-remove-url] check result - URL: \(hasURL), TIFF: \(hasTIFF), URL data: \(urlData != nil)")
        
        guard hasURL && hasTIFF, let urlData = urlData else {
            print("[monitor-vm] [check-and-remove-url] no URL+TIFF combination found")
            lastChangeCount = currentChangeCount
            return
        }
        
        print("[monitor-vm] [check-and-remove-url] reading clipboard items...")
        let items = clipboardService.readClipboard()
        print("[monitor-vm] [check-and-remove-url] found \(items.count) items in clipboard")
        
        let filteredItems = items.filter { $0.data != urlData }
        print("[monitor-vm] [check-and-remove-url] filtered to \(filteredItems.count) items after removing URL data")
        
        print("[monitor-vm] [check-and-remove-url] writing filtered items back to clipboard...")
        clipboardService.writeToClipboard(filteredItems)
        print("[monitor-vm] [check-and-remove-url] successfully removed URL data from clipboard")
        DispatchQueue.main.async {
            self.lastChangeCount = self.clipboardService.getChangeCount()
        }

    }
    
}
