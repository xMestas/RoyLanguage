# ROY (Extensible Imperative Language)

## Description

### Goals

For our project, we will create an easily user extendable imperative programming language (ROY), and implement a simple extension known as Linear Algebra Neatly Created Extension (LANCE) to demonstrate how such extensions can be done. 
Our programming language will be simple in its core features, but designed to be extended by users by allowing them to implement custom data types and operations on those data types–a plugin architecture.  In addition, we will take inspiration from SageMath and implement an example user extension that includes matrices and vectors as data types with basic operations such as dot products that can be performed on them.

The features planned for our project are:

- A simple extensible programming language that supports integers and booleans, as well as allows the user to extend the language with their own custom primitive data types and operations.

- Basic operations implemented for integers and booleans.

- Core language features including if statements, while loops, primitive operations, setting and referencing variables, and defining/calling functions.

- An interpreter for the language and it's basic features that is compatible with user added operations and data types.

- An extendable parser that can convert the languages concrete syntax to an AST that can be interpreted by the interpreter.

- An extendable type checker that can validate programs before they are ran by the interpreter.

- An example user extension to the programming language.

### Progress

The features implemented so far are: 

- Created the data types to represent the AST of an extensible imperative programming language.

- Implemented a basic interpreter for the existing language features. 

- Supported if statements, while loops, primitive operations, setting and referencing variables, and defining/calling functions in the AST and interpreter.

- Included support for Integers and Booleans along with a simple primitive operation for each (not all operations are implemented yet).

- Added run time error checking to the interpreter in place of the type checker.  

- Defined multiple test cases to ensure correctness in the interpreter.

The features to be implemented in the future are:

- Add more primitive operations for integers and booleans.

- Create an extendable concrete syntax and parser, and a program that links the parser to the interpreter.  

- Develop an example user extension to show that the language is extendable. 

## Instructions

(RoySyntax.hs)[RoySyntax.hs] holds the definitions of the data types that make up the core syntax and AST of the language.

(RoyBase.hs)[RoyBase.hs] defines the basic data types and operations in the language. The basic data types and operations are added to the language in the same way an extension would be done.

(RoySemantics.hs)[RoySemantics.hs] contains evaluation functions for expressions and statements. 

(RoyExamples.hs)[RoyExamples.hs] has example programs for the language, as well as helper functions for building example programs. 

(RoyTests.hs)[RoyTests.hs] contains doctest test cases for the evaluation functions that use the examples.  After installing doctest, the tests can be ran with the following command:

`doctest RoyTests.hs`

To interact with the language, example programs, and evaluation functions in GHCi, load (RoyTests.hs)[RoyTests.hs] in GHCi with the following command:

`ghci RoyTests.hs`


In GHCi, you can build expressions and statements using the AST that is defined in (RoySyntax.hs)[RoySyntax.hs].
Note that DVals can be created using `(DA x)` where x is any instance of RoyDataType.
Sometimes, GHCi will require you to explicitly state the type of x.
For example, to store the integer 4 as a DVal you would need to do `(DA 4::Int)`.

Expressions and Statements can be evaluated using their evaluation functions.
Their respective evaluation functions are `eval` for expressions, `stmt` for a single statement, and `stmts` for a list of statements.
The `runFun` function is used for evaluating the result of a function (a list of statements that contains a return statement).
Notice that each evaluation function also takes in a tuple, with the first element being a list of tuples with a variable name and a `DVal` stored in that variable, and the second element being a list of tuples with a function name, and a list of statements for that function.
The easiest environment to start with is `([],[])`. 
You can see many examples of these evaluation functions being used in (RoyTests.hs)[RoyTest.hs]. 

### Examples

- `eval (Prim "add" (Lit (DA (3::Int))) (Ref "x")) ([("x",DA (5::Int))],[])`
  
  `Just 8`
  
  This example evaluates a simple expression that adds 3 and x when x stores the value 5.

- `stmts [Set "x" (Lit (DA (4::Int))), Set "y" (Lit (DA True))] ([],[])`
  
  `Just ([("y",True),("x",4)],[])`

  This example evaluates a simple list of statements that set the variables x to 4 and y to True.

- `stmt (If (Lit (DA (5::Int))) [Set "x" (Lit (DA False))]) ([],[])`
  
  `Nothing`

  A Nothing value is returned because using an if statement with a condition that is not a boolean is not allowed.

- `runFun prog3 ([], [])`

  `Just 105`

  Runs a program that takes the number 100, passes it to a function that adds 5 to it using a loop, and returns the result.

## Design Questions

- Currently we are using a Generalised Algebraic Data Type (GADT) to represent values in our program.  That data type is called DVal.  What we accomplished with this GADT is that any instance of the type class RoyDataType can be stored in a DVal.  This allows us to have environments that hold an arbitrary number of data types.  The user can extend the amount of data types that can be held in the environment by creating new instances of RoyDataType.  

  We found this created issues for us, as our RoyDataType instances now must be Typeable, and we have to cast them from DVals back to their original types to perform primitive operations on them.  Do you have any other suggestions for how we could accomplish having variable environments while also allowing users to extend the language with new data types?  Any other suggestions overall to improve the simplicity of our interpreter while maintaining extensibility of the language? 
- The next steps for us will be to design a concrete syntax and implement a parser to convert concrete syntax into a list of statements.  We are looking at using the [Parsec](https://wiki.haskell.org/Parsec) library for the parser.  All of the functions that we will need to have defined to parse user created data types are included in the RoyDataType type class.  Do you have any suggestions for us when designing our parser and concrete syntax?
- Currently, returning from a function is a statement, but that statement is interpreted by the runFun function which is called by the expression evaluation function.  This feels off to me.  It feels like the stmts function and the runFun are doing the same job, but they have different return types.  Do you have any suggestions to resolve this, or improve the way that we return from functions?  Also, we can not return inside of if statements and while loops as a result.
- Do you have any ideas for how we could have primitive operations with different arities?
- We're thinking of ditching having a type checker and doing our error checking at run time, as shown in our evaluation functions.  Does our error checking look sufficient so far? Are there any error cases we are missing?
