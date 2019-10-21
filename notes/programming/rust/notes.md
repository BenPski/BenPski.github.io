---
title: The Rust Programming Language Notes
---

# Chapter 4: Ownership

Main idea is around ownership, tracking usage to avoid allocation and freeing of memory without the use of garbage collection.

## Section 1
Assignment from an existing variable occurs either with moves or copies. Essentially both are shallow copies of data types, but when a data type is fully allocated on the stack (e.g., numbers) a shallow copy is identical to a deep copy. Makes some slight differences in passing arguments and scope when a value is moved or copy, old references are invalid in a move. Ownership is continually transferred when working with values or given up and acquired repeatedly. Can use clone for deep copies.

## Section 2
To avoid moves and copies have references to borrow data, ownership is still involved but the references are what transfer ownership rather than the values themselves. Can reference immutably and mutable, & is the referencing operator and * is the de-referencing operator. Only allowed one mutable reference at a time. Cannot have a mutable and immutable reference at the same time.

## Section 3
Slices refer to a section of memory on the heap, specifically sections of a string are string slices. Make slices by &string[a..b], initial and final index can be left implicit.

# Chapter 5: Structs

Structs are product types and are like most other implementations in other languages.

## Section 1

Defining structs:

```rust
struct Name {
    field1: type,
    field2: type,
    ... ,
}
```

Initialize structs:
```rust
let s = Struct {field1: value, field2: value, ...};
```

Access fields using dot notation. and if it is mutable also use dot notation for mutation. 

The whole struct must be mutable, can't only have some fields mutable and other immutable.

When initializing can eliminate field names if the variable matches the field name. Example `let s = Test {value: value};` $\rightarrow$ `let s = Test {value};`. For initializing a new instance of a struct from data in an existing struct can do:
```rust
let x1 = Thing {...};
let x2 = Thing {field1: value,
                ..x1};               
```
to copy all non-specified fields from the existing data.

Tuple structs are just adding names to tuples to distinguish their type, working with them is just like tuples. Fields are accessed by index rather than name, `x.0` is the first item.
```rust
struct Thing(type, type);
let z = Thing(x, y);
```

Structs should own all their data. If it uses references then lifetimes are necessary.

Have Unit-like structs with no fields `struct Unit;`.

## Section 2

Not really about structs, but using `[#derive(Debug)]` and `println!({:?}, struct)` is convenient for simple initial printing. Can also use `{:#?}` to be a bit prettier.

## Section 3

Can define methods on structs to make it more obvious that certain functions are associated with certain data types. Essentially acting like classes.

```rust
struct Interval {
    lower: f64,
    upper: f64,
}

impl Interval {
    fn average(&self) -> f64 {
        (self.upper + self.lower)/2
    }
}
```

When defining the methods do not need to specify type for `self` as it is obvious from context. `self` can be the value or a reference and can be mutable or immutable just like regular function arguments.

When calling methods use dot syntax. No need to worry about referencing and dereferencing as that is handled implicitly.

Associated functions are functions defined in an `impl` block, but do not take `self` as an argument. These would typically be constructors. These functions are namespaced by the struct like they are for modules.
```rust
impl Interval {
    fn init(lower: f64, upper: f64) -> Interval {
        Interval {lower, upper}
    }
}
```

Can always have multiple `impl` blocks.

# Chapter 6: Enums and Pattern Matching

Enumerations are sum types. With enumerations pattern matching can be done for more concise code similar to Haskell.

## Section 1

Syntax for enums is:
```rust
enum Sum {
    A(type),
    B(type),
}

let a = Sum::A;
let b = Sum::B;
```

Also, I don't think it was mentioned before, there are anonymous structs `{x: i32, y: i32}`. These can be used in the definitions of data structures.

Can also define methods on enums using `impl` like for structs.

### Option

Just like maybe

```rust
enum Option<T> {
    Some(T),
    None,
}
```

## Section 2

`match` is just like `case` it allows for control flow by pattern matching.

```rust
match expr {
    Variant1 => res1,
    Variant2 => res2,
    ...,
}
```

`_` always matches a value.

## Section 3

When there is only one variant being matched on can use `if let` to be a bit more concise. Also can use and `else` branch for all non-matches.

```rust
if let Variant = expr {
    // do something
} else {
    //do something else
}
```

