# KPS Development TODO v4

## Week 1: 기반 구축

### Day 1-2: 프로젝트 셋업
- [x] SPM 프로젝트 생성
  - [x] `Package.swift` 작성
  - [x] `// swift-tools-version:5.9` 주석 확인
  - [x] ArgumentParser 의존성 추가
  - [x] 폴더 구조 생성 (Commands, Core, Utils)
- [x] `main.swift` 엔트리포인트 작성
  - [x] `CommandConfiguration(version: "0.1.0")`으로 `--version` 지원

### Day 3: Config 모델
- [x] `Config.swift`
  - [x] KPSConfig struct 정의
  - [x] JSON 인코딩/디코딩
  - [x] 파일 저장 (`save(to:)`)
    - [x] **atomic write 사용**: `data.write(to:options: .atomic)`
  - [x] 파일 로드 (`load(from:)`)
    - [x] **JSON 디코딩 실패 시 적절한 KPSError 반환** ⭐
- [x] `ConfigKey.swift`
  - [x] enum 정의 (author, sourceFolder, projectName)
  - [x] description 프로퍼티
- [x] `ConfigLocator.swift`
  - [x] 현재 경로부터 상위로 `.kps/config.json` 탐색
  - [x] **반환 타입**: `Result<ProjectRoot, KPSError>`
    - [x] `ProjectRoot` 구조체 정의:
      - [x] `projectRoot: URL` - .kps 디렉토리가 존재하는 프로젝트 루트
      - [x] `configPath: URL` - projectRoot/.kps/config.json
      - [x] **관계 보장**: configPath는 projectRoot로부터 **계산된 경로**로 생성 ⭐
      - [x] Locator는 "탐색 결과의 기준 루트"만 책임지고, 경로 관계는 구조적으로 보장
    - [x] 실패 시 에러 타입으로 이유 전달 (Command에서 분기 불필요)
  - [x] **탐색 정책**
    - [x] `.kps/config.json` 발견 → `.success(ProjectRoot(projectRoot: ...))`
    - [x] `.git` 발견 → `gitRepoDetected = true` 플래그 설정, **탐색 계속**
    - [x] 루트(`/`) 도달 → 실패
  - [x] **최종 실패 시 에러 분기**
    - [x] `gitRepoDetected == true` → `.failure(.configNotFoundInGitRepo)`
    - [x] `gitRepoDetected == false` → `.failure(.configNotFound)`
  - [x] **책임 범위 명확화** ⭐
    - [x] ConfigLocator는 **파일 존재 및 경로 탐색만 담당**
    - [x] JSON 파싱/형식 오류는 `Config.load(from:)` 단계에서 처리
  - [x] 모노레포 지원: 상위 .git과 하위 .kps 모두 탐색

### Day 4: Platform & Problem 모델
- [x] `Platform.swift`
  - [x] enum 정의 (boj, programmers)
  - [x] baseURL 프로퍼티
    - [x] BOJ: `https://acmicpc.net/problem/`
    - [x] Programmers: `https://school.programmers.co.kr/learn/courses/30/lessons/` ⭐
  - [x] folderName 프로퍼티
- [x] Problem struct 정의
  - [x] url computed property
  - [x] fileName computed property
  - [x] functionName computed property

### Day 5: URLParser
- [x] `URLParser.swift`
  - [x] URL 정규화 (scheme, host, path 분리)
  - [x] www 접두사 처리
  - [x] http/https 모두 지원
  - [x] query string 무시
  - [x] fragment 무시
  - [x] BOJ URL 파싱 (`acmicpc.net/problem/{n}`)
  - [x] BOJ 단축 URL 파싱 (`boj.kr/{n}`)
  - [x] **Programmers URL 파싱** ⭐
    - [x] `school.programmers.co.kr/.../lessons/{n}` (canonical)
    - [x] `programmers.co.kr/.../lessons/{n}` (구버전 호환)
  - [x] 잘못된 URL 에러 처리

### Day 6: Utils
- [x] `Console.swift`
  - [x] **출력 레벨 정의** ⭐
    - [x] success (`✅`) → stdout
    - [x] info (`✔`, `📦`, `💾`, `🚀`, `🔗`, `💡`) → stdout
    - [x] warning (`⚠️`) → **stderr**
    - [x] error (`❌`) → **stderr**
  - [x] stdout/stderr 분리 구현
