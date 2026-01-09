/// 지원하는 문제 풀이 플랫폼
enum Platform: String, Codable {
    case boj
    case programmers

    /// 문제 페이지 기본 URL
    var baseURL: String {
        switch self {
        case .boj:
            return "https://acmicpc.net/problem/"
        case .programmers:
            return "https://school.programmers.co.kr/learn/courses/30/lessons/"
        }
    }

    /// 프로젝트 구조 내 폴더 이름
    var folderName: String {
        switch self {
        case .boj:
            return "BOJ"
        case .programmers:
            return "Programmers"
        }
    }
}
