//
//  main.swift
//  ParameterSet-Test
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

