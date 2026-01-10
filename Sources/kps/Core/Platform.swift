/// 지원하는 문제 풀이 플랫폼
enum Platform: String, Codable {
    case boj
    case programmers

    /// 문제 페이지의 기본 URL
    var baseURL: String {
        switch self {
        case .boj:
            return "https://acmicpc.net/problem/"
        case .programmers:
            return "https://school.programmers.co.kr/learn/courses/30/lessons/"
        }
    }

    /// 프로젝트 구조에서의 폴더 이름
    var folderName: String {
        switch self {
        case .boj:
            return "BOJ"
        case .programmers:
            return "Programmers"
        }
    }

    /// 사용자에게 표시되는 플랫폼 이름
    /// (커밋 메시지, 로그 등에 사용)
    var displayName: String {
        switch self {
        case .boj:
            return "BOJ"
        case .programmers:
            return "Programmers"
        }
    }
}
