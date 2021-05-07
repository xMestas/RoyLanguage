module RoySemantics where

import RoySyntax

--
-- Primitive Data Types and Operations
--

add :: PrimOp Int
add = (+)

--
-- Evaluation Functions
--

eval :: Expr a -> a
eval (Lit x) = x
eval (Prim f x y) = f x y
