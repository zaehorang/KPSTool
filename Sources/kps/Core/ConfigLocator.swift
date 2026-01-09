import Foundation

/// KPS 프로젝트의 루트 디렉토리를 나타냄
struct ProjectRoot {
    let projectRoot: URL

    var configPath: URL {
        projectRoot.appendingPathComponent(".kps").appendingPathComponent("config.json")
    }
}

/// `.kps/config.json`을 찾아 KPS 프로젝트 루트 디렉토리를 탐색
enum ConfigLocator {
    /// 시작 경로에서 상위로 탐색하여 KPS 설정을 검색
    /// - Parameter startingPath: 검색을 시작할 디렉토리 (기본값: 현재 디렉토리)
    /// - Returns: 성공 시 `ProjectRoot`를 포함하는 Result, 또는 git 저장소 발견 여부를 나타내는 에러
    static func locate(
        from startingPath: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    ) -> Result<ProjectRoot, KPSError> {
        var currentPath = startingPath.standardizedFileURL
        var gitRepoDetected = false

        // config를 찾거나 파일시스템 루트에 도달할 때까지 상위로 탐색
        while currentPath.path != "/" {
            let kpsPath = currentPath.appendingPathComponent(".kps")
            let configPath = kpsPath.appendingPathComponent("config.json")

            if FileManager.default.fileExists(atPath: configPath.path) {
                return .success(ProjectRoot(projectRoot: currentPath))
            }

            // 더 나은 에러 메시지를 위해 git 저장소 추적 (monorepo 지원)
            let gitPath = currentPath.appendingPathComponent(".git")
            if FileManager.default.fileExists(atPath: gitPath.path) {
                gitRepoDetected = true
            }

            let parent = currentPath.deletingLastPathComponent().standardizedFileURL
            if parent.path == currentPath.path {
                break
            }
            currentPath = parent
        }

        // git 저장소 발견 여부에 따라 에러 구분
        if gitRepoDetected {
            return .failure(.config(.notFoundInGitRepo))
        } else {
            return .failure(.config(.notFound))
        }
    }
}
