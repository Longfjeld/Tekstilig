import Foundation
#if os(macOS)
import Security
#endif

// Low-level boundaries are injected so tests never invoke Security or CloudKit.
@MainActor
protocol CloudKitEnvironmentEvidenceSource {
    var supported: Bool { get }
    func copySelf() -> Int32
    func checkValidity() -> Int32
    func createTask() -> Bool
    func entitlement() -> CloudKitEnvironmentVerification.Entitlement
}

@MainActor
enum CloudKitEnvironmentVerification {
    enum Environment: String, Equatable { case development = "Development", production = "Production" }
    enum Entitlement: Equatable { case string(String), missing, invalidType(String), failure(String) }
    enum Reason: Equatable {
        case missingExpectedEnvironment, unsupportedPlatform, codeLookupFailed(Int32), signatureInvalid(Int32)
        case taskUnavailable, missingEntitlement, invalidType(String), unknownValue(String), entitlementError(String)
    }
    enum Outcome: Equatable {
        case verified(Environment)
        case unverified(Reason)
        case mismatch(expected: Environment, observed: Environment)
    }
    enum Blocked: Error { case environment(Outcome) }
    static let entitlementKey = "com.apple.developer.icloud-container-environment"

    static func evaluate(source: any CloudKitEnvironmentEvidenceSource, expected: Environment?) -> Outcome {
        guard let expected else { return .unverified(.missingExpectedEnvironment) }
        guard source.supported else { return .unverified(.unsupportedPlatform) }
        let code = source.copySelf()
        guard code == 0 else { return .unverified(.codeLookupFailed(code)) }
        let signature = source.checkValidity()
        guard signature == 0 else { return .unverified(.signatureInvalid(signature)) }
        guard source.createTask() else { return .unverified(.taskUnavailable) }
        switch source.entitlement() {
        case .string(let value):
            guard let observed = Environment(rawValue: value) else { return .unverified(.unknownValue(value)) }
            return observed == expected ? .verified(observed) : .mismatch(expected: expected, observed: observed)
        case .missing: return .unverified(.missingEntitlement)
        case .invalidType(let type): return .unverified(.invalidType(type))
        case .failure(let error): return .unverified(.entitlementError(error))
        }
    }

    static func withVerifiedEnvironment<T>(source: any CloudKitEnvironmentEvidenceSource, expected: Environment?,
        then body: (Environment) async throws -> T) async throws -> T {
        let outcome = evaluate(source: source, expected: expected)
        guard case .verified(let environment) = outcome else { throw Blocked.environment(outcome) }
        return try await body(environment)
    }
}

@MainActor
final class SystemCloudKitEnvironmentEvidenceSource: CloudKitEnvironmentEvidenceSource {
    #if os(macOS)
    private var code: SecCode?
    private var task: SecTask?
    #endif
    var supported: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }
    func copySelf() -> Int32 {
        #if os(macOS)
        let status = SecCodeCopySelf(SecCSFlags(rawValue: 0), &code)
        return status == errSecSuccess && code == nil ? errSecInternalComponent : status
        #else
        return -1
        #endif
    }
    func checkValidity() -> Int32 {
        #if os(macOS)
        guard let code else { return errSecInternalComponent }
        return SecCodeCheckValidity(code, SecCSFlags(rawValue: 0), nil)
        #else
        return -1
        #endif
    }
    func createTask() -> Bool {
        #if os(macOS)
        task = SecTaskCreateFromSelf(nil)
        return task != nil
        #else
        return false
        #endif
    }
    func entitlement() -> CloudKitEnvironmentVerification.Entitlement {
        #if os(macOS)
        guard let task else { return .failure("Task mangler") }
        var error: Unmanaged<CFError>?
        let value = SecTaskCopyValueForEntitlement(task,
            CloudKitEnvironmentVerification.entitlementKey as CFString, &error)
        if let error { return .failure(String(describing: error.takeRetainedValue())) }
        guard let value else { return .missing }
        guard CFGetTypeID(value) == CFStringGetTypeID(), let string = value as? String else {
            return .invalidType(String(reflecting: type(of: value)))
        }
        return .string(string)
        #else
        return .failure("Plattform uten offentlig etablert miljøleser")
        #endif
    }
}
