//
//  main.swift
//  ToolboxTest
//
//  Created by Dirk Braner on 27.11.24.
//

import Foundation


//
// Demo / Test of Dictionary<String, any Castable>
//

print("\n*** Demo / Test of Dictionary<String, any Castable> ***\n")

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

let myDict3 = DictAny(jsonString: "{\"a\":50,\"b\":12.5}")
print("myDict3 = \(type(of: myDict3))")


if NSDictionary(dictionary: myDict).isEqual(to: NSDictionary(dictionary: myDict2)) {
    print("Dictionaries are equal\n")
}
else {
    print("Dictionaries are not equal\n")
}

print("Type of dictionary = \(type(of: myDict))\n")

// Convert dictionary to JSON
let js = myDict.jsonString
print("JSON:\n\(js)\n")
let di = DictAny(jsonString: js)
print(di)

// Read Int as Int
print("\nRead Int 'a' as Int without default")
let a3: Int = myDict[path: "a"]
print("Read Int 'a' as Int with default")
let a4 = myDict[path: "a", default: 10]
expect(100, a3, "a3")
expect(100, a4, "a4")

// Read Double as Double
print("\nRead Double 'b' as Double without default")
let b1: Double = myDict[path: "b"]
expect(2.5, b1, "b1")
print("Read Double 'b' with default")
let b2 = myDict[path: "b", default: 10.0]
expect(2.5, b2, "b2")

// Read Double as Int
print("\nRead Double 'b' as Int with default")
let b_as_i = myDict[path: "b", default: 10]
print("b_as_i: = \(b_as_i) \(type(of: b_as_i))\n")
expect(2, b_as_i, "b_as_i")

// Read Double as Float
print("\nRead Double 'b' as Float without default")
let b_as_f: Float = myDict[path: "b"]
expect(Float(2.5), b_as_f, "b_as_f")

// Read Int as Float
print("\nRead Int 'a' as Float with default")
let a_as_f = myDict[path: "a", default: Float(1.0)]
print("a_as_f \(a_as_f), \(type(of: a_as_f))\n")
expect(Float(100.0), a_as_f, "a_as_f")

// Add new Double element
print("\nAdd 'c': 300.0 as Double")
myDict[path: "c"] = 300.0
var c: Double = myDict[path: "c"]
expect(300.0, c, "c")

// Assign Int to Double element
print("\nAssign 10 (Int) to 'c' (Double)")
myDict[path: "c"] = 10
let c1 = myDict[path: "c", default: 0.0]
expect(10.0, c1, "c1")

// Read numeric String as Int
print("\nRead numeric String as Int")
// let s_as_i: Int = myDict.get("s", default: 10)
let s_as_i: Int = myDict[path: "s", default: 10]
print("s_as_i: \(s_as_i) \(type(of: s_as_i))\n")
expect(222, s_as_i, "s_as_i")

// Read non-numeric String as Int
print("\nRead non-numeric String as Int. Expected result: default value 10 (Int)")
// let sx_as_i: Int = myDict.get("sx", default: 10)
let sx_as_i: Int = myDict[path: "sx", default: 10]
expect(10, sx_as_i, "sx_as_i")

// Read Double as String
print("\nRead Double 'b' as String")
// let b_as_s: String = myDict.get("b", default: "1000.5")
let b_as_s: String = myDict[path: "b", default: "1000.5"]
expect("2.5", b_as_s, "b_as_s")

// Read non-existing element
print("\nRead non-existing element 't' with default 10")
let t: Int = myDict[path: "t", default: 10]
expect(10, t, "t")

// Read element from sub-dictionary
print("\nRead element 'x' from sub-dictionary 'sub' with default 10")
let x1: Int = myDict[path: "sub.x", default: 10]
expect(1000, x1, "x1")

// Read non-existing element from sub-dictionary
print("\nRead non-exsting element 'z' from sub-dictionary 'sub' with default 10")
let z1: Int = myDict[path: "sub.z", default: 10]
expect(10, z1, "z1")

// Add new element to sub-dictionary
print("\nAdd new element 'z' to sub-dictionary 'sub'")
myDict[path: "sub.z"] = 400
let z2: Int = myDict[path: "sub.z", default: 10]
expect(400, z2, "z2")

// Recursively add sub-dictionaries
print("\nRecursively add Double 'i' = 2.99 to sub-dictionaries 'sub1.sub2'")
myDict[path: "sub1.sub2.i"] = 2.99
let i1 = myDict[path: "sub1.sub2.i", default: 0.0]
expect(2.99, i1, "i1")


//
// Demo / Test of ParameterSet
//

print("\n*** Demo / Test of ParameterSet ***\n")

// Define parameter set
var myParameterset = ParameterSet([
    "par1": Int(100),
    "par2": 100.0,
    "par3": "Hello World",
    "par4": ParameterSet(myDict),
    "par5": ParameterSet([      // ParameterSet as parameter
        "x": 1,
        "y": 2,
        "z": 3
    ]),
    "par6": "1000.5",
    "par7": [
        "x": 1.5,
        "y": Float(3.8)
    ]
])

/*
let psjs = myParameterset.jsonString
print("Parameterset as JSON:\n\(psjs)")
*/
print("\nAccess non existing element 'par0' with default Int 200")
let par0 = myParameterset["par0", default: 200]
expect(200, par0, "par0")

print("\nRead Double 'par2' as Double with default Double 1.0")
let par2: Double = myParameterset["par2", default: 1.0]
expect(100.0, par2, "par2")

print("\nRead Double 'par2' as Int without default")
let par2asInt: Int = myParameterset["par2"]
expect(100, par2asInt, "par2asInt")

print("\nRead invalid numeric String 'par3' as Int")
let par3asInt: Int = myParameterset["par3", default: 1]
expect(1, par3asInt, "par3asInt")

print("\nRead valid numeric String 'par6' as Double")
let par6asDbl: Double = myParameterset["par6"]
expect(1000.5, par6asDbl, "par6asDbl")

print("\nRead valid numeric String 'par6' as Int")
let par6asInt = myParameterset["par6", default: 1]
expect(1000, par6asInt, "par6asInt")

print("\nAssign Int to String 'par6'")
myParameterset["par6"] = 200
print("Verify 'par6'")
let par6: String = myParameterset["par6"]
expect("200", par6, "par6")

// Currently segmented path addressing of sub-parametersets is not supported
print("\nAccess sub parameter set 'par5', Int element 'x'")
let par5: ParameterSet = myParameterset["par5"]
let par5x: Int = par5["x", default: 0]
expect(1, par5x, "par5x")

print("\nAssign Int to sub parameter set 'par7', element 'y'")
myParameterset["par7.y"] = 200
print("Verify 'par7.y'")
let par7y: Float = myParameterset["par7.y"]
expect(Float(200.0), par7y, "par7y")

/*

print("Assign Double 7.5 to new sub parameter set 'par5', element 'w'")
myParameterset["par5.w"] = 7.5
print("Verify 'par5.w'")
let par5w: Double = myParameterset.get("par5.w", default: 0.0)
print("par5.w: \(par5w) \(type(of: par5w))\n")

 */

print("\n*** End of Demo / Test of ParameterSet ***\n")

