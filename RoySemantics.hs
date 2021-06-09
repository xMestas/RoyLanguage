module RoySemantics where

import RoySyntax
import Data.Typeable 
import Data.Dynamic
import Data.Foldable

--
--  Evaluation Helper Functions
--

getOp :: String -> PrimOp -> Maybe Dynamic
getOp n (on, f) = if n == on then Just f else Nothing

--
-- Expression Evaluation Function
--

eval :: Expr -> (Env,FuncEnv) -> Maybe DVal
eval (Lit x) _           = Just x
eval (Prim n x y) m      = do  DA x1 <- eval x m 
                               DA y1 <- eval y m
                               op    <- asum $ map (getOp n) (primOps x1)
                               f1    <- dynApply op (toDyn x1)
                               f2    <- dynApply f1 (toDyn y1)
                               fromDynamic f2
eval (Ref x) (m,_)       = lookup x m
eval (Call fn vs) (m,fm) = eval (Ref "_ret") <$> exec >>= id
    where exec = flip stmts (m, fm) <$> lookup fn fm >>= id

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
                            if c then stmts (ss++[(While e ss)]) m else Just m
stmt (Def v ss) (m,fm) = Just (m,(v,ss):fm)

stmts :: [Stmt] -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmts (Ret e:_) (m,fm) = eval e (m,fm) >>= \x -> Just (("_ret",x):m,fm)
stmts (s:ss) m         = stmt s m >>= stmts ss
stmts [] m             = Just m

getRet :: Maybe (Env,FuncEnv) -> Maybe DVal
getRet (Just e)  = eval (Ref "_ret") e
getRet Nothing   = Nothing
