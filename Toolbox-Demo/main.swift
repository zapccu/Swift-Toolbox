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
let i: Int = myDict.getVal("a", 10)
print("a = \(i) \(type(of: i))\n")

// Read Double as Double
print("Read Double as Double")
let f: Double = myDict.getVal("b", 10.0)
print("b = \(f) \(type(of: f))\n")
print("Read Double via subscript with Double default value as Double")
let f1 = myDict["b", 10.0]!
print("b = \(f1) \(type(of: f1))\n")
print("Read Double via subscript with Int default value as Int")
let f2: Int = myDict["b", 10]!
print("b = \(f2) \(type(of: f2))\n")

// Read Double as Int
print("Read Double as Int")
let dasi: Int = myDict.getVal("b", 10)
print("dasi: = \(dasi) \(type(of: dasi))\n")

// Read Double as Float
print("Read Double as Float")
let dasf: Float = myDict.getVal("b", 10.0)
print("dasf = \(dasf) \(type(of: dasf))\n")

// Read Int as Float
print("Read Int as Float")
let iasf: Float = myDict.getVal("a", 1.0)
print("iasf \(iasf), \(type(of: iasf))\n")

print("Add c = 300.0 as Double")
myDict.setVal("c", 300.0)
print("c = \(myDict["c"]!) \(type(of: myDict["c"]))\n")

print("Assign 10 (Int) to c (Double)")
myDict.setVal("c", 10)
print("c = \(myDict["c"]!) \(type(of: myDict["c"]))\n")

print("Read String as Int")
let sasi: Int = myDict.getVal("s", 10)
print("sasi: \(sasi) \(type(of: sasi))\n")

print("Read Double as String")
let dass: String = myDict.getVal("b", "1000.5")
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
    ])
])

print("Access non existing element with default Int")
let par = myParameterset["par", 200]
print("par = \(par!) \(type(of: par!))\n")

print("Read Double as Double")
let par2: Double = myParameterset["par2"]
print("par2 = \(par2) type \(par2)")
/*

let z = myParameterset["par3"]!
print("z: \(z)")

// Access non existing element, return default value 3
if let a = myParameterset["par", 3] {
    print("a: \(a)")
}

// Access an element by path (2 keys separated by ".")
if let b = myParameterset["par4.b", 4] {
    print("b: \(b)")
}

// Return dictionary
let d = myParameterset["par4"]!
print("d: \(d)")

// Access element of type ParameterSet
if let ps = myParameterset["par5"] as? ParameterSet {
    print(type(of: ps))
    print(ps)
    let psz = ps["z"]!
    print("psz: \(psz)")
}

*/



