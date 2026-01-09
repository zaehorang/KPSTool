import Foundation

/// KPS 프로젝트 설정 모델
struct KPSConfig: Codable {
    var author: String
    var sourceFolder: String
    var projectName: String

    /// 설정을 JSON 파일로 저장 (atomic write 사용)
    /// - Parameter url: 설정이 저장될 파일의 URL
    /// - Throws: 인코딩 또는 쓰기 실패 시 KPSError.file(.ioError)
    func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(self)
            // Atomic write는 전체 성공 또는 전체 실패를 보장
            try data.write(to: url, options: .atomic)
        } catch let error as EncodingError {
            throw KPSError.file(.ioError(error))
        } catch {
            throw KPSError.file(.ioError(error))
        }
    }

    /// JSON 파일에서 설정 로드
    /// - Parameter url: 설정을 읽을 파일의 URL
    /// - Returns: 파싱된 KPSConfig 인스턴스
    /// - Throws: 디코딩 실패 시 KPSError.config(.parseError), 읽기 실패 시 KPSError.file(.ioError)
    static func load(from url: URL) throws -> KPSConfig {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(KPSConfig.self, from: data)
        } catch let error as DecodingError {
            // 더 나은 에러 메시지를 위해 DecodingError를 config parse error로 변환
            throw KPSError.config(.parseError(error.localizedDescription))
        } catch {
            throw KPSError.file(.ioError(error))
        }
    }
}
