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

eval :: Expr -> (Env,FuncEnv) -> DVal
eval (Lit x) _ = x
eval (Prim n x y) m = case (eval x m, eval y m) of
                          (DA x1, DA y1) -> DA ((findJust (map (getOp n) (primOps x1))) (fromJust (cast x1)) (fromJust (cast y1)))
eval (Ref x) (m,_) = case (lookup x m) of (Just v) -> v

stmt :: Stmt -> (Env,FuncEnv) -> (Env,FuncEnv)
stmt (Set v e) (m,fm) = ((v,eval e (m,fm)):m,fm)
stmt (If e ss) m = case (eval e m) of (DA x) -> if fromJust (cast x) then stmts ss m else m
stmt (Def v ss) (m,fm) = (m,(v,ss):fm)

stmts :: [Stmt] -> (Env,FuncEnv) -> (Env,FuncEnv)
stmts (s:ss) m = stmts ss (stmt s m)
stmts [] m = m
