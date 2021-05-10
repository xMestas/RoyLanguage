module RoyTests where

import RoySyntax
import RoySemantics

addFunc :: Func
addFunc = [Set "ret" (Prim "add" (Ref "i1") (Ref "i2"))]

-- | Expression Evaluation Function Tests
--
--   >>> eval (Lit (DA (4::Int))) ([],[])
--   4
--
--   >>> eval (Prim "add" (Lit (DA (3::Int))) (Lit (DA (4::Int)))) ([],[])
--   7
--
--   >>> eval (Ref "x") ([("x",DA (5::Int))],[])
--   5
--
--   >>> eval (Prim "add" (Lit (DA (3::Int))) (Ref "x")) ([("x",DA (5::Int))],[])
--   8
--
--   >>> eval (Prim "eq" (Lit (DA (True))) (Lit (DA (False)))) ([],[])
--   False

-- | Statement Evaluation Function Tests
--
--   >>> stmt (Set "x" (Lit (DA (4::Int)))) ([],[])
--   ([("x",4)],[])
--
--   >>> stmts [Set "x" (Lit (DA (4::Int))), Set "y" (Lit (DA True))] ([],[])
--   ([("y",True),("x",4)],[])
--
--   >>> stmt (If (Lit (DA True)) [Set "x" (Lit (DA False))]) ([],[])
--   ([("x",False)],[])
--
--   >>> stmt (Def "addInts" addFunc) ([],[])
--   ([],[("addInts",[Set "ret" (Prim "add" (Ref "i1") (Ref "i2"))])])
