module RoySemantics where

import RoySyntax
import Text.Read
import Data.Typeable

--
-- Primitive Data Types and Operations
--

instance RoyDataType Int where
    litParserSymbol _ = "Int "
    parseFunction = readMaybe


add :: PrimOp Int
add = (+)

--
-- Evaluation Functions
--

eval :: RoyDataType a => Expr a -> a
eval (Lit x) = x
eval (Prim f x y) = f (eval x) (eval y) 
