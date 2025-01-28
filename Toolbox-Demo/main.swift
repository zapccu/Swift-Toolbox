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

var myDict: DictPar = [
    "a": 100,   // Int
    "b": 2.5,   // Double
    "s": "222"  // Numeric String
]

// Read Int as Int
print("Read Int as Int")
let i: Int = myDict.get("a", default: 10)
print("a = \(i) \(type(of: i))\n")

// Read Double as Double
print("Read Double as Double")
let f: Double = myDict.get("b", default: 10.0)
print("b = \(f) \(type(of: f))\n")
print("Read Double via subscript with Double default value as Double")
let f1 = myDict["b", default: 10.0]
print("b = \(f1) \(type(of: f1))\n")
print("Read Double via subscript with Int default value as Int")
let f3: Int = myDict.get("b", default: 10)
let f2: Int = myDict["b", default: 10]
print("b = \(f2) \(type(of: f2))\n")

// Read Double as Int
print("Read Double as Int")
let dasi: Int = myDict.get("b", default: 10)
print("dasi: = \(dasi) \(type(of: dasi))\n")

// Read Double as Float
print("Read Double as Float")
let dasf: Float = myDict.get("b", default: 10.0)
print("dasf = \(dasf) \(type(of: dasf))\n")

// Read Int as Float
print("Read Int as Float")
let iasf: Float = myDict.get("a", default: 1.0)
print("iasf \(iasf), \(type(of: iasf))\n")

print("Add c = 300.0 as Double")
myDict.set("c", 300.0)
print("c = \(myDict["c"]!) \(type(of: myDict["c"]))\n")

print("Assign 10 (Int) to c (Double)")
myDict.set("c", 10)
print("c = \(myDict["c"]!) \(type(of: myDict["c"]))\n")

print("Read String as Int")
let sasi: Int = myDict.get("s", default: 10)
print("sasi: \(sasi) \(type(of: sasi))\n")

print("Read Double as String")
let dass: String = myDict.get("b", default: "1000.5")
print("dass \(dass), \(type(of: dass))\n")


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
    "par6": "1000.5"
])

print("Access non existing element with default Int")
let par = myParameterset["par", default: 200]
print("par = \(par) \(type(of: par))\n")

print("Read Double as Double")
let par2: Double = myParameterset["par2", default: 1.0]
print("par2 = \(par2) type \(type(of: par2))")

print("Read Double as Int")
let par2asInt: Int = myParameterset["par2", default: 1]
print("par2asInt: \(par2asInt) \(type(of: par2asInt))\n")

print("Read invalid numeric String as Int")
let par3asInt: Int = myParameterset["par3", default: 1]
print("par3asInt: \(par3asInt) \(type(of: par3asInt))\n")

print("Read valid numeric String as Double")
let par6asDbl: Double = myParameterset["par6"]
print("par6asDbl: \(par6asDbl) \(type(of: par6asDbl))\n")

print("Read valid numeric String as Int")
let par6asInt = myParameterset["par6", default: 1]
print("par6asInt: \(par6asInt) \(type(of: par6asInt))\n")

print("Assign Int to String")
// ERR-1: Remove "default" from assign subscript?
myParameterset["par6"] = 200
print("par6 = ", myParameterset["par6", default: "0"], type(of: myParameterset["par6", default: "0"]), "\n")

print("Access sub parameter set")
// ERR-2: Segmented path not working
// let sx: Int = myParameterset["par5.x", default: 0]
let sx: Int = myParameterset["par5", default: ParameterSet([:])]["x", default: 0]
print("sx: \(sx) \(type(of: sx))\n")





