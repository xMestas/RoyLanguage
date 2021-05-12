module RoySemantics where

import RoySyntax
import Text.Read
import Data.Typeable 
import Data.Maybe
import Data.Dynamic

--
-- Primitive Data Types and Operations
--

compose2 :: (c -> d) -> (a -> b -> c) -> a -> b -> d
compose2 = (.) . (.)

createOp :: (RoyDataType c, Typeable a, Typeable b) => s -> (a -> b -> c) -> (s, Dynamic)
createOp s f = (s, toDyn (compose2 DA f))

instance RoyDataType Int where
    litParserSymbol _ = "Int "
    parseFunction     = readMaybe
    primOps _         = [addOp, inteqOp]


add :: Int -> Int -> Int
add = (+)

addOp :: PrimOp
addOp = createOp "add" add

inteq :: Int -> Int -> Bool
inteq = (==)

inteqOp :: PrimOp
inteqOp = createOp "eq" inteq

readBool :: String -> Maybe Bool
readBool ("True")  = Just True
readBool ("False") = Just False
readBool _         = Nothing

instance RoyDataType Bool where
    litParserSymbol _ = "Bool "
    parseFunction     = readBool
    primOps _         = [booleqOp]

booleq :: Bool -> Bool -> Bool
booleq = (==)

booleqOp :: PrimOp
booleqOp = createOp "eq" booleq

--
--  Evaluation Helper Functions
--

getOp :: String -> PrimOp -> Maybe Dynamic
getOp n (on, f) = if n == on then Just f else Nothing

filterEnv :: [Var] -> (Var,DVal) -> Bool
filterEnv vs (c,_) = elem c vs

runFun :: Func -> (Env,FuncEnv) -> Maybe DVal
runFun (Ret e:_) m  = eval e m
runFun (s:ss)    m  = stmt s m >>= runFun ss

findJust :: [Maybe Dynamic] -> Maybe Dynamic
findJust [Nothing]    = Nothing
findJust (Nothing:ls) = findJust ls
findJust (Just f:_)   = Just f

--
-- Expression Evaluation Function
--

eval :: Expr -> (Env,FuncEnv) -> Maybe DVal
eval (Lit x) _           = Just x
eval (Prim n x y) m      = do  DA x1 <- eval x m 
                               DA y1 <- eval y m
                               op    <- findJust $ map (getOp n) (primOps x1)
                               f1    <- dynApply op (toDyn x1)
                               f2    <- dynApply f1 (toDyn y1)
                               fromDynamic f2
eval (Ref x) (m,_)       = lookup x m
eval (Call fn vs) (m,fm) = flip runFun (filter (filterEnv vs) m, fm) <$> lookup fn fm >>= id

--
-- Statement Evaluation Functions
--

stmt :: Stmt -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmt (Set v e) (m,fm)  = eval e (m,fm) >>= \x -> Just ((v,x):m,fm)
stmt (If e ss) m       = do DA x <- eval e m
                            c    <- cast x
                            if c then stmts ss m else Just m
stmt (While e ss) m    = do DA x <- eval e m
                            c    <- cast x
                            if c
                                then stmts ss m >>= stmts [(While e ss)]
                                else Just m
stmt (Def v ss) (m,fm) = Just (m,(v,ss):fm)

stmts :: [Stmt] -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmts (s:ss) m = stmt s m >>= stmts ss
stmts [] m     = Just m
