
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
