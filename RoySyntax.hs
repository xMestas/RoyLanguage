{-# LANGUAGE GADTs                     #-}

module RoySyntax where

import Data.Typeable
import Data.Dynamic

--
-- Data types that define the languages data types, allowing the language to be extensible
--

class (Show a, Typeable a) => RoyDataType a where
    litParserSymbol :: a -> String -- Doesn't like it when you don't use a in the type so just a placeholder to have it there for now.
    parseFunction   :: String -> Maybe a
    primOps         :: a -> [PrimOp]

data DVal where 
    DA :: RoyDataType a => a -> DVal

instance Show DVal where
    show (DA a) = show a

--
-- AST for the language
--

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

--
-- Helper functions for building PrimOps out of functions.
--

compose2 :: (c -> d) -> (a -> b -> c) -> a -> b -> d
compose2 = (.) . (.)

createOp :: (RoyDataType a, RoyDataType b, RoyDataType c) => Var -> (a -> b -> c) -> (Var, Dynamic)
createOp s f = (s, toDyn (compose2 DA f))