- [x] `DateFormatter.swift`
  - [x] yyyy/M/d 포맷
  - [x] **Locale 고정**: `Locale(identifier: "en_US_POSIX")` ⭐
  - [x] **TimeZone**: `TimeZone.current` (local time)

### Day 7: Week 1 테스트
- [x] `URLParserTests.swift`
  - [x] **BOJ URL 파싱 테스트**
    - [x] `https://acmicpc.net/problem/1000`
    - [x] `https://www.acmicpc.net/problem/1000` (www 접두사)
    - [x] `http://acmicpc.net/problem/1000` (http)
  - [x] **BOJ 단축 URL 테스트**
    - [x] `https://boj.kr/1000`
  - [x] **Programmers URL 파싱 테스트** ⭐
    - [x] `https://school.programmers.co.kr/learn/courses/30/lessons/340207` (canonical)
    - [x] `https://programmers.co.kr/learn/courses/30/lessons/340207` (구버전 호환)
    - [x] `https://www.programmers.co.kr/learn/courses/30/lessons/340207` (www 접두사)
  - [x] **URL 정규화 테스트**
    - [x] query string 포함 URL (`?itm_content=...`)
    - [x] fragment 포함 URL (`#section`)
  - [x] **에러 케이스 테스트**
    - [x] 지원하지 않는 도메인 (`leetcode.com`)
    - [x] 잘못된 경로 (`acmicpc.net/submit/1000`)
    - [x] 문제 번호 없음 (`acmicpc.net/problem/`)
- [x] `ConfigTests.swift`
  - [x] JSON 인코딩 테스트
  - [x] JSON 디코딩 테스트
  - [x] 파일 저장/로드 테스트
  - [x] ConfigKey 검증 테스트
- [x] `ConfigLocatorTests.swift`
  - [x] 현재 디렉토리에 config 있을 때 → `.success(ProjectRoot(...))`
  - [x] 상위 디렉토리에 config 있을 때 → `.success(ProjectRoot(...))`
  - [x] config 없을 때 (.git도 없음) → `.failure(.configNotFound)`
  - [x] .git만 있고 .kps 없을 때 → `.failure(.configNotFoundInGitRepo)`
  - [x] 모노레포: 상위 .git, 하위 .kps 있을 때 → `.success(ProjectRoot(...))`
  - [x] **ProjectRoot 구조 검증 (standardizedFileURL 기반)** ⭐
    - [x] `configPath.lastPathComponent == "config.json"`
    - [x] `configPath.deletingLastPathComponent().lastPathComponent == ".kps"`
    - [x] `configPath.deletingLastPathComponent().deletingLastPathComponent().standardizedFileURL == projectRoot.standardizedFileURL`

### ✅ Week 1 완료 조건
- [x] URLParser가 다양한 형식의 BOJ, Programmers URL을 정확히 파싱
- [x] **URLParser가 `school.programmers.co.kr`과 `programmers.co.kr` 둘 다 허용** ⭐
- [x] ConfigLocator가 하위 폴더에서도 프로젝트 루트를 찾음
- [x] ConfigLocator가 모노레포 구조에서도 정상 동작
- [x] ConfigLocator가 .git만 있는 경우 적절한 메시지 제공
- [x] Config JSON 저장/로드 동작 확인
- [x] 모든 단위 테스트 통과 (22/22)

### Day 8: 코드 품질 & 스타일 가이드 (2026-01-09)
- [x] **Swift Style Guide 문서화**
  - [x] `docs/SWIFT_STYLE_GUIDE.md` 생성 (StyleShare 기반)
  - [x] 코드 레이아웃, 네이밍, 클로저, 타입 규칙 정의
  - [x] Access Control, 에러 처리, Concurrency 가이드
- [x] **SwiftLint 통합**
  - [x] `.swiftlint.yml` 설정 (120자 제한, custom rules)
  - [x] SPM Plugin으로 통합 (`SwiftLintBuildToolPlugin`)
  - [x] `swift build` 시 자동 lint 실행 설정
  - [x] 위반 시 빌드 중단 (error) / 경고 (warning)
