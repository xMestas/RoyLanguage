{-# LANGUAGE ExistentialQuantification #-}

module RoySyntax where

class RoyDataType a where
    litParserSymbol :: a -> String -- Doesn't like it when you don't use a in the type so just a placeholder to have it there for now.
    parseFunction :: String -> a

data DVal = forall a . RoyDataType a => DA a 

type Var = String
type Env = [(Var,DVal)]

type PrimOp a = a -> a -> a

data Expr a = Lit a
            | Prim (PrimOp a) a a
