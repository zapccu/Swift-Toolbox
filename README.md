
# Swift Dictionary and ParameterSet Toolbox
---
## DictionaryPath

### Purpose

Extends a dictionary of type [String: Any] by addressing sub-dictionaries by path strings.
A path string contains multiple string segments separated by a '.'. Each segment addresses a dictionary level.
For an easier definition of dictionaries a type alias _DictAny_ is defined as a shortcut to [String: Any].

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

---
## Castable and CastableEnum

### Purpose

Defines protocols _Castable_ and _CastableEnum_ and make types Int, UInt, Float, Double and String conform to Castable.
The protocols _Castable_ and _CastableEnum_ define functions for casting values between castable types.

### Functions in protocol Castable

Protocol _Castable_ derives from _Equatable_ and _Any_.

`static func isCastable<T>(from: T) -> Bool`

Check if value _from_ is castable to current type.

`static func cast<T>(from: T) -> any Castable where T: Castable`

Cast value _from_ to current type.

`static var defaultValue: Self { get }`

Return default value of castable type.

### Properties in protocol CastableEnum

Protocol _CastableEnum_ derives from _Castable_ and _RawRepresentable_.

`static var values: [Int] { get }`

Return array with raw values allowed by enum type.

`static var names: [String] { get }`

Return array with alias names for raw values allowed by enum type.

### Helper functions

`func compare<L,R>(_ lhs: L, _ rhs: R) -> Bool where L: Castable, R: Castable`

Compare two values of castable types. If types are different, _rhs_ is casted to _lhs_ before comparision.

`func isCastableToEnum<E,T>(enumType: E.Type, from: T) -> Bool where E: CastableEnum`

Check if value _from_ is castable to a castable Enum type.

`func castToEnum<E,T>(enumType: E.Type, from: T) -> E where E: CastableEnum`

Cast value _from_ to a castable Enum type.

### Extension of Dictionary for Castable and path addressing support

`func delete(_ path: String)`

Delete a dictionary entry (either sub-dictionary or element).

`func cast(fromDict: DictAny)`

Cast and assign dictionary _fromDict_ to current dictionary entry types. Elements which doesn't exist in 
current dictionary are added to current dictionary.

### Extension of Array for Castable support

`func cast(fromArray: [Any])`

Cast and assign array _fromArray_ to current array entry types.

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