- [x] **Agent 기반 코드 리뷰**
  - [x] 11개 Swift 파일 의미적 분석
  - [x] 문서화 주석 개선 (parameter/return/throws 명세)
  - [x] High/Medium/Low 우선순위 제안
- [x] **문서화 개선**
  - [x] URLParser helper 메서드 문서화 완성
  - [x] Config save/load 메서드 문서화 완성
  - [x] ConfigLocator locate 메서드 문서화 완성
  - [x] ConfigKey enum 문서화 추가
- [x] **커밋 컨벤션 정립**
  - [x] `docs/COMMIT_Convention.md` 추가 (Conventional Commits 기반)
  - [x] `docs/COMMIT_PLAN.md` 제거 (중복)
- [x] **CLAUDE.md 업데이트**
  - [x] SwiftLint 사용 가이드 추가
  - [x] 자동/수동 실행 방법 문서화
  - [x] CI/CD 통합 안내

**완료 커밋:**
- `ec59194` - refactor: apply Swift style guide
- `a8ed195` - chore: integrate SwiftLint via SPM plugin
- `919ddb0` - docs: update commit convention documentation

**검증 결과:**
- SwiftLint: 0 violations ✅
- Build: Success ✅
- Tests: 22/22 passed ✅
- Auto-lint on build: Working ✅

---

## Week 2: 명령어 구현

### Day 1: 에러 시스템
- [x] `KPSError.swift`
  - [x] configNotFound
  - [x] configNotFoundInGitRepo (특별 케이스)
  - [x] configParseError ⭐ (JSON 디코딩 실패)
  - [x] configAlreadyExists
  - [x] unsupportedURL
  - [x] invalidProblemNumber
  - [x] platformRequired
  - [x] conflictingPlatformFlags
  - [x] urlWithPlatformFlag (URL + 플래그 동시 사용)
  - [x] invalidConfigKey
  - [x] fileAlreadyExists
  - [x] fileNotFound
  - [x] gitNotAvailable (설치 안 됨 or 실행 불가)
  - [x] notGitRepository
  - [x] nothingToCommit (변경사항 없음)
  - [x] gitFailed
  - [x] gitPushFailed
  - [x] permissionDenied
  - [x] fileIOError (generic fallback)
- [x] **NSError 매핑 정책**
  - [x] `NSFileWriteNoPermissionError` → permissionDenied
  - [x] `NSFileReadNoPermissionError` → permissionDenied
  - [x] 그 외 → fileIOError
- [x] Console 에러 출력 포맷 연동
- [x] 모든 에러에 해결 힌트 포함
- [x] **unsupportedURL 메시지**: `Supported: acmicpc.net, school.programmers.co.kr` ⭐

### Day 2: PlatformOption & kps init
- [x] `PlatformOption.swift` ⭐
  - [x] OptionGroup으로 -b/-p 플래그 정의
  - [x] `resolve()` → `Platform?` (충돌 시 에러)
  - [x] `requirePlatform()` → `Platform` (없으면 에러)
- [x] `InitCommand.swift`
  - [x] ArgumentParser 설정 (--author, --source, --force)
  - [x] 현재 디렉토리에서 projectName 추출
  - [x] `.kps` 디렉토리 생성
  - [x] `config.json` 저장
  - [x] 기존 설정 존재 시 처리 (--force)
  - [x] 쓰기 권한 실패 처리
  - [x] 성공 메시지 출력
  - [x] **git repo 여부 체크 안 함** ⭐ (init은 git 없이도 동작)

### Day 3-4: kps new
- [x] `Template.swift`
  - [x] Swift 파일 템플릿 정의
  - [x] 변수 치환 로직 ({number}, {projectName}, {author}, {date}, {url})
- [x] `FileManager+KPS.swift`
  - [x] 디렉토리 생성
  - [x] 파일 존재 확인
  - [x] 파일 쓰기
  - [x] NSError → KPSError 매핑
