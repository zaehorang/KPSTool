import Foundation

/// 특정 플랫폼의 문제를 나타냄
struct Problem {
    let platform: Platform
    let number: String

    var url: String {
        platform.baseURL + number
    }

    var fileName: String {
        "\(number).swift"
    }

    /// 문제 풀이 함수 이름
    /// - _{number}
    var functionName: String { "_\(number)" }

    /// 파일의 전체 경로 계산
    /// - Parameters:
    ///   - projectRoot: 프로젝트 루트 디렉토리
    ///   - config: 프로젝트 설정 (sourceFolder 정보 포함)
    /// - Returns: 문제 파일의 전체 경로
    func filePath(projectRoot: URL, config: KPSConfig) -> URL {
        projectRoot
            .appendingPathComponent(config.sourceFolder)
            .appendingPathComponent(platform.folderName)
            .appendingPathComponent(fileName)
    }

    /// 파일이 위치할 소스 디렉토리 경로
    /// - Parameters:
    ///   - projectRoot: 프로젝트 루트 디렉토리
    ///   - config: 프로젝트 설정 (sourceFolder 정보 포함)
    /// - Returns: 플랫폼별 소스 디렉토리 경로
    func sourceDirectory(projectRoot: URL, config: KPSConfig) -> URL {
        projectRoot
            .appendingPathComponent(config.sourceFolder)
            .appendingPathComponent(platform.folderName)
    }

    /// 변경된 파일 목록에서 문제 번호와 플랫폼에 맞는 파일 찾기
    /// - Parameters:
    ///   - modifiedFiles: git status로 가져온 변경된 파일 경로 배열
    ///   - projectRoot: 프로젝트 루트 디렉토리
    ///   - config: 프로젝트 설정 (sourceFolder 정보 포함)
    /// - Returns: 발견된 파일의 전체 경로
    /// - Throws:
    ///   - KPSError.file(.notFound): 매칭되는 파일이 없을 때
    ///   - KPSError.file(.multipleFound): 매칭되는 파일이 여러 개일 때
    func findInModifiedFiles(
        _ modifiedFiles: [String],
        projectRoot: URL,
        config: KPSConfig
    ) throws -> URL {
        // 1. 필터링 조건:
        //    - 파일명이 {number}.swift로 끝나야 함
        //    - 경로에 플랫폼 폴더명이 포함되어야 함
        let matches = modifiedFiles.filter { filePath in
            filePath.hasSuffix(fileName) &&
            filePath.contains("/\(platform.folderName)/")
        }

        // 2. 매칭 결과에 따라 처리
        switch matches.count {
        case 0:
            // 매칭되는 파일이 없음
            let standardPath = filePath(projectRoot: projectRoot, config: config)
            throw KPSError.file(.notFound(standardPath.path))

        case 1:
            // 정확히 하나의 파일 발견
            let relativePath = matches[0]
            return projectRoot.appendingPathComponent(relativePath)

        default:
            // 여러 파일 발견 (중복)
            throw KPSError.file(.multipleFound(matches))
        }
    }
}
