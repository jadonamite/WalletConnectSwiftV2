import XCTest
@testable import Commons

final class EitherTests: XCTestCase {

    // MARK: - Basic Value Tests
    
    func testLeftValue() {
        let value = "string"
        let either = Either<String, Int>(value)
        XCTAssertEqual(either.left, value)
        XCTAssertNil(either.right)
    }

    func testRightValue() {
        let value = 1
        let either = Either<String, Int>(value)
        XCTAssertEqual(either.right, value)
        XCTAssertNil(either.left)
    }
    
    func testLeftInitializer() {
        let either = Either<String, Int>.left("test")
        XCTAssertEqual(either.left, "test")
        XCTAssertNil(either.right)
    }
    
    func testRightInitializer() {
        let either = Either<String, Int>.right(42)
        XCTAssertEqual(either.right, 42)
        XCTAssertNil(either.left)
    }

    // MARK: - Equality Tests
    
    func testEquality() {
        XCTAssertEqual(Either<Int, Int>.left(1), Either<Int, Int>.left(1))
        XCTAssertEqual(Either<Int, Int>.right(1), Either<Int, Int>.right(1))
        XCTAssertNotEqual(Either<Int, Int>.left(1), Either<Int, Int>.right(1))
        XCTAssertNotEqual(Either<Int, Int>.right(1), Either<Int, Int>.left(1))
        XCTAssertNotEqual(Either<Int, Int>.left(1), Either<Int, Int>.left(2))
        XCTAssertNotEqual(Either<Int, Int>.right(1), Either<Int, Int>.right(2))
    }
    
    func testEqualityWithDifferentTypes() {
        let either1 = Either<String, Int>.left("hello")
        let either2 = Either<String, Int>.left("hello")
        let either3 = Either<String, Int>.left("world")
        
        XCTAssertEqual(either1, either2)
        XCTAssertNotEqual(either1, either3)
    }

    // MARK: - Codable Tests
    
    func testCodableRoundTripLeft() throws {
        let either = Either<String, Int>("string")
        let encoded = try JSONEncoder().encode(either)
        let decoded = try JSONDecoder().decode(Either<String, Int>.self, from: encoded)
        XCTAssertEqual(decoded, either)
    }

    func testCodableRoundTripRight() throws {
        let either = Either<String, Int>(1)
        let encoded = try JSONEncoder().encode(either)
        let decoded = try JSONDecoder().decode(Either<String, Int>.self, from: encoded)
        XCTAssertEqual(decoded, either)
    }

    func testDecodingFail() throws {
        let either = Either<Int, Int>.left(1)
        let encoded = try JSONEncoder().encode(either)
        XCTAssertThrowsError(try JSONDecoder().decode(Either<String, String>.self, from: encoded))
    }
    
    func testCodableWithCustomType() throws {
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
        }
        
        let person = Person(name: "John", age: 30)
        let either = Either<Person, String>(person)
        let encoded = try JSONEncoder().encode(either)
        let decoded = try JSONDecoder().decode(Either<Person, String>.self, from: encoded)
        XCTAssertEqual(decoded, either)
    }
    
    func testJSONStructure() throws {
        let either = Either<String, Int>.left("test")
        let encoded = try JSONEncoder().encode(either)
        let json = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        
        XCTAssertNotNil(json)
        // Verify JSON structure matches expected format
        // (depends on your Either implementation)
    }

    // MARK: - Edge Cases
    
    func testOptionalValues() {
        let either1 = Either<String?, Int>.left(nil)
        XCTAssertNil(either1.left)
        XCTAssertNil(either1.right)
        
        let either2 = Either<String?, Int>.left("value")
        XCTAssertEqual(either2.left, "value")
    }
    
    func testNestedEither() {
        let nested = Either<String, Int>.right(42)
        let either = Either<String, Either<String, Int>>.right(nested)
        
        XCTAssertNil(either.left)
        XCTAssertEqual(either.right?.right, 42)
    }
    
    func testEmptyString() {
        let either = Either<String, Int>("")
        XCTAssertEqual(either.left, "")
        XCTAssertNil(either.right)
    }
    
    func testZeroValue() {
        let either = Either<String, Int>(0)
        XCTAssertEqual(either.right, 0)
        XCTAssertNil(either.left)
    }
    
    func testNegativeValue() {
        let either = Either<String, Int>(-1)
        XCTAssertEqual(either.right, -1)
    }

    // MARK: - Functional Operations (if implemented)
    
    func testMapLeft() {
        let either = Either<Int, String>.left(5)
        let mapped = either.mapLeft { $0 * 2 }
        XCTAssertEqual(mapped.left, 10)
    }
    
    func testMapRight() {
        let either = Either<String, Int>.right(5)
        let mapped = either.mapRight { $0 * 2 }
        XCTAssertEqual(mapped.right, 10)
    }
    
    func testFold() {
        let either1 = Either<String, Int>.left("error")
        let result1 = either1.fold(
            ifLeft: { "Left: \($0)" },
            ifRight: { "Right: \($0)" }
        )
        XCTAssertEqual(result1, "Left: error")
        
        let either2 = Either<String, Int>.right(42)
        let result2 = either2.fold(
            ifLeft: { "Left: \($0)" },
            ifRight: { "Right: \($0)" }
        )
        XCTAssertEqual(result2, "Right: 42")
    }
    
    // MARK: - Helper Methods
    
    func testIsLeft() {
        let either1 = Either<String, Int>.left("test")
        let either2 = Either<String, Int>.right(42)
        
        XCTAssertTrue(either1.isLeft)
        XCTAssertFalse(either2.isLeft)
    }
    
    func testIsRight() {
        let either1 = Either<String, Int>.left("test")
        let either2 = Either<String, Int>.right(42)
        
        XCTAssertFalse(either1.isRight)
        XCTAssertTrue(either2.isRight)
    }
    
    func testSwap() {
        let either = Either<String, Int>.left("test")
        let swapped = either.swap()
        
        XCTAssertNil(swapped.left)
        XCTAssertEqual(swapped.right, "test")
    }

    // MARK: - Description/Debug Tests
    
    func testDescription() {
        let either1 = Either<String, Int>.left("error")
        let either2 = Either<String, Int>.right(42)
        
        XCTAssertTrue(either1.description.contains("error"))
        XCTAssertTrue(either2.description.contains("42"))
    }

    // MARK: - Collection Tests
    
    func testArrayOfEither() {
        let eithers: [Either<String, Int>] = [
            .left("error1"),
            .right(1),
            .left("error2"),
            .right(2)
        ]
        
        let lefts = eithers.compactMap { $0.left }
        let rights = eithers.compactMap { $0.right }
        
        XCTAssertEqual(lefts, ["error1", "error2"])
        XCTAssertEqual(rights, [1, 2])
    }
    
    // MARK: - Pattern Matching
    
    func testSwitchPattern() {
        let either1 = Either<String, Int>.left("error")
        var result1 = ""
        
        switch either1 {
        case .left(let value):
            result1 = "Error: \(value)"
        case .right(let value):
            result1 = "Success: \(value)"
        }
        
        XCTAssertEqual(result1, "Error: error")
    }
}
