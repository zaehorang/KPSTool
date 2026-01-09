/// Represents a problem from a specific platform
struct Problem {
    let platform: Platform
    let number: String

    var url: String {
        platform.baseURL + number
    }

    var fileName: String {
        "\(number).swift"
    }

    /// Function name for the problem solution
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
