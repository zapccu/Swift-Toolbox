//
//  JSON-Test
//
//  Created by Dirk Braner on 25.02.25.
//
//  Test of JSON conversion functionality of ParameterSet
//

import Foundation

print("************************************************************")
print("\n*** Demo / Test of JSON conversion of ParameterSet ***\n")

// Define parameter set
var myParameterset = ParameterSet([
    "par1": Int(100),
    "par2": ParameterSet([
        "sx": 1.0,
        "sy": 0.2,
        "sz": 3
    ])
])

print("Initial dictionary before JSON test:")
dump(myParameterset.current)

print("\nConvert parameterset to JSON string")
let psjs = myParameterset.jsonString
if psjs != "" {
    print("Parameterset as JSON:\n\(psjs)")
}
else {
    print("ERR: Conversion failed")
}

print("\nConvert JSON string to parameterset")
var myNewParameterset = myParameterset
let jsstr = psjs.replacingOccurrences(of: "0.2", with: "0.8")
if myNewParameterset.fromJSON(jsstr) {
    print("\nConversion successful. Dump of new parameterset current:")
    dump(myNewParameterset.current)
    print("\nDump of new parameterset previous:")
    dump(myNewParameterset.previous)
    if myNewParameterset.current == myParameterset.current {
        print("Initial and converted dictionaries are equal")
    }
    else {
        print("Initial and converted dictionaries are not equal")
    }
}
else {
    print("Conversion failed")
}

// Define 2nd parameter set
var myParameterset2 = ParameterSet([
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

print("\nConvert parameterset to JSON string")
let psjs2 = myParameterset2.jsonString
if psjs2 != "" {
    print("Parameterset as JSON:\n\(psjs2)")
}
else {
    print("ERR: Conversion failed")
}

print("\nConvert JSON string to parameterset")
var myNewParameterset2 = myParameterset2
if myNewParameterset2.fromJSON(psjs2) {
    print("Conversion successful. Dump of new parameterset:")
    dump(myNewParameterset2.current)
    if myNewParameterset2.current == myParameterset2.current {
        print("Initial and converted dictionaries are equal")
    }
    else {
        print("ERR: Initial and converted dictionaries are not equal")
    }
}
else {
    print("Conversion failed")
}

