//
//  main.swift
//  DictAny-Test
//
//  Created by Dirk Braner on 06.03.25.
//

import Foundation

var testCount: Int = 0
var errorCount: Int = 0

func test<T>(_ expected: T, _ message: String, code: () -> any Castable) where T: Equatable {
    print(message)
    testCount += 1
    let result = code()
    if T.self == type(of: result) {
        if result as! T != expected {
            errorCount += 1
            print("ERR: Expected value \(expected), but got \(result)")
        }
        else {
            print("OK: Expected \(result) \(T.self), got \(expected) \(type(of: result))")
        }
    }
    else {
        errorCount += 1
        print("ERR: Expected type \(T.self), but got \(type(of: result))")
    }
}


// =========================================================================
//
//  Demo / Test of Dictionary<String, Any> with subscript [keyPath: String]
//
// =========================================================================

print("\n*** Demo / Test of Dictionary<String, Any> [keyPath: String] ***\n")

var anyDict: DictAny = [
    "a": Int(100),
    "sub": [
        "x": Int(1000),
        "y": 1.5
    ]
]

print("Initial dictionary:")
dump(anyDict)

// Read Int
test(100, "\nRead Int 'a' without default") {
    return anyDict[keyPath: "a"] as? Int ?? 0
}
test(1000, "\nRead Int 'sub.x' with default = 10") {
    return anyDict[keyPath: "sub.x", default: 10] as? Int ?? 0
}

// Read Double
test(1.5, "\nRead Double 'sub.y' with default = 10.0") {
    return anyDict[keyPath: "sub.y", default: 10.0] as? Double ?? 0
}

// Read non existing element
test(1.0, "\nRead non existing element 'b' with default = 1.0") {
    return anyDict[keyPath: "b", default: 1.0] as? Double ?? 0.0
}

// Read non existing element from sub-dictionary
test(1.0, "\nRead non existing element 'sub.z' with default = 1.0") {
    return anyDict[keyPath: "sub.z", default: 1.0] as? Double ?? 0.0
}

// Assign Double to Int
test(2.5, "\nAssign Double to Int 'a'") {
    anyDict[keyPath: "a"] = 2.5
    return anyDict[keyPath: "a"] as? Double ?? 0.0
}

// Add new element
test(10.5, "\nAdd new sub-dictionary and element 'sub2.a'") {
    anyDict[keyPath: "sub2.a"] = 10.5
    return anyDict[keyPath: "sub2.a"] as? Double ?? 0.0
}

// Delete element x from sub-dictionary
test(0, "\nDelete element 'x' from sub-dictionary 'sub'") {
    anyDict[keyPath: "sub.x"] = nil
    return anyDict.pathExists("sub.x") ? 1 : 0
}

print("\nResulting dictionary:")
dump(anyDict)


