module RoyTests where

import RoySyntax
import RoySemantics

addFunc :: Func
addFunc = [Set "ret" (Prim "add" (Ref "i1") (Ref "i2")), Ret (Ref "ret")]

quickCall :: (RoyDataType a, RoyDataType b) => a -> b -> Func -> Func 
quickCall x y f = [Set "i1" (Lit (DA x)), Set "i2" (Lit (DA y)), Def "fun" f, Set "ret" (Call "fun" ["i1", "i2"])]

quickCall2 :: (RoyDataType a, RoyDataType b) => a -> b -> Func -> Func 
quickCall2 x y f = [Set "i1" (Lit (DA x)), 
                    Set "i2" (Lit (DA y)), 
                    Def "fun" f, 
                    Set "ret" (Call "fun" ["i1", "i2"]),
                    Ret (Ref "ret")]

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

-- Sample program #1
--  x := 0
--  y := True
--  z := -10
--  while (y = True)
--  {
--     x = x + 20
--     z = z + x 
--     y = False
--  }
--  return z

prog1 :: Func
prog1 = [Set "x" (Lit (DA (0::Int))),
         Set "y" (Lit (DA (True))),
         Set "z" (Lit (DA (-10::Int))),
         While (Ref "y") [Set "x" (Prim "add" (Ref "x") (Lit (DA (20::Int)))),
                          Set "z" (Prim "add" (Ref "z") (Ref "x")),
                          Set "y" (Lit (DA False))],
         Ret (Ref "z")]


-- Sample program #2
--  Program calls a function 'callsum' gets variable x and y, returns sum

prog2 :: Func
prog2 = [Set "x" (Lit (DA (-100::Int))),
         Set "y" (Lit (DA (101::Int))),
         Def "callsum" callsum,
         Ret (Call "callsum" ["x", "y"])]

callsum :: Func
callsum = [Ret (Prim "add" (Ref "x") (Ref "y"))]

-- | Test programs
--
--   >>> runFun prog1 ([], [])
--   Just 10
-- 
--   >>> runFun prog2 ([], [])
--   Just 1