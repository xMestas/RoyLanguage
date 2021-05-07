module RoySyntax where

type PrimOp a = a -> a -> a

data Expr a = Lit a
            | Prim (PrimOp a) a a