- [x] `NewCommand.swift`
  - [x] ArgumentParser 설정 (input, --boj, --programmers)
  - [x] **입력 분기 로직 (에러 삼킴 방지)** ⭐
    - [x] `looksLikeURL()` 헬퍼로 URL 형태 여부 판단
    - [x] URL 형태면 `try URLParser.parse()` (`try?` 사용 금지)
    - [x] URL이 아니면 번호 + 플래그 플로우
  - [x] **입력 규칙 처리**
    - [x] 번호만 입력 (플래그 없음) → `platformRequired`
    - [x] `-b -p` 둘 다 → `conflictingPlatformFlags`
    - [x] URL + 플래그 → `urlWithPlatformFlag` 에러
  - [x] ConfigLocator로 프로젝트 루트 찾기
  - [x] 파일 경로 계산
  - [x] 템플릿으로 파일 생성
  - [x] 성공 메시지 + 링크 출력
  - [x] **다음 행동 가이드 출력** ⭐ (`💡 Next: solve with 'kps solve 1000 -b'`)

### Day 5: kps config
- [x] `ConfigCommand.swift`
  - [x] ArgumentParser 설정 (key?, value?)
  - [x] ConfigLocator로 config 찾기
  - [x] 전체 조회 (인자 0개)
  - [x] 특정 값 조회 (인자 1개)
  - [x] 값 수정 (인자 2개)
  - [x] ConfigKey 검증
  - [x] 잘못된 키 에러 메시지
  - [x] **git repo 여부 체크 안 함** ⭐

### Day 6: Week 2 테스트 & 정리
- [x] `TemplateTests.swift`
  - [x] 변수 치환 테스트
  - [x] 날짜 포맷 테스트
  - [x] **Programmers URL이 `school.programmers.co.kr`로 출력되는지 확인** ⭐
- [x] 에러 메시지 문구 다듬기
- [x] Smoke test: init → new 워크플로우
- [x] 플래그 충돌 테스트 ⭐
- [x] URL + 플래그 에러 테스트 ⭐
- [x] **looksLikeURL 분기 테스트** ⭐
  - [x] URL 형태 + 잘못된 도메인 → unsupportedURL 에러 (not platformRequired)

### ✅ Week 2 완료 조건
- [x] `kps init` → `kps new` 워크플로우 동작 (git 없이도)
- [x] 하위 폴더에서 `kps new` 실행해도 정상 동작
- [x] URL과 번호+플래그 두 방식 모두 동작
- [x] 플래그 충돌 / URL+플래그 시 명확한 에러 메시지
- [x] **잘못된 URL 입력 시 unsupportedURL 에러 (platformRequired 아님)** ⭐
- [x] `kps new` 성공 후 다음 행동 가이드 출력
- [x] 모든 에러 케이스에서 친절한 메시지 출력

---

## Week 3: Git 연동 및 릴리즈

### Day 1: Git 사전 조건 체크
- [x] `GitExecutor.swift` - preflight checks
  - [x] **git 실행 가능 확인**: `git --version` 실행 성공 여부 ⭐
  - [x] git repo 확인: `git rev-parse --is-inside-work-tree`
  - [x] 실패 시 친절한 에러 메시지
    - [x] `gitNotAvailable`: "Git is not installed or not in PATH. Install: https://git-scm.com/downloads"
    - [x] `notGitRepository`: "Not a git repository. Run 'git init' first."

### Day 2: Git 명령 실행
- [x] `GitExecutor.swift` - commands
  - [x] Process로 git 명령 실행
  - [x] **working directory를 projectRoot로 고정** ⭐
    - [x] `Process.currentDirectoryURL = projectRoot`
    - [x] 모든 git 명령(add, commit, push, status)에 동일 적용
  - [x] **arguments 배열로 전달 (shell 문자열 금지)**
  - [x] **`--` 사용으로 옵션 파싱 종료**
    - [x] `git add -- <filePath>` 형태
    - [x] 공백/특수문자/대시 파일명 안전 처리
  - [x] **commit message도 arguments로 전달 (따옴표/특수문자 안전)**
  - [x] **커밋 메시지 기본값** ⭐
    - [x] 형식: `solve: [Platform] {number}`
    - [x] 예시: `solve: [BOJ] 1000`
  - [x] 종료 코드 확인
  - [x] stderr 캡처
  - [x] `add(file:)` 메서드
  - [x] `commit(message:)` 메서드
    - [x] **성공 시 commit hash 반환** (`git rev-parse --short HEAD`)
    - [x] commit hash는 **stdout(info)** 레벨로 출력 ⭐
  - [x] `push()` 메서드
  - [x] `status()` 메서드 (`git status --porcelain` - nothing to commit 판별용)