# Chapter 7: Packages, Crates, and Modules

Essentially how to organize code.

Paths: naming things
Modules: group paths
Crates: tree of modules
Package: manipulate crates

## Section 1

Packages must contain at least one crate, it can contain 0 or 1 crates, and it can contain any number of binaries. Crates are either library crates or binary crates. A package is defined by a TOML file.

`cargo new NAME` creates a new package. The presence of `main.rs` implies it is an executable crate and `lib.rs` implies a library crate. Automatically creates a TOML configuration. Can have both `main.rs` and `lib.rs` in `src`. For multiple binaries put files in `src/bin`, each file is a binary.

Crates group scope for usage in code.

## Section 2

Modules group code for organization and control public and private access.

`cargo new --lib NAME` initializes a library.

```rust
mod MOD_NAME {
    //mod_items
}
```

Modules can be nested.

## Section 3

Paths are for locating definitions of functions and data structures. Paths can be absolute or relative. Absolute specifies the whole path starting from `crate` and relative uses identifiers such as `self` and `super`. `::` separates hierarchy levels.

Everything defaults to private and to make things public have to use `pub`. Parent definitions are in scope for child modules and child module definitions are hidden by default to parent modules.

`pub` goes on both modules and definitions in the module.

`super` goes up one level in the module hierarchy much like `..` in a filesystem.

For structs each field can be private or public. For enums either it is all public or all private.

## Section 4

`use` brings paths into scope like importing. `use crate::thing::mod` brings `mod` into scope and the public functions in `mod` are called as `mod::func()`. If dealing with a relative path use `self::path`.

Can alias an import using `as`. `use crate::thing::mod as ThingMod`.

`pub use` allows imports to be public or re-exported.

To use external dependencies add the package name to the `Cargo.toml` file under `[dependencies]` and then you can `use` that package. The standard library, `std`, is always implicitly a dependency.

To shorten repetitive `use`'s can do nested paths. `std::io::{self, Write};` imports `std::io` and `std::io::Write`.

`*` brings all public things into scope.

## Section 5

To use a module from a separate file write `mod thing;`. Having a semicolon rather than braces indicates it is in another file. Layout the file structure like the modules would be laid out in a file.

# Chapter 8: Common Collections

Look at data structures that live on the heap and store multiple values. 

Vectors, strings, and hash maps

## Section 1

Vectors, `Vec<T>`, is an ordered array of homogeneous elements. 

Can create an empty vector with `Vec::new()` or initialize a vector with the macro `vec![...]`.

Push an element to the end with `.push(val)`.

Reading elements can either be done by indexing or getting. Indexing causes a panic if the index is our of range and `.get()` returns an `Option<T>`. Indexing is done with a `&arr[index]`. Indexing starts at 0.

Cannot mutate vector if a immutable reference exists. The memory can move on updates.

Can iterate over elements using `for` loops.

```rust
for i in &v {
    ...
}
``` 
gets a reference to each element.

```rust
for i in &mut v {
    ...
}
```
gets mutable reference to each element. Have to dereference the value to update it.

## Section 2

Strings are hard because language is complicated when you try to include all of them. Rust gives the ability to interpret strings in various ways, but not quite like a list of characters common in other languages.

To initialize strings either use `String::new()` for an empty string, `.to_string()` for anything with the `Display` trait, or `String::from()` to initialize from a string slice.

Append to a string using `.push()` for a character and `.push_str()` for a string.

Concatenate using `+` or using `format!`. Addition needs the second argument to be a reference. Format is more convenient for complex concatenation, `format!("{} and {}", s1, s2)`.

Can get all characters in a string with `.chars()` and all bytes using `.bytes()`.

## Section 3  

Have to `use std::collections::HashMap` to use.

Initialize with `new()`, no macro for initialization. Can use `.collect()` on a vector of tuples to create a hash map a bit easier.

Use `.insert(key, value)` to insert into the map. Insert keeps last value inserted.

Retrieve using `.get()`. Can also iterate over a hash map using a for loop, 

```rust
for (key, value) in map {
    ...
}
```

`.entry()` combined with `.or_insert()` allows for checking if a field is assigned to and inserting something if not.

Can update a value by using a reference to that value (`.or_insert()` returns a mutable reference).

