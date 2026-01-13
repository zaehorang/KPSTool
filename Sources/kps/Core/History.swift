import Foundation

/// 문제 풀이 히스토리의 단일 항목
struct HistoryEntry: Codable, Equatable {
    let problemNumber: String
    let platform: Platform
    let filePath: String  // relative to project root
    let timestamp: Date
}

/// KPS 문제 풀이 히스토리 관리자
/// .kps/history.json 파일에 문제 생성 기록을 저장
struct KPSHistory: Codable {
    private(set) var entries: [HistoryEntry]

    /// 빈 히스토리 또는 기존 항목으로 초기화
    /// - Parameter entries: 초기 항목 배열 (기본값: 빈 배열)
    init(entries: [HistoryEntry] = []) {
        self.entries = entries
    }

    /// 새 항목을 히스토리에 추가 (배열 끝에 append)
    /// - Parameter entry: 추가할 히스토리 항목
    mutating func addEntry(_ entry: HistoryEntry) {
        entries.append(entry)
    }

    /// 가장 최근 항목 반환
    /// - Returns: 가장 최근 항목 (배열의 마지막), 히스토리가 비어있으면 nil
    func mostRecent() -> HistoryEntry? {
        entries.last
    }

    /// 히스토리를 JSON 파일로 저장
    /// - Parameter url: 저장할 파일 경로
    /// - Throws: 인코딩 또는 쓰기 실패 시 KPSError.file(.ioError)
    func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(self)
            // Atomic write: 전체 성공 또는 전체 실패 보장
            try data.write(to: url, options: .atomic)
        } catch {
            throw KPSError.file(.ioError(error))
        }
    }

    /// JSON 파일에서 히스토리 로드
    /// - Parameter url: 로드할 파일 경로
    /// - Returns: 파싱된 KPSHistory 인스턴스
    /// - Throws: 디코딩 또는 읽기 실패 시 KPSError.file(.ioError)
    static func load(from url: URL) throws -> KPSHistory {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(KPSHistory.self, from: data)
        } catch {
            throw KPSError.file(.ioError(error))
        }
    }
}
