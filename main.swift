//
//  main.swift
//  ToolboxTest
//
//  Created by Dirk Braner on 27.11.24.
//

import Foundation

var myDict: Dictionary<String, Any> = [
    "a": 100,
    "b": 2.5,
    "s": "222"
]

// Define parameter set
let myParameterset = ParameterSet([
    "par1": Int(100),
    "par2": 100.0,
    "par3": "Hello World",
    "par4": [                   // Dictionary as parameter
        "a": 100,
        "b": 200
    ],
    "par5": ParameterSet([      // ParameterSet as parameter
        "x": 1,
        "y": 2,
        "z": 3
    ])
])

// Read Int as Int
let i: Int = myDict.getValue("a", 10)
print("i: \(i)")

// Read Double as Double
let f: Double = myDict.getValue("b", 10.0)
print("Subscript Double default: ", myDict["b", 10.0]!)
print("Subscript Int default: ", myDict["b", 10]! as Int)
print("f: \(f) \(type(of: f))")

// Read Double as Int
let intf: Int = myDict.getValue("b", 10)
print("intf: \(intf)")

// Read Double as Float
let fltf: Float = myDict.getValue("b", 10.0)
print("fltf: \(fltf) \(type(of: fltf))")

// Read Int as Float
let aflt: Float = myDict.getValue("a", 1.0)
print("aflt: \(aflt), \(type(of: aflt))")

print("Add c = 300.0 as Double")
myDict.setValue("c", 300.0)
print("Type of c is \(type(of: myDict["c"]!))")

print("Assign int 10 to c (Double)")
myDict.setValue("c", 10)
print("Type of c is \(type(of: myDict["c"]!))")

let istr: Int = myDict.getValue("s", 10)
print("istr: \(istr)")

let sflt: String = myDict.getValue("b", "1000.5")
print("slft \(sflt), \(type(of: sflt))")

/*
let x = myParameterset["par", 200] as? Int
print("x: \(x!)")

let y = myParameterset["par2"] as! Double
let t = type(of: y)
print("y: \(y) type \(t)")

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



