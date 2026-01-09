import Testing
@testable import kps

// MARK: - BOJ Tests

/// BOJ URL 파싱용 테스트 데이터 (url, expectedNumber)
private let bojTestCases: [(String, String)] = [
    ("https://acmicpc.net/problem/1000", "1000"),
    ("https://www.acmicpc.net/problem/1000", "1000"),
    ("http://acmicpc.net/problem/1000", "1000"),
    ("https://boj.kr/1000", "1000")
]

@Test("parse should correctly parse BOJ URLs", arguments: bojTestCases)
func parseBOJURLs(url: String, expectedNumber: String) throws {
    let problem = try URLParser.parse(url)
    #expect(problem.number == expectedNumber)
    #expect(problem.platform == .boj)
}

// MARK: - Programmers Tests

/// Programmers URL 파싱용 테스트 데이터 (url, expectedNumber)
private let programmersTestCases: [(String, String)] = [
    ("https://school.programmers.co.kr/learn/courses/30/lessons/340207", "340207"),
    ("https://programmers.co.kr/learn/courses/30/lessons/340207", "340207"),
    ("https://www.programmers.co.kr/learn/courses/30/lessons/340207", "340207")
]

@Test("parse should correctly parse Programmers URLs", arguments: programmersTestCases)
func parseProgrammersURLs(url: String, expectedNumber: String) throws {
    let problem = try URLParser.parse(url)
    #expect(problem.number == expectedNumber)
    #expect(problem.platform == .programmers)
}

// MARK: - URL Normalization Tests

/// URL 정규화용 테스트 데이터 (url, expectedNumber, expectedPlatform)
private let normalizationTestCases: [(String, String, Platform)] = [
    ("https://school.programmers.co.kr/learn/courses/30/lessons/340207?itm_content=detail", "340207", .programmers),
    ("https://acmicpc.net/problem/1000#section", "1000", .boj)
]

@Test("parse should ignore query strings and fragments", arguments: normalizationTestCases)
func parseNormalizesURLs(url: String, expectedNumber: String, expectedPlatform: Platform) throws {
    let problem = try URLParser.parse(url)
    #expect(problem.number == expectedNumber)
    #expect(problem.platform == expectedPlatform)
}

// MARK: - Error Tests

/// unsupportedURL 에러를 발생시켜야 하는 유효하지 않은 URL 테스트 데이터
private let invalidURLTestCases = [
    "https://leetcode.com/problems/two-sum",
    "https://acmicpc.net/submit/1000",
    "https://acmicpc.net/problem/"
]

@Test("parse should throw unsupportedURL for invalid URLs", arguments: invalidURLTestCases)
func parseThrowsUnsupportedURL(url: String) {
    #expect(throws: KPSError.platform(.unsupportedURL)) {
        try URLParser.parse(url)
    }
}
