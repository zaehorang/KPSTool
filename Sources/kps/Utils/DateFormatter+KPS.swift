import Foundation

extension DateFormatter {
    /// Shared date formatter for KPS dates (format: yyyy/M/d)
    /// - Uses POSIX locale for consistent formatting regardless of system locale
    /// - Lazy-initialized for performance (DateFormatter creation is expensive)
    static let kpsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
