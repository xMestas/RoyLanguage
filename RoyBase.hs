module RoyBase where

import RoySyntax

import Text.ParserCombinators.Parsec
import Text.Read
import Data.Dynamic

instance RoyDataType Int where
    litParserInfo _ = ("Int",parseInt)
    primOps _       = [addOp, inteqOp]

parseInt :: Parser DVal 
parseInt = do
         n <- many1 digit
         return (DA (read n::Int))

add :: Int -> Int -> Int
add = (+)

addOp :: PrimOp
addOp = createOp "add" add

inteq :: Int -> Int -> Bool
inteq = (==)

inteqOp :: PrimOp
inteqOp = createOp "eq" inteq

instance RoyDataType Bool where
    litParserInfo _ = ("Bool",parseBool)
    primOps _       = [booleqOp]

parseBool :: Parser DVal
parseBool = (string "True" >> return (DA True))
            <|> (string "False" >> return (DA False))

booleq :: Bool -> Bool -> Bool
booleq = (==)

booleqOp :: PrimOp
booleqOp = createOp "eq" booleq
