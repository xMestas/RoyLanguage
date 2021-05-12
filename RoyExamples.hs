module RoyExamples where

import RoySyntax
import RoySemantics
import RoyBase

-- Function examples

-- A function which returns the sum of two arguments
addFunc :: Func
addFunc = [Set "ret" (Prim "add" (Ref "i1") (Ref "i2")), Ret (Ref "ret")]

-- Generate a function that calls a binary function with arguments
callBinaryFunc :: (RoyDataType a, RoyDataType b) => a -> b -> Func -> Func 
callBinaryFunc x y f = [Set "i1" (Lit (DA x)), 
                        Set "i2" (Lit (DA y)), 
                        Def "fun" f, 
                        Set "ret" (Call "fun" ["i1", "i2"])]

-- A sub function that takes a number and return a sum of series of 5 numbers
seriesSum :: Func
seriesSum = [Set "count" (Lit (DA (0::Int))),
             Set "test" (Lit (DA (True))),
             While (Ref "test") 
                [Set "x" (Prim "add" (Ref "x") (Lit (DA (1::Int)))),
                 Set "count" (Prim "add" (Ref "count") (Lit (DA (1::Int)))),
                 If (Prim "eq" (Ref "count") (Lit (DA (5::Int)))) [Set "test" (Lit (DA (False)))]],
             Ret (Ref "x")]

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
prog2 = callBinaryFunc (-100::Int) (101::Int) addFunc ++ [Ret (Ref "ret")]
        
-- Sample program #3
-- This calls 'seriesSum' function
prog3 :: Func
prog3 = [Set "x" (Lit (DA (100::Int))),
         Def "seriesSum" seriesSum,
         Ret (Call "seriesSum" ["x"])]