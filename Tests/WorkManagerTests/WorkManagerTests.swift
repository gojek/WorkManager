import XCTest
@testable import WorkManager

final class WorkManagerTests: XCTestCase {
    let sut = WorkManager.shared
    
    func testQueuing() throws {
        let performExpectation = XCTestExpectation(description: "performExpectation")
        var didPerformed = false
        sut.enqueueUniquePeriodicWork(id: "com.example.task.one", interval: 20) {
            didPerformed = true
            performExpectation.fulfill()
        }
        wait(for: [performExpectation], timeout: 21)
        assert(didPerformed)
    }
    
    func testCancellation() throws {
        let performExpectation = XCTestExpectation(description: "performExpectation")
        var didPerformed = false
        sut.enqueueUniquePeriodicWork(id: "com.example.task.two", interval: 20) {
            didPerformed = true
            performExpectation.fulfill()
        }
        sleep(5)
        sut.cancelQueuedPeriodicWork(withId: "com.example.task.two")
        performExpectation.fulfill()
        wait(for: [performExpectation], timeout: 21)
        assert(!didPerformed)
    }
    
}
