module RoyExamples where

import RoySyntax
import RoySemantics
import RoyBase

-- Function examples

-- A function which returns the sum of two arguments
addFunc :: Func
addFunc = [Set "ret" (Prim "add" (Ref "i1") (Ref "i2")), Ret (Ref "ret")]

-- This is a helper function which calls a binary function. First two arguments are inputs for the binary function.
callBinaryFunc :: (RoyDataType a, RoyDataType b) => a -> b -> Func -> Func 
callBinaryFunc x y f = [Set "i1" (Lit (DA x)), 
                        Set "i2" (Lit (DA y)), 
                        Def "fun" f, 
                        Set "ret" (Call "fun" ["i1", "i2"]),
                        Ret (Ref "ret")]

-- A sub function that takes a number and return a sum of series of 5 numbers
seriesSum :: Func
seriesSum = [Set "count" (Lit (DA (0::Int))),
             Set "test" (Lit (DA (True))),
             While (Ref "test") 
                [Set "x" (Prim "add" (Ref "x") (Lit (DA (1::Int)))),
                 Set "count" (Prim "add" (Ref "count") (Lit (DA (1::Int)))),
                 If (Prim "eq" (Ref "count") (Lit (DA (5::Int)))) [Set "test" (Lit (DA (False)))]],
             Ret (Ref "x")]

getRet :: Maybe (Env,FuncEnv) -> Maybe DVal
getRet (Just e)  = eval (Ref "_ret") e
getRet Nothing   = Nothing

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
-- This program returns sum of two numbers. It uses 'addFunc' and 'callBinaryFunc'

prog2 :: Func
prog2 = callBinaryFunc (-100::Int) (101::Int) addFunc
        
-- Sample program #3
-- This calls 'seriesSum' function

prog3 :: Func
prog3 = [Set "x" (Lit (DA (100::Int))),
         Def "seriesSum" seriesSum,
         Ret (Call "seriesSum" ["x"])]


-- Concrete syntax examples for the parser to parse

concrete1 :: String
concrete1 = "def var foo {\n set var x = $ Int 34\n ret ref var x\n}\n\nset var worked = $ Bool False \nset var result = call var foo()\nif (eq (ref var result, $ Int 34 ) ) {\n  set var worked = $ Bool True \n}\n\n"

