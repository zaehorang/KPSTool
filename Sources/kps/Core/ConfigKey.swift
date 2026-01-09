/// KPS 프로젝트 설정 키
enum ConfigKey: String, CaseIterable {
    case author
    case sourceFolder
    case projectName

    var description: String {
        switch self {
        case .author:
            return "파일 헤더에 사용될 작성자 이름"
        case .sourceFolder:
            return "소스 폴더 경로 (예: 'Sources')"
        case .projectName:
            return "프로젝트 이름"
        }
    }
}
