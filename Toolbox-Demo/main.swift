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


// ==============================================================
//
//  Demo / Test of ParameterSet
//
// ==============================================================

print("************************************************************")
print("\n*** Demo / Test of ParameterSet ***\n")

// Define parameter set
var myParameterset = ParameterSet([
    "par1": Int(100),
    "par2": 100.0,
    "par3": "Hello World",
    "par5": ParameterSet([
        "sx": 1,
        "sy": 0.2,
        "sz": 3
    ]),
    "par6": "1000.5",
    "par7": [
        "x": 1.5,
        "y": Float(3.8),
        "z": "Test"
    ],
    "par9": DrawMode.solid,
    "par10": Orientation.landscapeRight.rawValue
])

print("Initial dictionary before parameterset tests:")
dump(myParameterset.current)

test(200, "\nAccess non existing element 'par0' with default Int = 200") {
    let par0 = myParameterset["par0", default: 200]
    return par0
}

test(100.0, "\nRead Double 'par2' as Double with default Double = 1.0") {
    let par2: Double = myParameterset["par2", default: 1.0]
    return par2
}

test(100, "\nRead Double 'par2' as Int without default") {
    let par2: Int = myParameterset["par2"]
    return par2
}

test(1, "\nRead invalid numeric String 'par3' as Int with default = 1") {
    let par3: Int = myParameterset["par3", default: 1]
    return par3
}

test(1000.5, "\nRead valid numeric String 'par6' as Double") {
    let par6: Double = myParameterset["par6"]
    return par6
}

test(1000, "\nRead valid numeric String 'par6' as Int") {
    let par6 = myParameterset["par6", default: 1]
    return par6
}

test("200", "\nAssign Int 200 to String 'par6' and read as String") {
    myParameterset["par6"] = 200
    print("Verify 'par6'")
    let par6: String = myParameterset["par6"]
    return par6
}

// Read Enum Type with default
test(DrawMode.solid, "\nRead DrawMode 'par9' with default = .none") {
    let par9: DrawMode = myParameterset["par9", default: .none]
    return par9
}

// Read raw value of Enum type with default
test(Orientation.landscapeRight.rawValue, "\nRead Orientation rawValue 'par10' with default = 0") {
    let par10: Int = myParameterset["par10", default: Orientation.portrait.rawValue]
    return par10
}

// Read Enum type as raw value with default
test(Orientation.landscapeRight, "\nRead Orientation 'par10' with default = .portrait") {
    let par10: Orientation = Orientation(rawValue: myParameterset["par10", default: Orientation.portrait.rawValue])!
    return par10
}

// Currently segmented path addressing of sub-parametersets is not supported
/*
test(1, "\nAccess sub parameter set 'par5', Int element 'x'") {
    let par5: ParameterSet = myParameterset["par5"]
    let x: Int = par5["x", default: 0]
    return x
}


test(Float(200.0), "\nAssign Int 200 to sub dictionary 'par7', element 'y' and read as Float") {
    myParameterset["par7.y"] = 200
    print("Verify 'par7.y'")
    let y: Float = myParameterset["par7.y"]
    return y
}
*/
test(777, "\nAdd new element 'k' = 222 to non-existing sub dictionary 'par8'") {
    myParameterset["par8.k"] = 222
    print("Verify 'par8.k'. Should return default value 777 because assignment to non-existing elements is not allowed")
    let k: Int = myParameterset["par8.k", default: 777]
    return k
}

test(7.5, "\nAssign Double 7.5 to sub dictionary 'par7', new element 'w'") {
    guard myParameterset.addSetting("par7.w", 0.0) else { return 0.0 }
    myParameterset["par7.w"] = 7.5
    print("Verifying 'par7.w'")
    let w: Double = myParameterset["par7.w", default: 0.0]
    return w
}

test(Float(9.9), "\nAssign Float 9.9 to new sub dictionary 'par4', new element 'abc'") {
    guard myParameterset.addSetting("par4", ["abc": Float(0.0)]) else { return Float(0.0) }
    myParameterset["par4.abc"] = Float(9.9)
    print("Verifying 'par4.abc'")
    let abc: Float = myParameterset["par4.abc", default: Float(0.0)]
    return abc
}

print("\nResulting dictionary after castable tests:")
dump(myParameterset.current)

print("\n*** End of Demo / Test of ParameterSet ***\n")
print("\(errorCount) of \(testCount) tests failed.\n")
