import Foundation

/// Console output utilities with stdout/stderr separation
enum Console {
    /// Outputs success message to stdout
    static func success(_ message: String) {
        print("✅ \(message)")
    }

    /// Outputs info message to stdout
    static func info(_ message: String, icon: String = "✔") {
        print("\(icon) \(message)")
    }

    /// Outputs warning message to stderr
    static func warning(_ message: String) {
        fputs("⚠️  \(message)\n", stderr)
    }

    /// Outputs error message to stderr
    static func error(_ message: String) {
        fputs("❌ \(message)\n", stderr)
    }
}
