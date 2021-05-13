module RoyTests where

import RoySyntax
import RoySemantics
import RoyBase
import RoyExamples


-- | Expression Evaluation Function Tests
--
--   >>> eval (Lit (DA (4::Int))) ([],[])
--   Just 4
--
--   >>> eval (Prim "add" (Lit (DA (3::Int))) (Lit (DA (4::Int)))) ([],[])
--   Just 7
--
--   >>> eval (Ref "x") ([("x",DA (5::Int))],[])
--   Just 5
--
--   >>> eval (Prim "add" (Lit (DA (3::Int))) (Ref "x")) ([("x",DA (5::Int))],[])
--   Just 8
--
--   >>> eval (Prim "eq" (Lit (DA (True))) (Lit (DA (False)))) ([],[])
--   Just False
--
--   >>> eval (Prim "add" (Lit (DA (True))) (Lit (DA (3::Int)))) ([],[])
--   Nothing
--
--   >>> eval (Prim "eq" (Lit (DA (True))) (Lit (DA (3::Int)))) ([],[])
--   Nothing
--
--   >>> eval (Prim "eq" (Lit (DA (5::Int))) (Ref "x")) ([("x",DA (5::Int))],[])
--   Just True
--
--   >>> eval (Prim "eq" (Lit (DA (5::Int))) (Ref "x")) ([("x",DA (4::Int))],[])
--   Just False


-- | Statement Evaluation Function Tests
--
--   >>> stmt (Set "x" (Lit (DA (4::Int)))) ([],[])
--   Just ([("x",4)],[])
--
--   >>> stmts [Set "x" (Lit (DA (4::Int))), Set "y" (Lit (DA True))] ([],[])
--   Just ([("y",True),("x",4)],[])
--
--   >>> stmt (If (Lit (DA True)) [Set "x" (Lit (DA False))]) ([],[])
--   Just ([("x",False)],[])
--
--   >>> stmt (Def "addInts" addFunc) ([],[])
--   Just ([],[("addInts",[Set "ret" (Prim "add" (Ref "i1") (Ref "i2")),Ret (Ref "ret")])])
--
--   >>> stmts (callBinaryFunc (5::Int) (6::Int) addFunc) ([],[])
--   Just ([("ret",11),("i2",6),("i1",5)],[("fun",[Set "ret" (Prim "add" (Ref "i1") (Ref "i2")),Ret (Ref "ret")])])
--
--   >>> stmt (If (Lit (DA (5::Int))) [Set "x" (Lit (DA False))]) ([],[])
--   Nothing
--  
--   Try to add an integer and a boolean
--   >>> stmts (callBinaryFunc (5::Int) (True) addFunc) ([],[])
--   Nothing 
--
--   Call a function without a return statement in a list of stmts
--   >>> stmts [Def "function" [Set "x" (Lit (DA False))], Set "y" (Call "function" [])] ([],[])
--   Nothing 
--
--   >>> stmts [Set "y" (Lit (DA True)), While (Ref "y") [Set "y" (Lit (DA False))]] ([],[])
--   Just ([("y",False),("y",True)],[])
--


-- | Sample Programs Tests
--
--   >>> runFun prog1 ([], [])
--   Just 10
-- 
--   >>> runFun prog2 ([], [])
--   Just 1
--
--   >>> runFun prog3 ([], [])
--   Just 105
--
--   Call a function without a return statement
--   >>> runFun (callBinaryFunc (1::Int) (2::Int) addFunc) ([], [])
--   Nothing
