import Foundation
import Testing
@testable import kps

// MARK: - Test Helpers

/// 자동 정리 기능이 있는 임시 디렉토리 생성
private func withTempDirectory(_ block: (URL) throws -> Void) rethrows {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: tempDir) }
    try block(tempDir)
}

/// 지정된 경로에 config.json이 있는 KPS 설정 디렉토리 생성
private func createKPSConfig(at directory: URL) throws {
    let kpsDir = directory.appendingPathComponent(".kps")
    try FileManager.default.createDirectory(at: kpsDir, withIntermediateDirectories: true)
    let configPath = kpsDir.appendingPathComponent("config.json")
    try "{}".write(to: configPath, atomically: true, encoding: .utf8)
}

/// Result.success를 unwrap하거나 테스트 실패
private func unwrapSuccess<T>(_ result: Result<T, KPSError>) throws -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        Issue.record()
        throw error
    }
}

/// Result.failure를 unwrap하거나 테스트 실패
private func unwrapFailure<T>(_ result: Result<T, KPSError>) throws -> KPSError {
    switch result {
    case .success:
        Issue.record()
        throw KPSError.config(.notFound)
    case .failure(let error):
        return error
    }
}

// MARK: - Tests

@Test("locate should find config in current directory")
func locateFindsConfigInCurrentDirectory() throws {
    try withTempDirectory { tempDir in
        try createKPSConfig(at: tempDir)
        let result = ConfigLocator.locate(from: tempDir)
        let projectRoot = try unwrapSuccess(result)

        #expect(projectRoot.projectRoot.standardizedFileURL == tempDir.standardizedFileURL)
        #expect(projectRoot.configPath.lastPathComponent == "config.json")
        #expect(projectRoot.configPath.deletingLastPathComponent().lastPathComponent == ".kps")
    }
}

@Test("locate should find config in parent directory")
func locateFindsConfigInParentDirectory() throws {
    try withTempDirectory { tempDir in
        try createKPSConfig(at: tempDir)

        let subDir = tempDir.appendingPathComponent("subdir")
        try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)

        let result = ConfigLocator.locate(from: subDir)
        let projectRoot = try unwrapSuccess(result)

        #expect(projectRoot.projectRoot.standardizedFileURL == tempDir.standardizedFileURL)
    }
}

@Test("locate should return configNotFound when no config")
func locateReturnsConfigNotFoundWhenNoConfig() throws {
    try withTempDirectory { tempDir in
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let result = ConfigLocator.locate(from: tempDir)
        let error = try unwrapFailure(result)

        #expect(error == KPSError.config(.notFound))
    }
}

@Test("locate should return configNotFoundInGitRepo when only git exists")
func locateReturnsConfigNotFoundInGitRepoWhenOnlyGitExists() throws {
    try withTempDirectory { tempDir in
        let gitDir = tempDir.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)

        let result = ConfigLocator.locate(from: tempDir)
        let error = try unwrapFailure(result)

        #expect(error == KPSError.config(.notFoundInGitRepo))
    }
}

@Test("locate should support monorepo with parent git and child KPS")
func locateSupportsMonorepoWithParentGitAndChildKPS() throws {
    try withTempDirectory { tempDir in
        let gitDir = tempDir.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: gitDir, withIntermediateDirectories: true)

        let subProject = tempDir.appendingPathComponent("project")
        try createKPSConfig(at: subProject)

        let result = ConfigLocator.locate(from: subProject)
        let projectRoot = try unwrapSuccess(result)

        #expect(projectRoot.projectRoot.standardizedFileURL == subProject.standardizedFileURL)
    }
}

@Test("projectRoot should have correct structure")
func projectRootHasCorrectStructure() throws {
    try withTempDirectory { tempDir in
        try createKPSConfig(at: tempDir)

        let result = ConfigLocator.locate(from: tempDir)
        let projectRoot = try unwrapSuccess(result)

        #expect(projectRoot.configPath.lastPathComponent == "config.json")
        #expect(projectRoot.configPath.deletingLastPathComponent().lastPathComponent == ".kps")
        #expect(
            projectRoot.configPath.deletingLastPathComponent().deletingLastPathComponent().standardizedFileURL ==
            projectRoot.projectRoot.standardizedFileURL
        )
    }
}
