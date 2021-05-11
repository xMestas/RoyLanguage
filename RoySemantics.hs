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
    parseFunction     = readMaybe
    primOps _         = [add]

add :: PrimOp Int
add = ("add",(+))

readBool :: String -> Maybe Bool
readBool ("True")  = Just True
readBool ("False") = Just False
readBool _         = Nothing

instance RoyDataType Bool where
    litParserSymbol _ = "Bool "
    parseFunction     = readBool
    primOps _         = [eq]

eq :: PrimOp Bool
eq = ("eq",(==))

--
-- Helper Functions
--
getOp :: String -> PrimOp a -> Maybe (a -> a -> a)
getOp n (on, f) = if n == on then Just f else Nothing

findJust :: [Maybe (a -> a -> a)] -> (a -> a -> a)
findJust ((Nothing):ls) = findJust ls
findJust ((Just f):_)   = f

filterEnv :: [Var] -> (Var,DVal) -> Bool
filterEnv vs (c,_) = elem c vs

runFun :: Func -> (Env,FuncEnv) -> DVal
runFun ((Ret e):_) m = eval e m
runFun (s:ss) m      = runFun ss (stmt s m)

--
-- Evaluation Functions
--

eval :: Expr -> (Env,FuncEnv) -> DVal
eval (Lit x) _           = x
eval (Prim n x y) m      = case (eval x m, eval y m) of
                                (DA x1, DA y1) -> DA $ (findJust (map (getOp n) (primOps x1))) (fromJust (cast x1)) (fromJust (cast y1))
eval (Ref x) (m,_)       = case (lookup x m) of (Just v) -> v
eval (Call fn vs) (m,fm) = case (lookup fn fm) of (Just f) -> runFun f (filter (filterEnv vs) m, fm)

stmt :: Stmt -> (Env,FuncEnv) -> (Env,FuncEnv)
stmt (Set v e) (m,fm)  = ((v,eval e (m,fm)):m,fm)
stmt (If e ss) m       = case (eval e m) of (DA x) -> if fromJust (cast x) then stmts ss m else m
stmt (Def v ss) (m,fm) = (m,(v,ss):fm)

stmts :: [Stmt] -> (Env,FuncEnv) -> (Env,FuncEnv)
stmts (s:ss) m = stmts ss (stmt s m)
stmts [] m     = m

--
-- Eval' w/ Runtime typecheck
--

runFun' :: Func -> (Env,FuncEnv) -> Maybe DVal
runFun' (Ret e:_) m  = eval' e m
runFun' (s:ss)    m  = stmt' s m >>= runFun' ss

findJust' :: [Maybe (a -> a -> a)] -> Maybe (a -> a -> a)
findJust' [Nothing]    = Nothing
findJust' (Nothing:ls) = findJust' ls
findJust' (Just f:_)   = Just f

eval' :: Expr -> (Env,FuncEnv) -> Maybe DVal
eval' (Lit x) _           = Just x
eval' (Prim n x y) m      = do DA x1 <- eval' x m 
                               DA y1 <- eval' y m
                               op    <- findJust' $ map (getOp n) (primOps x1)
                               return DA <*> (op <$> cast x1 <*> cast y1)
eval' (Ref x) (m,_)       = lookup x m
eval' (Call fn vs) (m,fm) = flip runFun' (filter (filterEnv vs) m, fm) <$> lookup fn fm >>= id

stmt' :: Stmt -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmt' (Set v e) (m,fm)  = eval' e (m,fm) >>= \x -> Just ((v,x):m,fm)
stmt' (If e ss) m       = do DA x <- eval' e m
                             c    <- cast x
                             if c then stmts' ss m else Just m
stmt' (Def v ss) (m,fm) = Just (m,(v,ss):fm)

stmts' :: [Stmt] -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmts' (s:ss) m = stmt' s m >>= stmts' ss
stmts' [] m     = Just m
