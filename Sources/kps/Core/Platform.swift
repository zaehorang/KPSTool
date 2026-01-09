/// Supported problem solving platforms
enum Platform: String, Codable {
    case boj
    case programmers

    /// Base URL for problem pages
    var baseURL: String {
        switch self {
        case .boj:
            return "https://acmicpc.net/problem/"
        case .programmers:
            return "https://school.programmers.co.kr/learn/courses/30/lessons/"
        }
    }

    /// Folder name in project structure
    var folderName: String {
        switch self {
        case .boj:
            return "BOJ"
        case .programmers:
            return "Programmers"
        }
    }
}
