import Foundation

/// stdout/stderr 분리를 지원하는 콘솔 출력 유틸리티
enum Console {
    /// 성공 메시지를 stdout에 출력
    static func success(_ message: String) {
        print("✅ \(message)")
    }

    /// 정보 메시지를 stdout에 출력
    static func info(_ message: String, icon: String = "✔") {
        print("\(icon) \(message)")
    }

    /// 경고 메시지를 stderr에 출력
    static func warning(_ message: String) {
        fputs("⚠️  \(message)\n", stderr)
    }

    /// 에러 메시지를 stderr에 출력
    static func error(_ message: String) {
        fputs("❌ \(message)\n", stderr)
    }
}
