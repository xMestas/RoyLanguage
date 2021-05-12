module RoyBase where

import RoySyntax
import Text.Read
import Data.Dynamic

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
