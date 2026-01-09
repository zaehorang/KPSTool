import Testing
import Foundation
@testable import kps

// MARK: - Test Helpers

/// 에러 설명이 주어진 텍스트를 포함하는지 확인
private func assertErrorContains(_ error: KPSError, _ text: String) {
    #expect(error.errorDescription?.contains(text) == true)
}

/// 에러 설명이 주어진 텍스트 중 하나를 포함하는지 확인
private func assertErrorContainsAny(_ error: KPSError, _ texts: String...) {
    let contains = texts.contains { text in
        error.errorDescription?.contains(text) == true
    }
    #expect(contains)
}

// MARK: - Error Description Tests

@Test("configNotFound should have helpful error message")
func configNotFoundHasHelpfulMessage() {
    assertErrorContains(KPSError.config(.notFound), "kps init")
}

@Test("configNotFoundInGitRepo should mention git repository")
func configNotFoundInGitRepoMentionsGitRepo() {
    let error = KPSError.config(.notFoundInGitRepo)
    assertErrorContains(error, "git repository")
    assertErrorContains(error, "kps init")
}

@Test("invalidProblemNumber should provide clear message")
func invalidProblemNumberProvidesClearMessage() {
    #expect(KPSError.platform(.invalidProblemNumber).errorDescription != nil)
}

@Test("platformRequired should suggest using flags")
func platformRequiredSuggestsFlags() {
    assertErrorContainsAny(KPSError.platform(.platformRequired), "-b", "-p")
}

@Test("conflictingPlatformFlags should mention both flags")
func conflictingPlatformFlagsMentionsBothFlags() {
    let error = KPSError.platform(.conflictingFlags)
    assertErrorContains(error, "-b")
    assertErrorContains(error, "-p")
}

@Test("urlWithPlatformFlag should explain the conflict")
func urlWithPlatformFlagExplainsConflict() {
    #expect(KPSError.platform(.urlWithPlatformFlag).errorDescription != nil)
}

@Test("invalidConfigKey should be informative")
func invalidConfigKeyIsInformative() {
    assertErrorContains(KPSError.config(.invalidKey("invalid")), "invalid")
}

@Test("fileAlreadyExists should mention the problem")
func fileAlreadyExistsMentionsTheProblem() {
    assertErrorContains(KPSError.file(.alreadyExists("/path/to/file.swift")), "file.swift")
}

@Test("fileNotFound should be clear")
func fileNotFoundIsClear() {
    assertErrorContains(KPSError.file(.notFound("/path/to/file.swift")), "file.swift")
}

@Test("gitNotAvailable should provide installation hint")
func gitNotAvailableProvidesInstallationHint() {
    let error = KPSError.git(.notAvailable)
    assertErrorContains(error, "Git")
    assertErrorContains(error, "git-scm.com")
}

@Test("notGitRepository should suggest git init")
func notGitRepositorySuggestsGitInit() {
    assertErrorContains(KPSError.git(.notRepository), "git init")
}

@Test("nothingToCommit should ask if file was saved")
func nothingToCommitAsksIfFileSaved() {
    assertErrorContains(KPSError.git(.nothingToCommit), "No changes")
}

@Test("gitFailed should include stderr output")
func gitFailedIncludesStderrOutput() {
    assertErrorContains(KPSError.git(.failed("test error output")), "test error output")
}

@Test("gitPushFailed should include stderr output")
func gitPushFailedIncludesStderrOutput() {
    assertErrorContains(KPSError.git(.pushFailed("remote error")), "remote error")
}

@Test("permissionDenied should mention permissions")
func permissionDeniedMentionsPermissions() {
    let error = KPSError.file(.permissionDenied("/path/to/file"))
    #expect(error.errorDescription?.lowercased().contains("permission") == true)
    assertErrorContains(error, "/path/to/file")
}

// MARK: - NSError Mapping Tests

@Test("NSFileWriteNoPermissionError should map to permissionDenied")
func nsFileWriteNoPermissionMapsToPermissionDenied() {
    let nsError = NSError(
        domain: NSCocoaErrorDomain,
        code: NSFileWriteNoPermissionError,
        userInfo: [NSFilePathErrorKey: "/test/path"]
    )

    let kpsError = KPSError.from(nsError)

    if case .file(.permissionDenied(let path)) = kpsError {
        #expect(path == "/test/path")
    } else {
        Issue.record("Expected file(.permissionDenied), got \(kpsError)")
    }
}

@Test("NSFileReadNoPermissionError should map to permissionDenied")
func nsFileReadNoPermissionMapsToPermissionDenied() {
    let nsError = NSError(
        domain: NSCocoaErrorDomain,
        code: NSFileReadNoPermissionError,
        userInfo: [NSFilePathErrorKey: "/test/path"]
    )

    let kpsError = KPSError.from(nsError)

    if case .file(.permissionDenied(let path)) = kpsError {
        #expect(path == "/test/path")
    } else {
        Issue.record("Expected file(.permissionDenied), got \(kpsError)")
    }
}

@Test("other NSErrors should map to fileIOError")
func otherNSErrorsMapsToFileIOError() {
    let nsError = NSError(
        domain: NSCocoaErrorDomain,
        code: 999,
        userInfo: nil
    )

    let kpsError = KPSError.from(nsError)

    if case .file(.ioError) = kpsError {
        // Success
    } else {
        Issue.record("Expected file(.ioError), got \(kpsError)")
    }
}

// MARK: - Equality Tests

@Test("invalidProblemNumber should be equal to itself")
func invalidProblemNumberEqualityWorks() {
    let error1 = KPSError.platform(.invalidProblemNumber)
    let error2 = KPSError.platform(.invalidProblemNumber)

    #expect(error1 == error2)
}

@Test("invalidConfigKey with same value should be equal")
func invalidConfigKeyEqualityWorks() {
    let error1 = KPSError.config(.invalidKey("test"))
    let error2 = KPSError.config(.invalidKey("test"))

    #expect(error1 == error2)
}

@Test("fileAlreadyExists with same path should be equal")
func fileAlreadyExistsEqualityWorks() {
    let error1 = KPSError.file(.alreadyExists("/path/file.swift"))
    let error2 = KPSError.file(.alreadyExists("/path/file.swift"))

    #expect(error1 == error2)
}
