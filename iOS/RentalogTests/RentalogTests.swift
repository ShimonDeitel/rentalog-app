import XCTest
@testable import Rentalog

@MainActor
final class RentalogTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(RentalogEntry(customerName: "Test", amount: 10, note: "n", date: Date()))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        let store = Store()
        store.entries = []
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtFreeLimit() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            RentalogEntry(customerName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = false
        XCTAssertFalse(store.canAddMore)
        let result = store.add(RentalogEntry(customerName: "Over", amount: 1, note: "", date: Date()))
        XCTAssertFalse(result)
    }

    func testProUserCanAlwaysAdd() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            RentalogEntry(customerName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteEntry() {
        let store = Store()
        let entry = RentalogEntry(customerName: "ToDelete", amount: 5, note: "", date: Date())
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntry() {
        let store = Store()
        var entry = RentalogEntry(customerName: "Original", amount: 5, note: "", date: Date())
        store.add(entry)
        entry.customerName = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.customerName, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        store.entries = []
        store.add(RentalogEntry(customerName: "A", amount: 1, note: "", date: Date()))
        store.add(RentalogEntry(customerName: "B", amount: 1, note: "", date: Date()))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
    }
}
