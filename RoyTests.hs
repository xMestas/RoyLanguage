module RoyTests where

import RoySyntax
import RoySemantics

addFunc :: Func
addFunc = [Set "ret" (Prim "add" (Ref "i1") (Ref "i2")), Ret (Ref "ret")]

quickCall :: (RoyDataType a, RoyDataType b) => a -> b -> Func -> Func 
quickCall x y f = [Set "i1" (Lit (DA x)), Set "i2" (Lit (DA y)), Def "fun" f, Set "ret" (Call "fun" ["i1", "i2"])]

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
--   >>> stmts (quickCall (5::Int) (6::Int) addFunc) ([],[])
--   Just ([("ret",11),("i2",6),("i1",5)],[("fun",[Set "ret" (Prim "add" (Ref "i1") (Ref "i2")),Ret (Ref "ret")])])
--
--   >>> stmt (If (Lit (DA (5::Int))) [Set "x" (Lit (DA False))]) ([],[])
--   Nothing
--
--   >>> stmts (quickCall (5::Int) (True) addFunc) ([],[])
--   Nothing 
--
--   >>> stmts [Set "y" (Lit (DA True)), While (Ref "y") [Set "y" (Lit (DA False))]] ([],[])
--   Just ([("y",False),("y",True)],[])
--
