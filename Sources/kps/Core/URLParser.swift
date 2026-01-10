import Foundation

/// 문제 풀이 플랫폼 URL 파싱 (BOJ, Programmers)
enum URLParser {
    /// Programmers 코딩테스트 연습 코스 ID
    /// 참고: https://school.programmers.co.kr/learn/courses/30/lessons/...
    private static let programmersCodingTestCourseID = "30"

    /// URL 문자열을 파싱하여 플랫폼과 문제 번호를 추출
    /// - Throws: 유효하지 않거나 지원하지 않는 URL인 경우 `KPSError.platform(.unsupportedURL)`
    static func parse(_ urlString: String) throws -> Problem {
        guard let url = URL(string: urlString),
              let host = url.host(percentEncoded: false) else {
            throw KPSError.platform(.unsupportedURL)
        }

        // 정규화를 위해 "www." 접두사 제거
        let normalizedHost = host.replacingOccurrences(of: "www.", with: "")
        let path = url.path

        if normalizedHost == "acmicpc.net" {
            return try parseBOJ(path: path)
        } else if normalizedHost == "boj.kr" {
            return try parseBOJShort(path: path)
        } else if normalizedHost == "school.programmers.co.kr" || normalizedHost == "programmers.co.kr" {
            return try parseProgrammers(path: path)
        } else {
            throw KPSError.platform(.unsupportedURL)
        }
    }

    /// BOJ URL 경로 파싱 (형식: /problem/{number})
    /// - Parameter path: URL 경로 구성요소
    /// - Returns: 파싱된 Problem 인스턴스
    /// - Throws: 경로 형식이 유효하지 않은 경우 KPSError.platform(.unsupportedURL)
    private static func parseBOJ(path: String) throws -> Problem {
        let components = path.split(separator: "/")

        guard components.count == 2,
              components[0] == "problem",
              !components[1].isEmpty else {
            throw KPSError.platform(.unsupportedURL)
        }

        return Problem(platform: .boj, number: String(components[1]))
    }

    /// BOJ 짧은 URL 경로 파싱 (형식: /{number})
    /// - Parameter path: URL 경로 구성요소
    /// - Returns: 파싱된 Problem 인스턴스
    /// - Throws: 경로 형식이 유효하지 않은 경우 KPSError.platform(.unsupportedURL)
    private static func parseBOJShort(path: String) throws -> Problem {
        let components = path.split(separator: "/")

        guard components.count == 1,
              !components[0].isEmpty else {
            throw KPSError.platform(.unsupportedURL)
        }

        return Problem(platform: .boj, number: String(components[0]))
    }

    /// Programmers URL 경로 파싱 (형식: /learn/courses/30/lessons/{number})
    /// - Parameter path: URL 경로 구성요소
    /// - Returns: 파싱된 Problem 인스턴스
    /// - Throws: 경로 형식이 유효하지 않은 경우 KPSError.platform(.unsupportedURL)
    private static func parseProgrammers(path: String) throws -> Problem {
        let components = path.split(separator: "/")

        guard components.count >= 4,
              components[0] == "learn",
              components[1] == "courses",
              components[2] == programmersCodingTestCourseID,
              components[3] == "lessons",
              components.count >= 5,
              !components[4].isEmpty else {
            throw KPSError.platform(.unsupportedURL)
        }

        return Problem(platform: .programmers, number: String(components[4]))
    }
}
