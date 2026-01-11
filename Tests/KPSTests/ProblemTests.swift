import Foundation
import Testing
@testable import kps

@Suite("Problem File Finding Tests")
struct ProblemTests {
    /// 테스트용 임시 디렉토리 생성
    private func createTestEnvironment() throws -> (root: URL, config: KPSConfig) {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let config = KPSConfig(
            author: "TestAuthor",
            sourceFolder: "Sources",
            projectName: "TestProject"
        )

        return (tempDir, config)
    }

    @Test("findInModifiedFiles should find single match")
    func findSingleMatch() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let problem = Problem(platform: .boj, number: "1000")
        let modifiedFiles = ["Sources/BOJ/DP/1000.swift"]

        // When
        let foundPath = try problem.findInModifiedFiles(
            modifiedFiles,
            projectRoot: projectRoot,
            config: config
        )

        // Then
        #expect(foundPath.path.contains("DP/1000.swift"))
        #expect(foundPath.path.contains("Sources/BOJ"))
    }

    @Test("findInModifiedFiles should throw on multiple matches")
    func multipleMatches() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let problem = Problem(platform: .boj, number: "1000")
        let modifiedFiles = [
            "Sources/BOJ/1000.swift",
            "Sources/BOJ/DP/1000.swift"
        ]

        // When/Then
        #expect(throws: KPSError.file(.multipleFound(modifiedFiles))) {
            _ = try problem.findInModifiedFiles(
                modifiedFiles,
                projectRoot: projectRoot,
                config: config
            )
        }
    }

    @Test("findInModifiedFiles should throw on no match")
    func noMatch() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let problem = Problem(platform: .boj, number: "1000")
        let modifiedFiles = ["Sources/BOJ/2000.swift"]

        // When/Then
        #expect(throws: KPSError.self) {
            _ = try problem.findInModifiedFiles(
                modifiedFiles,
                projectRoot: projectRoot,
                config: config
            )
        }
    }

    @Test("findInModifiedFiles should only match correct platform")
    func platformFilter() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let bojProblem = Problem(platform: .boj, number: "1000")
        let modifiedFiles = ["Sources/Programmers/1000.swift"]

        // When/Then
        #expect(throws: KPSError.self) {
            _ = try bojProblem.findInModifiedFiles(
                modifiedFiles,
                projectRoot: projectRoot,
                config: config
            )
        }
    }

    @Test("findInModifiedFiles should match file in nested subdirectories")
    func nestedSubdirectories() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let problem = Problem(platform: .programmers, number: "340207")
        let modifiedFiles = ["Sources/Programmers/Level2/Hash/340207.swift"]

        // When
        let foundPath = try problem.findInModifiedFiles(
            modifiedFiles,
            projectRoot: projectRoot,
            config: config
        )

        // Then
        #expect(foundPath.path.contains("Level2/Hash/340207.swift"))
        #expect(foundPath.path.contains("Sources/Programmers"))
    }

    @Test("findInModifiedFiles should not match wrong file extension")
    func wrongFileExtension() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let problem = Problem(platform: .boj, number: "1000")
        let modifiedFiles = ["Sources/BOJ/1000.txt", "Sources/BOJ/1000.md"]

        // When/Then
        #expect(throws: KPSError.self) {
            _ = try problem.findInModifiedFiles(
                modifiedFiles,
                projectRoot: projectRoot,
                config: config
            )
        }
    }

    @Test("findInModifiedFiles should handle empty modified files list")
    func emptyModifiedFiles() throws {
        // Given
        let (projectRoot, config) = try createTestEnvironment()
        let problem = Problem(platform: .boj, number: "1000")
        let modifiedFiles: [String] = []

        // When/Then
        #expect(throws: KPSError.self) {
            _ = try problem.findInModifiedFiles(
                modifiedFiles,
                projectRoot: projectRoot,
                config: config
            )
        }
    }
}
