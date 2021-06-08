{-# LANGUAGE FlexibleInstances #-}

module Lance where

import RoySyntax

import Text.ParserCombinators.Parsec
import Text.Read
import Data.Dynamic
import Data.Matrix

instance RoyDataType (Matrix Int) where
    litParserInfo _ = ("Mat",parseMat)
    primOps _       = [matAddOpp, matMulOpp]

parseInt :: Parser Int 
parseInt = do
         n <- many1 digit
         return (read n::Int)

parseArr :: Parser [Int]
parseArr = do
         char '['
         a <- sepBy (parseInt) (char ',')
         char ']'
         return a

parseArrArr :: Parser [[Int]]
parseArrArr = do
         char '['
         as <- sepBy (parseArr) (char ',')
         char ']'
         return as

parseMat :: Parser DVal
parseMat = do
         mat <- parseArrArr
         return (DA (fromLists mat))

matAdd :: Matrix Int -> Matrix Int -> Matrix Int
matAdd = elementwise (+)

matAddOpp :: PrimOp
matAddOpp = createOp "matadd" matAdd

matMul :: Matrix Int -> Matrix Int -> Matrix Int
matMul = multStd

matMulOpp :: PrimOp
matMulOpp = createOp "matmul" matMul
