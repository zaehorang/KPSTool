import Foundation

/// KPS 프로젝트 설정 모델
struct KPSConfig: Codable {
    var author: String
    var sourceFolder: String
    var projectName: String

    /// 설정을 JSON 파일로 저장 (atomic write 사용)
    /// - Parameter url: 설정이 저장될 파일 URL
    /// - Throws: 인코딩 또는 쓰기 실패 시 KPSError.fileIOError
    func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(self)
            // Atomic write로 전체 성공 또는 전체 실패 보장
            try data.write(to: url, options: .atomic)
        } catch let error as EncodingError {
            throw KPSError.fileIOError(error)
        } catch {
            throw KPSError.fileIOError(error)
        }
    }

    /// JSON 파일에서 설정 로드
    /// - Parameter url: 설정을 읽을 파일 URL
    /// - Returns: 파싱된 KPSConfig 인스턴스
    /// - Throws: 디코딩 실패 시 KPSError.configParseError, 읽기 실패 시 KPSError.fileIOError
    static func load(from url: URL) throws -> KPSConfig {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(KPSConfig.self, from: data)
        } catch let error as DecodingError {
            // 더 나은 에러 메시지를 위해 DecodingError를 configParseError로 변환
            throw KPSError.configParseError(error.localizedDescription)
        } catch {
            throw KPSError.fileIOError(error)
        }
    }
}
