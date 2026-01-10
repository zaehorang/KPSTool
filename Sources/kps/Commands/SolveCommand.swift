import ArgumentParser
import Foundation

/// 문제 풀이 완료 후 커밋 및 푸시 명령
/// Git add, commit, push를 자동으로 수행
struct SolveCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "solve",
        abstract: "문제 풀이 커밋 및 푸시"
    )

    @Argument(help: "문제 번호")
    var number: String

    @OptionGroup var platformOption: PlatformOption

    @Flag(name: .long, help: "푸시하지 않고 커밋만 수행")
    var noPush = false

    @Option(name: .shortAndLong, help: "커밋 메시지 (기본값: solve: [Platform] {number})")
    var message: String?

    func run() throws {
        // 1. 플랫폼 결정
        let platform = try platformOption.requirePlatform()

        // 2. 프로젝트 루트 찾기
        let projectRoot = try ConfigLocator.locate().get()

        // 3. 설정 로드
        let config = try KPSConfig.load(from: projectRoot.configPath)

        // 4. 파일 경로 계산
        let problem = Problem(platform: platform, number: number)
        let filePath = projectRoot.projectRoot
            .appendingPathComponent(config.sourceFolder)
            .appendingPathComponent(problem.platform.folderName)
            .appendingPathComponent(problem.fileName)

        // 5. 파일 존재 확인
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            throw KPSError.file(.notFound(filePath.path))
        }

        // 6. Git preflight check
        try GitExecutor.checkPreflight(at: projectRoot.projectRoot)

        // 7. Git add
        Console.info("Adding file to git...", icon: "📦")
        try GitExecutor.add(file: filePath, at: projectRoot.projectRoot)

        // 8. Git commit
        let commitMessage = message ?? defaultCommitMessage(for: platform, number: number)
        Console.info("Committing changes...", icon: "💾")
        let hash = try GitExecutor.commit(message: commitMessage, at: projectRoot.projectRoot)
        Console.info("Commit: \(hash)")

        // 9. Git push (--no-push가 아닐 때)
        if noPush {
            Console.success("Done! (push skipped)")
        } else {
            do {
                Console.info("Pushing to remote...", icon: "🚀")
                try GitExecutor.push(at: projectRoot.projectRoot)
                Console.success("Done!")
            } catch {
                // Push 실패 시 경고 메시지 출력
                Console.warning("Commit succeeded, but push failed.")
                Console.warning("Possible causes:")
                Console.warning("  • No remote configured: run 'git remote -v'")
                Console.warning("  • Authentication issue: check your credentials or SSH key")
                Console.warning("To complete: run 'git push' manually")
                throw error  // exit 1을 위해 에러 재전파
            }
        }
    }

    /// 기본 커밋 메시지 생성
    /// - Parameters:
    ///   - platform: 플랫폼 (BOJ, Programmers)
    ///   - number: 문제 번호
    /// - Returns: 형식: "solve: [Platform] {number}"
    private func defaultCommitMessage(for platform: Platform, number: String) -> String {
        let platformName = platform == .boj ? "BOJ" : "Programmers"
        return "solve: [\(platformName)] \(number)"
    }
}
