# ROY (Extensible Imperative Language)

## Description

### Goals

asdf

### Progress

asdf

## Instructions

RoySytax.hs holds the definitions of the data types that make up the core syntax and AST of the language.

RoySemantics.hs defines the basic data types and operations  in the language, and contains evaluation functions for expressions and statements. 

RoyTests.hs contains doctest test cases for the evaluation functions.  After installing doctest, the tests can be ran with the following command:

`doctest RoyTests.hs`

To interact with the language and evaluation functions in GHCi, load RoySemantics.hs in GHCi with the following command:

`ghci RoySemantics.hs`


In GHCi, you can build expressions and statements using the AST that is defined in RoySyntax.hs.
Note that DVals can be created using `(DA x)` where x is any instance of RoyDataType.
Sometimes, GHCi will require you to explicitly state the type of x.
For example, to store the integer 4 as a DVal you would need to do `(DA 4::Int)`.

Expressions and Statements can be evaluated using their evaluation functions.
Their respective evaluation functions are `eval` for expressions, `stmt` for a single statement, and `stmts` for a list of statements.
Notice that each evaluation function also takes in a tuple, with the first element being a list of tuples with a variable name and a `DVal` stored in that variable, and the second element being a list of tuples with a function name, and a list of statements for that function.
The easiest environment to start with is `([],[])`. 
You can see many examples of these evaluation functions being used in RoyTests.hs. 

## Design Questions

- Currently we are using a Generalised Algebraic Data Type (GADT) to represent values in our program.  That data type is called DVal.  What we accomplished with this GADT is that any instance of the type class RoyDataType can be stored in a DVal.  This allows us to have environments that hold an arbitrary number of data types.  The user can extend the amount of data types that can be held in the environment by creating new instances of RoyDataType.  

  We found this created issues for us, as our RoyDataType instances now must be Typeable, and we have to cast them from DVals back to their original types to perform primitive operations on them.  Do you have any other suggestions for how we could accomplish having variable environments while also allowing users to extend the language with new data types?  Any other suggestions overall to improve the simplicity of our interpreter while maintaining extensibility of the language? 
- The next steps for us will be to design a concrete syntax and implement a parser to convert concrete syntax into a list of statements.  We are looking at using the [Parsec](https://wiki.haskell.org/Parsec) library for the parser.  All of the functions that we will need to have defined to parse user created data types are included in the RoyDataType type class.  Do you have any suggestions for us when designing our parser and concrete syntax?
- Currently, returning from a function is a statement, but that statement is interpreted by the runFun function which is called by the expression evaluation function.  This feels off to me.  It feels like the stmts function and the runFun are doing the same job, but they have different return types.  Do you have any suggestions to resolve this, or improve the way that we return from functions?
- Do you have any ideas for how we could get primitive operations to be able to return a different type than the type of their inputs?
- We're thinking of ditching having a type checker and doing our error checking at run time, as shown in our evaluation functions.  Does our error checking look sufficient so far? Are there any error cases we are missing?
