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
    /// - BOJ: solve{number}
    /// - Programmers: solution{number}
    var functionName: String {
        switch platform {
        case .boj:
            return "solve\(number)"
        case .programmers:
            return "solution\(number)"
        }
    }
}
