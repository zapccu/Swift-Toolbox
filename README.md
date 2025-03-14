
# Swift Dictionary and ParameterSet Toolbox

## DictionaryPath

### Purpose

Extends a dictionary of type [String: Any] by path string addressing of sub-dictionaries.
A path string contains multiple string segments separated by a '.'. Each segment addresses a dictionary level.

### Example

```
var myDict = [
   "a": 1,
   "b": 2,
   "c:" [
      "d:" Int(3),
      "e": 1.5
   ]

// Access level 1 of dictionary (same as myDict["a"])
let a = myDict[keyPath: "a"] as? Int ?? 0

// Access level 2 of dictionary: read elements of sub-dictionary "c"
// Use optional parameter "default" to specify a default value which is
// returned when a dictionary element doesn't exist.
let d = myDict[keyPath: "c.d", default: 0] as? Int ?? 0
let e = myDict[keyPath: "c.e", default: 0.0] as? Double ?? 0.0

// Assign values to sub-dictionary
myDict[keyPath: "c.d"] = 10
myDict[keyPath: "c.d"] = 10.0        // Type is changed to Double

// Add a new sub-dictionaty "x" with element "y"
myDict[keyPath: "x.y"] = Int(300)

// Delete element "d" in sub-dictionary "c"
myDict[keyPath: "c.d"] = nil
```

More examples can be found in project target "DictAnyPath-Test".

### Comparing dictionaries

The operator == is overloaded to compare two dictionaries of type [String: Any].


## Castable

### Purpose

Defines protocol Castable and make types Int, UInt, Float, Double and String conform to this protocol.
The protocol defines functions for casting values between castable types.

### Example

```
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

// Read Int element "a" as Int
let a: Int = myDict[path: "a"]

// Read Int element "a" as Int with default = 10
// Destination type can be inferred from default value
let a = myDict[path: "a", default: 10]

// Read Double element "b" as Int
// Destination type is inferred from default value
let b = myDict[path: "b", default: 10]

// Read Double as Float
let b: Float = myDict[path: "b"]

// Add a new Double element "c"
myDict[path: "c"] = 300.0        
```
