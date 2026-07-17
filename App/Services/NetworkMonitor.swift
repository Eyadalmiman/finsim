import Combine
import Foundation
import Network

/// Observes the device's network path so views can lock online-only
/// features (AI Coach, social sign-in) while the user is offline.
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.eyad.FinSim.NetworkMonitor"))
    }
}
