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

if NSDictionary(dictionary: myDict).isEqual(to: NSDictionary(dictionary: myDict2)) {
    print("Dictionaries are equal")
}
else {
    print("Dictionaries are not equal")
}

print("Type of dictionary =", type(of: myDict))

// Read Int as Int
print("Read Int 'a' as Int without default")
let a3: Int = myDict[path: "a"]
print("Read Int 'a' as Int with default")
let a4 = myDict[path: "a", default: 10]
// print("Read Int 'a' as Int with get toType")
// let a5 = myDict.get("a", toType: Int.self)      // Destination type specified as parameter toType
print("a3 = \(a3) \(type(of: a3))")
print("a4 = \(a4) \(type(of: a4))")
// print("a5 = \(a5) \(type(of: a4))\n")

// Read Double as Double
print("Read Double 'b' as Double without default")
let b1: Double = myDict[path: "b"]
print("b1 = \(b1) \(type(of: b1))\n")
print("Read Double 'b' with default")
let b2 = myDict[path: "b", default: 10.0]
print("b2 = \(b2) \(type(of: b2))\n")

// Read Double as Int
print("Read Double 'b' as Int with default")
let b_as_i = myDict[path: "b", default: 10]
print("b_as_i: = \(b_as_i) \(type(of: b_as_i))\n")

// Read Double as Float
print("Read Double 'b' as Float without default")
let b_as_f: Float = myDict[path: "b"]
print("b_as_f = \(b_as_f) \(type(of: b_as_f))\n")

// Read Int as Float
print("Read Int 'a' as Float with default")
let a_as_f = myDict[path: "a", default: Float(1.0)]
print("a_as_f \(a_as_f), \(type(of: a_as_f))\n")

// Add new Double element
print("Add 'c': 300.0 as Double")
myDict[path: "c"] = 300.0
var c: Double = myDict[path: "c"]
print("c = \(c) \(type(of: c))\n")

// Assign Int to Double element
print("Assign 10 (Int) to 'c' (Double)")
myDict[path: "c"] = 10
c = myDict[path: "c", default: 0.0]
print("c = \(c) \(type(of: c))\n")

// Read numeric String as Int
print("Read numeric String as Int")
// let s_as_i: Int = myDict.get("s", default: 10)
let s_as_i: Int = myDict[path: "s", default: 10]
print("s_as_i: \(s_as_i) \(type(of: s_as_i))\n")

// Read non-numeric String as Int
print("Read non-numeric String as Int. Expected result: default value 10 (Int)")
// let sx_as_i: Int = myDict.get("sx", default: 10)
let sx_as_i: Int = myDict[path: "sx", default: 10]
print("sx_as_i: \(sx_as_i) \(type(of: sx_as_i))\n")
// ERR: Int.defaultValue instead of default => Fatal error or exception?

// Read Double as String
print("Read Double 'b' as String")
// let b_as_s: String = myDict.get("b", default: "1000.5")
let b_as_s: String = myDict[path: "b", default: "1000.5"]
print("b_as_s \(b_as_s), \(type(of: b_as_s))\n")

// Read non-existing element
print("Read non-existing element 't' with default 10")
let t: Int = myDict[path: "t", default: 10]
print("t: \(t) \(type(of: t))\n")

// Read element from sub-dictionary
print("Read element 'x' from sub-dictionary 'sub' with default 10")
let x1: Int = myDict[path: "sub.x", default: 10]
print("x: \(x1) \(type(of: x1))\n")

// Read non-existing element from sub-dictionary
print("Read non-exsting element 'z' from sub-dictionary 'sub' with default 10")
let z1: Int = myDict[path: "sub.z", default: 10]
print("sub.z: \(z1) \(type(of: z1))\n")

// Add new element to sub-dictionary
print("Add new element 'z' to sub-dictionary 'sub'")
myDict[path: "sub.z"] = 400
let z2: Int = myDict[path: "sub.z", default: 10]
print("sub.z: \(z2) \(type(of: z2))\n")

// Recursively add sub-dictionaries
print("Recursively add Double 'i' = 2.99 to sub-dictionaries 'sub1.sub2'")
myDict[path: "sub1.sub2.i"] = 2.99
let i1 = myDict[path: "sub1.sub2.i", default: 0.0]
print("sub1.sub2.i: \(i1) \(type(of: i1))\n")


//
// Demo / Test of ParameterSet
//

/*
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
    "par6": "1000.5"
])

print("Access non existing element 'par0' with default Int 200")
let par0 = myParameterset["par0", default: 200]
print("par0 = \(par0) \(type(of: par0))\n")

print("Read Double 'par2' as Double with default Double 1.0")
let par2: Double = myParameterset["par2", default: 1.0]
print("par2 = \(par2) type \(type(of: par2))\n")

print("Read Double 'par2' as Int without default")
let par2asInt: Int = myParameterset["par2"]
print("par2asInt: \(par2asInt) \(type(of: par2asInt))\n")

print("Read invalid numeric String 'par3' as Int")
let par3asInt: Int = myParameterset["par3", default: 1]
print("par3asInt: \(par3asInt) \(type(of: par3asInt))\n")
// ERR: Return value = 0

print("Read valid numeric String 'par6' as Double")
let par6asDbl: Double = myParameterset["par6"]
print("par6asDbl: \(par6asDbl) \(type(of: par6asDbl))\n")

print("Read valid numeric String 'par6' as Int")
let par6asInt = myParameterset["par6", default: 1]
print("par6asInt: \(par6asInt) \(type(of: par6asInt))\n")

print("Assign Int to String 'par6'")
myParameterset["par6"] = 200
print("Verify 'par6'")
let par6: String = myParameterset["par6"]
print("par6: \(par6) \(type(of: par6))\n")

print("Access sub parameter set 'par5', Int element 'x'")
let par5x: Int = myParameterset.get("par5.x", default: 0)
print("par5.x: \(par5x) \(type(of: par5x))\n")

print("Assign Int to sub parameter set 'par5', element 'y'")
myParameterset["par5.y"] = 200
print("Verify 'par5.y'")
let par5y: Int = myParameterset.get("par5.y", default: 0)
print("par5.y: \(par5y) \(type(of: par5y))\n")

print("Assign Double 7.5 to new sub parameter set 'par5', element 'w'")
myParameterset["par5.w"] = 7.5
print("Verify 'par5.w'")
let par5w: Double = myParameterset.get("par5.w", default: 0.0)
print("par5.w: \(par5w) \(type(of: par5w))\n")

print("\n*** End of Demo / Test of ParameterSet ***\n")

*/
