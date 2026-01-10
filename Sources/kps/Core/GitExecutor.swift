import Foundation

/// Git 명령 실행 및 사전 조건 확인
enum GitExecutor {
    /// Git 실행 가능 여부 및 저장소 상태 확인
    /// - Parameter projectRoot: 프로젝트 루트 디렉토리
    /// - Throws: Git 미설치 시 KPSError.git(.notAvailable), 저장소 아닐 시 KPSError.git(.notRepository)
    static func checkPreflight(at projectRoot: URL) throws {
        // 1. Git 실행 가능 확인
        guard isGitAvailable() else {
            throw KPSError.git(.notAvailable)
        }

        // 2. Git 저장소 확인
        guard isGitRepository(at: projectRoot) else {
            throw KPSError.git(.notRepository)
        }
    }

    /// Git이 설치되어 실행 가능한지 확인
    /// - Returns: git --version 성공 시 true
    private static func isGitAvailable() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "--version"]

        // stdout, stderr 무시
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// 현재 디렉토리가 Git 저장소인지 확인
    /// - Parameter projectRoot: 확인할 디렉토리
    /// - Returns: git rev-parse --is-inside-work-tree 성공 시 true
    private static func isGitRepository(at projectRoot: URL) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "rev-parse", "--is-inside-work-tree"]
        process.currentDirectoryURL = projectRoot

        // stdout, stderr 무시
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// 파일을 스테이징 영역에 추가
    /// - Parameters:
    ///   - filePath: 추가할 파일 경로 (절대 경로)
    ///   - projectRoot: 프로젝트 루트 디렉토리
    /// - Throws: Git 명령 실패 시 KPSError.git(.failed)
    static func add(file filePath: URL, at projectRoot: URL) throws {
        try runGit(
            arguments: ["add", "--", filePath.path],
            at: projectRoot
        )
    }

    /// 스테이징된 변경사항 커밋
    /// - Parameters:
    ///   - message: 커밋 메시지
    ///   - projectRoot: 프로젝트 루트 디렉토리
    /// - Returns: 커밋 해시 (short)
    /// - Throws: Git 명령 실패 시 KPSError.git(.failed), 변경사항 없을 시 KPSError.git(.nothingToCommit)
    static func commit(message: String, at projectRoot: URL) throws -> String {
        // 커밋 실행 시도 (2단계 방어)
        do {
            try runGit(
                arguments: ["commit", "-m", message],
                at: projectRoot
            )
        } catch let KPSError.git(.failed(stderr)) {
            // 1단계: stderr에서 "nothing to commit" 또는 "nothing added to commit" 문자열 확인
            if stderr.contains("nothing to commit") || stderr.contains("nothing added to commit") {
                // 2단계: git diff --cached로 확인
                if try isNothingToCommit(at: projectRoot) {
                    throw KPSError.git(.nothingToCommit)
                }
            }
            // 다른 에러는 그대로 전파
            throw KPSError.git(.failed(stderr))
        }

        // 커밋 해시 반환
        return try getCommitHash(at: projectRoot)
    }

    /// 원격 저장소로 푸시
    /// - Parameter projectRoot: 프로젝트 루트 디렉토리
    /// - Throws: Push 실패 시 KPSError.git(.pushFailed)
    static func push(at projectRoot: URL) throws {
        do {
            try runGit(arguments: ["push"], at: projectRoot)
        } catch let KPSError.git(.failed(stderr)) {
            throw KPSError.git(.pushFailed(stderr))
        }
    }

    /// git diff --cached로 staged 변경사항 확인
    /// - Parameter projectRoot: 프로젝트 루트 디렉토리
    /// - Returns: staged 변경사항이 없으면 true
    /// - Throws: Git 명령 실패 시 에러
    private static func isNothingToCommit(at projectRoot: URL) throws -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "diff", "--cached", "--quiet"]
        process.currentDirectoryURL = projectRoot

        process.standardOutput = Pipe()
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        // exit code 0: no differences (nothing to commit)
        // exit code 1: differences exist (something to commit)
        return process.terminationStatus == 0
    }

    /// 현재 커밋 해시 조회 (short)
    /// - Parameter projectRoot: 프로젝트 루트 디렉토리
    /// - Returns: 짧은 형식의 커밋 해시
    /// - Throws: Git 명령 실패 시 에러
    private static func getCommitHash(at projectRoot: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "rev-parse", "--short", "HEAD"]
        process.currentDirectoryURL = projectRoot

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw KPSError.git(.failed("Failed to get commit hash"))
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: outputData, encoding: .utf8) ?? ""
        return hash.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Git 명령 실행 헬퍼
    /// - Parameters:
    ///   - arguments: Git 명령 인자 배열
    ///   - projectRoot: 프로젝트 루트 디렉토리
    /// - Throws: 명령 실패 시 KPSError.git(.failed)
    private static func runGit(arguments: [String], at projectRoot: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git"] + arguments
        process.currentDirectoryURL = projectRoot

        // 에러 메시지를 영어로 받기 위해 환경변수 설정
        process.environment = ProcessInfo.processInfo.environment
        process.environment?["LANG"] = "C"
        process.environment?["LC_ALL"] = "C"

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            // stdout과 stderr 모두 읽기 (git commit은 stdout에 메시지 출력)
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let stdout = String(data: outputData, encoding: .utf8) ?? ""
            let stderr = String(data: errorData, encoding: .utf8) ?? ""
            let combinedOutput = (stdout + "\n" + stderr).trimmingCharacters(in: .whitespacesAndNewlines)
            let message = combinedOutput.isEmpty ? "Unknown error" : combinedOutput
            throw KPSError.git(.failed(message))
        }
    }
}
