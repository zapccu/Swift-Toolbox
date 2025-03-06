//
//  main.swift
//  ToolboxTest
//
//  Created by Dirk Braner on 27.11.24.
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


// ======================================================================
//
//  Demo / Test of Dictionary<String, Any> with subscript [path: String]
//  and value conform to protocol castable
//
// ======================================================================

print("\n*******************************************************************")
print("\n*** Demo / Test of Dictionary<String, Any> [path: String] ***\n")

var myDict: DictAny = [
    "a": 100,       // Int
    "b": 2.5,       // Double
    "s": "222",     // Numeric String
    "sx": "Test",   // Non-numeric String
    "sub": [        // Sub-dictionary
        "x": 1000,
        "y": 3.1415
    ]
]

var myDict2: DictAny = [
    "a": 100,       // Int
    "b": 2.5,       // Double
    "s": "222",     // Numeric String
    "sx": "Test",   // Non-numeric String
    "sub": [        // Sub-dictionary
        "x": 1000.0,
        "y": 3.1415
    ]
]

print("Initial dictionary before castable tests:")
dump(myDict)

// Compare dictionaries of type [String: Any]
testCount += 1
print("\nCompare dictionaries:")
if myDict == myDict2 {
    print("Dictionaries are equal\n")
}
else {
    print("ERR: Dictionaries are not equal\n")
    errorCount += 1
}

// Read Int as Int
test(100, "\nRead Int 'a' as Int without default") {
    let a: Int = myDict[path: "a"]
    return a
}
test(100, "\nRead Int 'a' as Int with default = 10") {
    let a = myDict[path: "a", default: 10]
    return a
}

// Read Double as Double
test(2.5, "\nRead Double 'b' as Double without default") {
    let b: Double = myDict[path: "b"]
    return b
}

// Read Double as Int
test(2, "\nRead Double 'b' as Int with default = 10") {
    let b = myDict[path: "b", default: 10]
    return b
}

// Read Double as Float
test(Float(2.5), "\nRead Double 'b' as Float without default") {
    let b: Float = myDict[path: "b"]
    return b
}

// Read Int as Float
test(Float(100.0), "\nRead Int 'a' as Float with default = Float 1.0") {
    let a = myDict[path: "a", default: Float(1.0)]
    return a
}

// Add new Double element
test(300.0, "\nAdd 'c': 300.0 as Double") {
    myDict[path: "c"] = 300.0
    let c: Double = myDict[path: "c"]
    return c
}

// Assign Int to Double element
test(10.0, "\nAssign 10 (Int) to 'c' (Double)") {
    myDict[path: "c"] = 10
    let c = myDict[path: "c", default: 0.0]
    return c
}

// Assign Int to Double element
test(10.0, "\nAssign 10 (Int) to 'b' (Double)") {
    myDict[path: "b"] = 10
    let b = myDict[path: "b", default: 0.0]
    return b
}

// Read numeric String as Int
test(222, "\nRead numeric String as Int with default = 10") {
    let i: Int = myDict[path: "s", default: 10]
    return i
}

// Read non-numeric String as Int
test(10, "\nRead non-numeric String as Int with default = 10") {
    let i: Int = myDict[path: "sx", default: 10]
    return i
}

// Read Double as String
test("10.0", "\nRead Double 'b' as String with default = \"1000.5\"") {
    let s: String = myDict[path: "b", default: "1000.5"]
    return s
}

// Read non-existing element
test(10, "\nRead non-existing element 't' with default = 10") {
    let t: Int = myDict[path: "t", default: 10]
    return t
}

// Read element from sub-dictionary
test(1000, "\nRead element 'x' from sub-dictionary 'sub' with default = 10") {
    let x: Int = myDict[path: "sub.x", default: 10]
    return x
}

// Read non-existing element from sub-dictionary
test(10, "\nRead non-exsting element 'z' from sub-dictionary 'sub' with default = 10") {
    let z: Int = myDict[path: "sub.z", default: 10]
    return z
}

// Add new element to sub-dictionary
test(400, "\nAdd new element 'z' to sub-dictionary 'sub'") {
    myDict[path: "sub.z"] = 400
    let z: Int = myDict[path: "sub.z", default: 10]
    return z
}

// Recursively add sub-dictionaries
test(2.99, "\nRecursively add Double 'i' = 2.99 to sub-dictionaries 'sub1.sub2'") {
    myDict[path: "sub1.sub2.i"] = 2.99
    let i = myDict[path: "sub1.sub2.i", default: 0.0]
    return i
}

// Read sub-dictionary
// Slightly different from reading castable elements because a DictAny is not castable
print("\nRead sub-dictionary 'sub'")
let d1: DictAny = myDict[path: "sub"]
print(d1)

// Assign dictionary
let mySubDict: DictAny = [
    "x": 1,
    "y": 2,
    "z": 3
]
myDict[path: "subdict"] = mySubDict

print("\nRead sub-dictionary 'subdict' after assignment")
let d2: DictAny = myDict[path: "subdict"]
print("Org")
dump(mySubDict)
print("Read")
dump(d2)

print("\nResulting dictionary after castable tests:")
dump(myDict)


