import Foundation
import Testing
@testable import kps

@Suite("GitExecutor Modified Files Tests")
struct GitExecutorTests {
    /// 테스트용 임시 Git 저장소 생성
    private func createTestGitRepo() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kps-test-\(UUID().uuidString)")

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // Git 저장소 초기화
        let gitInit = Process()
        gitInit.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        gitInit.arguments = ["git", "init"]
        gitInit.currentDirectoryURL = tempDir
        try gitInit.run()
        gitInit.waitUntilExit()

        // Git 사용자 설정 (로컬 저장소용)
        let gitConfig1 = Process()
        gitConfig1.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        gitConfig1.arguments = ["git", "config", "user.email", "test@example.com"]
        gitConfig1.currentDirectoryURL = tempDir
        try gitConfig1.run()
        gitConfig1.waitUntilExit()

        let gitConfig2 = Process()
        gitConfig2.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        gitConfig2.arguments = ["git", "config", "user.name", "Test User"]
        gitConfig2.currentDirectoryURL = tempDir
        try gitConfig2.run()
        gitConfig2.waitUntilExit()

        return tempDir
    }

    /// 파일 생성 헬퍼
    private func createFile(at path: String, in directory: URL, content: String = "test") throws {
        let fileURL = directory.appendingPathComponent(path)
        let dirURL = fileURL.deletingLastPathComponent()

        // 디렉토리 생성
        try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)

        // 파일 생성
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    /// 테스트 후 임시 디렉토리 삭제
    private func cleanup(_ directory: URL) {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test("getModifiedFiles should return modified files")
    func getModifiedFilesReturnsModifiedFiles() throws {
        // Given
        let tempDir = try createTestGitRepo()
        defer { cleanup(tempDir) }

        try createFile(at: "Sources/BOJ/1000.swift", in: tempDir)
        try createFile(at: "Sources/BOJ/1001.swift", in: tempDir)

        // When
        let modifiedFiles = try GitExecutor.getModifiedFiles(at: tempDir)

        // Then
        #expect(modifiedFiles.count == 2)
        #expect(modifiedFiles.contains("Sources/BOJ/1000.swift"))
        #expect(modifiedFiles.contains("Sources/BOJ/1001.swift"))
    }

    @Test("getModifiedFiles should handle empty status")
    func getModifiedFilesHandlesEmptyStatus() throws {
        // Given: Clean git repository
        let tempDir = try createTestGitRepo()
        defer { cleanup(tempDir) }

        // Create a file and commit it
        try createFile(at: "README.md", in: tempDir)

        let gitAdd = Process()
        gitAdd.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        gitAdd.arguments = ["git", "add", "."]
        gitAdd.currentDirectoryURL = tempDir
        try gitAdd.run()
        gitAdd.waitUntilExit()

        let gitCommit = Process()
        gitCommit.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        gitCommit.arguments = ["git", "commit", "-m", "Initial commit"]
        gitCommit.currentDirectoryURL = tempDir
        try gitCommit.run()
        gitCommit.waitUntilExit()

        // When: No modifications
        let modifiedFiles = try GitExecutor.getModifiedFiles(at: tempDir)

        // Then: Should return empty array
        #expect(modifiedFiles.isEmpty)
    }

    @Test("getModifiedFiles should include staged files")
    func getModifiedFilesIncludesStagedFiles() throws {
        // Given
        let tempDir = try createTestGitRepo()
        defer { cleanup(tempDir) }

        try createFile(at: "Sources/BOJ/1000.swift", in: tempDir)

        // Stage the file
        let gitAdd = Process()
        gitAdd.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        gitAdd.arguments = ["git", "add", "."]
        gitAdd.currentDirectoryURL = tempDir
        try gitAdd.run()
        gitAdd.waitUntilExit()

        // When
        let modifiedFiles = try GitExecutor.getModifiedFiles(at: tempDir)

        // Then
        #expect(modifiedFiles.contains("Sources/BOJ/1000.swift"))
    }

    @Test("getModifiedFiles should handle files in subdirectories")
    func getModifiedFilesHandlesSubdirectories() throws {
        // Given
        let tempDir = try createTestGitRepo()
        defer { cleanup(tempDir) }

        try createFile(at: "Sources/BOJ/DP/1000.swift", in: tempDir)
        try createFile(at: "Sources/Programmers/Level2/340207.swift", in: tempDir)

        // When
        let modifiedFiles = try GitExecutor.getModifiedFiles(at: tempDir)

        // Then
        #expect(modifiedFiles.contains("Sources/BOJ/DP/1000.swift"))
        #expect(modifiedFiles.contains("Sources/Programmers/Level2/340207.swift"))
    }
}
