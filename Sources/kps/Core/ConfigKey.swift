/// KPS 프로젝트 설정 키
enum ConfigKey: String, CaseIterable {
    case author
    case sourceFolder
    case projectName
    case xcodeProjectPath

    var description: String {
        switch self {
        case .author:
            return "파일 헤더에 사용될 작성자 이름"
        case .sourceFolder:
            return "소스 폴더 경로 (예: 'Sources')"
        case .projectName:
            return "프로젝트 이름"
        case .xcodeProjectPath:
            return "Xcode 프로젝트 경로 (예: 'AlgorithmStudy.xcodeproj')"
        }
    }

    /// 문자열을 ConfigKey로 변환
    /// - Parameter string: 설정 키 문자열
    /// - Returns: ConfigKey 인스턴스
    /// - Throws: 유효하지 않은 키인 경우 KPSError.config(.invalidKey)
    static func from(_ string: String) throws -> ConfigKey {
        guard let key = ConfigKey(rawValue: string) else {
            throw KPSError.config(.invalidKey(string))
        }
        return key
    }
}