### Day 3: kps solve
- [x] `SolveCommand.swift`
  - [x] ArgumentParser 설정 (number, --boj, --programmers, --no-push, --message)
  - [x] ConfigLocator로 프로젝트 루트 찾기 (Result 타입 처리)
  - [x] 파일 존재 확인
  - [x] **Git preflight check 실행** (solve에서만)
  - [x] git add 실행
  - [x] git commit 실행
  - [x] **commit 성공 시 hash 출력**: `✔ Commit: a1b2c3d`
  - [x] git push 실행 (--no-push가 아닐 때)
  - [x] 단계별 출력 메시지
  - [x] **성공 메시지 분기** ⭐
    - [x] push 포함 완전 성공: `✅ Done!`
    - [x] `--no-push` 성공: `✅ Done! (push skipped)` + exit 0
  - [x] **push 실패 시 상세 힌트 제공**
    - [x] `⚠️ Commit succeeded, but push failed.`
    - [x] `Possible causes:`
    - [x] `  • No remote configured: run 'git remote -v'`
    - [x] `  • Authentication issue: check your credentials or SSH key` ⭐
    - [x] `To complete: run 'git push' manually`
    - [x] exit code 1 (Done! 없음)

### Day 4: Git 실패 처리 & 테스트
- [ ] add 실패 → 에러 + exit 1
- [ ] commit 실패 → 에러 + exit 1
  - [ ] **"nothing to commit" 감지 (2단계 방어)** ⭐
    - [ ] 1차: stderr에서 "nothing to commit" 문자열 확인
    - [ ] 2차: `git status --porcelain` 결과가 비어있는지 확인
    - [ ] 비어 있으면 → `nothingToCommit` 확정
    - [ ] 비어 있지 않으면 → 일반 `gitFailed`
    - [ ] 메시지: `No changes to commit. Did you save your solution file?`
- [ ] push 실패 → 경고 메시지 (stderr) + remote 힌트 + exit 1
- [ ] Smoke test: solve 전체 흐름
- [ ] Git 미설치/실행불가 환경 테스트
- [ ] Non-git 디렉토리 테스트
- [ ] 파일명에 공백/특수문자 테스트
- [ ] 파일 수정 없이 solve 실행 테스트
- [ ] commit message에 특수문자 포함 테스트
- [ ] commit hash 출력 확인

### Day 5: README & 문서
- [x] `README.md` 작성
  - [x] 프로젝트 소개 (한 줄 설명)
  - [x] 설치 방법
  - [x] Quick Start (3분 내 완료 가능)
  - [x] **지원 플랫폼 명시** ⭐
    - [x] BOJ (acmicpc.net, boj.kr)
    - [x] Programmers (school.programmers.co.kr)
  - [x] **생성되는 폴더 구조 예시** ⭐
    ```
    YourProject/
    ├── .kps/
    │   └── config.json
    └── Sources/
        ├── BOJ/
        │   └── 1000.swift
        └── Programmers/
            └── 340207.swift
    ```
  - [x] 명령어 레퍼런스
  - [x] **Exit Code 정책**
    ```
    Exit codes:
      0 - Success
      1 - Failure (including push failure)
    ```
- [x] `LICENSE` 파일 추가 (MIT)

### Day 6-7: 릴리즈
- [ ] 최종 테스트
  - [ ] 새 디렉토리에서 전체 워크플로우 테스트
  - [ ] 하위 폴더에서 명령 실행 테스트
  - [ ] git 없는 환경에서 init/new/config 동작 확인 ⭐
  - [ ] 모든 에러 케이스 확인
  - [ ] Git 실패 시나리오 테스트
  - [ ] 파일명 공백/특수문자 테스트
  - [ ] **Programmers URL 테스트 (school. / 구버전 둘 다)** ⭐
