{-# LANGUAGE GADTs                     #-}

module RoySyntax where

import Data.Typeable
import Data.Dynamic

class (Show a, Typeable a) => RoyDataType a where
    litParserSymbol :: a -> String -- Doesn't like it when you don't use a in the type so just a placeholder to have it there for now.
    parseFunction   :: String -> Maybe a
    primOps         :: a -> [(String, Dynamic)]

data DVal where 
    DA :: RoyDataType a => a -> DVal

instance Show DVal where
    show (DA a) = show a

type Var = String
type Env = [(Var,DVal)]

type OpName = String
type PrimOp = (OpName, Dynamic)

type Func = [Stmt]
type FuncEnv = [(Var,Func)]

data Expr = Lit DVal 
          | Prim OpName Expr Expr
          | Ref Var
          | Call Var [Var]
          deriving (Show)

data Stmt = Set Var Expr
          | If Expr [Stmt]
          | While Expr [Stmt]
          | Def Var Func
          | Ret Expr
          deriving (Show)

compose2 :: (c -> d) -> (a -> b -> c) -> a -> b -> d
compose2 = (.) . (.)

createOp :: (RoyDataType c, Typeable a, Typeable b) => s -> (a -> b -> c) -> (s, Dynamic)
createOp s f = (s, toDyn (compose2 DA f))
