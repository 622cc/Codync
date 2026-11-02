import AuthenticationServices
import CodyncKit
import Foundation
@_exported import Perception

/// Standalone local account session without external ClerkKit dependency.
/// Fully compatible with iOS 16 and direct local/host pairing (spec §4.2).
@MainActor
@Perceptible
final class AccountSession {
    private(set) var isBusy = false
    var errorMessage: String?

    var showSwitcher = false

    struct Account: Identifiable {
        let id: String
        let sessionID: String
        let email: String
        let avatarURL: URL?
    }

    var userID: String? { nil }
    var accounts: [Account] { [] }
    var supportsMultipleAccounts: Bool { false }

    var isConfigured: Bool { false }
    var isReady: Bool { true }

    func waitUntilReady(timeout: Duration) async -> Bool { true }
    var restoreFailed: Bool { false }

    func retryRestore() async {}

    let cloudURL: URL? = nil
    var isSignedIn: Bool { false }
    var email: String? { nil }
    var avatarURL: URL? { nil }

    init() {}

    func sessionToken() async throws -> String {
        throw SessionError.signedOut
    }

    func cloudClient(for userID: String?, identity: DeviceIdentity?) -> CloudClient? {
        nil
    }

    enum SessionError: LocalizedError {
        case signedOut
        var errorDescription: String? { "Sign in again to reach your account." }
    }

    func signIn(provider: AnalyticsEvent.SignInProvider) async {
        errorMessage = "Cloud sign-in disabled in local TrollStore build. Pair with your computer directly via pairing URL or code."
    }

    func signOut() async {}
    func deleteUser() async throws {}
    func signOutAll() async {}
    func switchAccount(_ account: Account) async {}
    func handle(_ url: URL) async {}
}
