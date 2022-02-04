import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(grecon2_experimentsTests.allTests),
    ]
}
#endif
