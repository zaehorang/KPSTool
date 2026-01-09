import Foundation

extension DateFormatter {
    /// KPS 날짜용 공유 date formatter (형식: yyyy/M/d)
    /// - 시스템 로케일과 무관하게 일관된 형식을 위해 POSIX 로케일 사용
    /// - 성능을 위한 lazy 초기화 (DateFormatter 생성은 비용이 높음)
    static let kpsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
