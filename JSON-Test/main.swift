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


