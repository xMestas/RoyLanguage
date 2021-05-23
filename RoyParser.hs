module RoyParser where

import Text.ParserCombinators.Parsec

import RoySyntax
import RoyBase

-- Helper function to run a parser on an input.
runParse :: Parser a -> String -> Either ParseError a
runParse p i = parse p "(Unknown)" i

-- These should go to the data type I think.
parseInt :: Parser DVal 
parseInt = do
         n <- many1 digit
         return (DA (read n::Int))

parseBool :: Parser DVal
parseBool = (string "True" >> return (DA True))
            <|> (string "False" >> return (DA False))

intSym :: String
intSym = "Int"

boolSym :: String
boolSym = "Bool"

-- Helper function to generate a literal parser from a data type definition
genLitParser :: (String,Parser DVal) -> Parser Expr
genLitParser (s,p) = do 
                   string s
                   char ' '
                   v <- p
                   return (Lit v)

litParseList :: [(String, Parser DVal)]
litParseList = [(intSym, parseInt),(boolSym, parseBool)]

parseLit :: Parser Expr
parseLit = string "$ " >> choice (map genLitParser litParseList)