- [ ] GitHub 릴리즈
  - [ ] v0.1.0 태그 생성
  - [ ] Release notes 작성
  - [ ] 바이너리 첨부 (optional)

### ✅ Week 3 완료 조건
- [ ] Git preflight check가 미설치/non-repo 상황에서 친절한 안내 제공
- [ ] init/new/config가 git 없이도 정상 동작
- [ ] `kps solve`가 모든 Git 실패 케이스에서 적절한 에러/경고 반환
- [ ] `--no-push` 성공 시 `Done! (push skipped)` 메시지 출력
- [ ] push 실패 시 exit code 1 + remote 힌트 (Done! 없음)
- [ ] 파일명 공백/특수문자에서도 git 명령 정상 동작
- [ ] README에 폴더 구조 예시 포함
- [ ] README에 설치 → 첫 사용까지 3분 내 완료 가능한 가이드 포함

---

## 릴리즈 체크리스트

### v0.1.0 출시 전 최종 확인

**기능 검증**
- [ ] 모든 단위 테스트 통과
- [ ] init → new → solve 전체 워크플로우 동작
- [ ] git 없이 init → new → config 동작
- [ ] 하위 폴더에서 모든 명령 정상 동작
- [ ] 모든 에러 메시지에 해결 힌트 포함
- [ ] push 실패 시 성공 메시지 없음 확인
- [ ] `--no-push` 성공 시 `Done! (push skipped)` 출력 확인 ⭐
- [ ] `kps new` 후 다음 행동 가이드 출력 확인
- [ ] **잘못된 URL 입력 시 올바른 에러 출력 확인 (에러 삼킴 없음)** ⭐

**URL 파싱 검증** ⭐
- [ ] `school.programmers.co.kr` URL 파싱 동작
- [ ] `programmers.co.kr` URL 파싱 동작 (구버전 호환)
- [ ] 생성된 파일의 URL이 `school.programmers.co.kr`로 통일되는지 확인

**품질 체크**
- [ ] `kps --version` 출력 확인
- [ ] `kps --help` 출력 점검 (예시 포함 여부)
- [ ] `kps init --help`, `kps new --help` 등 서브커맨드 help 점검
- [ ] 실행 파일명 일관성 확인 (`kps`)
- [ ] 파일명에 공백/특수문자 있을 때 동작
- [ ] 쓰기 권한 실패 시 메시지 (권한/경로 안내)

**문서 & 배포**
- [ ] README 완성 (Roadmap + Exit Code 정책 포함)
- [ ] LICENSE 파일 존재
- [ ] GitHub Release 태그 생성

---

## Exit Code 정책

| 상황 | Exit Code |
|------|-----------|
| 성공 (모든 단계 완료) | 0 |
| 에러 (설정 없음, 파일 없음 등) | 1 |
| Git 실패 (add, commit) | 1 |
| Git push 실패 | 1 |

> push 실패도 1로 처리. "기록 완성"이 목표이므로 push 실패는 미완성 상태.

---

## Console 출력 정책 ⭐

| 레벨 | 아이콘 | 출력 대상 | 용도 |
|------|--------|-----------|------|
| success | ✅ | stdout | 완전 성공 |
| info | ✔ 📦 💾 🚀 🔗 💡 | stdout | 진행 상황, 안내 |
| warning | ⚠️ | **stderr** | 부분 실패 (push 실패 등) |
| error | ❌ | **stderr** | 실패 |

> CI/스크립트 연동 시 stderr로 에러/경고 감지 가능

---

## Post-MVP (v0.2+)

### Homebrew 배포
- [ ] Homebrew tap 리포지토리 생성
- [ ] Formula 작성
- [ ] CI 자동 빌드 설정

### 추가 명령어
- [ ] `kps open` - 브라우저에서 문제 페이지 열기
- [ ] `kps list` - 풀이 목록 조회
- [ ] `kps stats` - 통계

### 학습 로그 기능
- [ ] `.kps/history.json` 설계
- [ ] 풀이 기록 자동 저장
- [ ] 재도전 추적
- [ ] 난이도 메타데이터
