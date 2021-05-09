{-# LANGUAGE ExistentialQuantification #-}

module RoySyntax where

import Data.Typeable

class (Show a, Typeable a) => RoyDataType a where
    litParserSymbol :: a -> String -- Doesn't like it when you don't use a in the type so just a placeholder to have it there for now.
    parseFunction :: String -> Maybe a

data DVal = forall a . RoyDataType a => DA a

instance Show DVal where
    show (DA a) = show a

type Var = String
type Env = [(Var,DVal)]

type PrimOp a = a -> a -> a

data Expr a = Lit a
            | Prim (PrimOp a) (Expr a) (Expr a)
            | Ref Var
