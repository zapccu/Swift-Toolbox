//
//  main.swift
//  ToolboxTest
//
//  Created by Dirk Braner on 27.11.24.
//

import Foundation

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





