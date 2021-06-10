module RoySemantics where

import RoySyntax
import Data.Typeable 
import Data.Dynamic
import Data.Foldable

import Control.Monad
import Control.Monad.Reader
import Control.Monad.Trans
import Control.Monad.Trans.Maybe

--
--  Evaluation Helper Functions
--

getOp :: String -> PrimOp -> Maybe Dynamic
getOp n (on, f) = if n == on then Just f else Nothing

--
-- Expression Evaluation Function
--

tryApply :: OpName -> DVal -> DVal -> Maybe DVal
tryApply n (DA a) (DA b) = do op    <- asum $ map (getOp n) (primOps a)
                              f1    <- dynApply op (toDyn a)
                              f2    <- dynApply f1 (toDyn b)
                              fromDynamic f2

evalM :: Expr -> ReaderT (Env,FuncEnv) Maybe DVal
evalM (Lit x)       = return $ x
evalM (Prim n x y)  = do x1 <- evalM x
                         x2 <- evalM y
                         lift $ tryApply n x1 x2
evalM (Ref x)       = ask >>= \(m,_) -> lift $ lookup x m
evalM (Call fn vs)  = do (_, fm) <- ask
                         ss      <- lift $ lookup fn fm
                         (a, b)  <- stmtsM ss
                         local (\_ -> (a,b)) $ evalM (Ref "_ret")

eval :: Expr -> (Env,FuncEnv) -> Maybe DVal
eval = runReaderT . evalM 

--
-- Statement Evaluation Functions
--

stmtM :: Stmt -> ReaderT (Env,FuncEnv) Maybe (Env,FuncEnv)
stmtM (Set v e)    = do (m,fm) <- ask
                        x      <- evalM e
                        return ((v,x):m,fm)
stmtM (If e ss)    = do DA x <- evalM e
                        c    <- lift $ cast x
                        if c then stmtsM ss else ask
stmtM (While e ss) = do DA x <- evalM e
                        c    <- lift $ cast x
                        if c then stmtsM (ss++[(While e ss)]) else ask
stmtM (Def v ss)   = ask >>= \(m,fm) -> return (m,(v,ss):fm)

stmt :: Stmt -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmt = runReaderT . stmtM

stmtsM :: [Stmt] -> ReaderT (Env,FuncEnv) Maybe (Env,FuncEnv)
stmtsM (Ret e:_) = stmtM (Set "_ret" e)
stmtsM (s:ss)    = stmtM s >>= \(a,b) -> local (\_ -> (a,b)) (stmtsM ss)
stmtsM []        = ask

stmts :: [Stmt] -> (Env,FuncEnv) -> Maybe (Env,FuncEnv)
stmts = runReaderT . stmtsM

getRet :: Maybe (Env,FuncEnv) -> Maybe DVal
getRet (Just e)  = eval (Ref "_ret") e
getRet Nothing   = Nothing
