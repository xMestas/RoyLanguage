module RoySemantics where

import RoySyntax
import Text.Read
import Data.Typeable 
import Data.Maybe

--
-- Primitive Data Types and Operations
--

instance RoyDataType Int where
    litParserSymbol _ = "Int "
    parseFunction = readMaybe
    primOps _ = [add]

add :: PrimOp Int
add = ("add",(+))

readBool :: String -> Maybe Bool
readBool ("True") = Just True
readBool ("False") = Just False
readBool _ = Nothing

instance RoyDataType Bool where
    litParserSymbol _ = "Bool "
    parseFunction = readBool
    primOps _ = [eq]

eq :: PrimOp Bool
eq = ("eq",(==))

--
-- Helper Functions
--
getOp :: String -> PrimOp a -> Maybe (a -> a -> a)
getOp n (on, f) = if n == on then Just f else Nothing

findJust :: [Maybe (a -> a -> a)] -> (a -> a -> a)
findJust ((Nothing):ls) = findJust ls
findJust ((Just f):_) = f

--
-- Evaluation Functions
--

eval :: Expr -> Env -> DVal
eval (Lit x) _ = x
eval (Prim n x y) m = case (eval x m, eval y m) of
                          (DA x1, DA y1) -> DA ((findJust (map (getOp n) (primOps x1))) (fromJust (cast x1)) (fromJust (cast y1)))
eval (Ref x) m = case (lookup x m) of (Just v) -> v

stmt :: Stmt -> Env -> Env
stmt (Set v e) m = (v,eval e m):m
