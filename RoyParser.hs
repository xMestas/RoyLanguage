module RoyParser where

import Text.ParserCombinators.Parsec

import RoySyntax
import RoyBase

-- List of all info needed for the parser for each RoyDataType.
-- TODO: Currently the user must add their custom data types to this list here.
--   Would be better if this list was generated.
litParseList :: [(String, Parser DVal)]
litParseList = [litParserInfo (1::Int), litParserInfo True]

-- Helper function to run a parser on an input.
runParse :: Parser a -> String -> Either ParseError a
runParse p i = parse p "(Unknown)" i

-- Helper function to generate a literal parser from a data type definition
genLitParser :: (String,Parser DVal) -> Parser Expr
genLitParser (s,p) = do 
                   string s
                   char ' '
                   v <- p
                   return (Lit v)

-- Parse a literal value
parseLit :: Parser Expr
parseLit = string "$ " >> choice (map genLitParser litParseList)

-- Parse a variable name
parseVar :: Parser String
parseVar = string "var " >> many1 (choice [digit, letter, char '_'])

-- Parse a variable reference
parseRef :: Parser Expr
parseRef = do
         string "ref "
         v <- parseVar
         return (Ref v)

-- Parse a function call
parseCall :: Parser Expr
parseCall = do
          string "call "
          fn <- parseVar
          char '('
          vs <- sepBy parseVar (char ',')
          char ')'
          return (Call fn vs)

-- Parse an expression
parseExpr :: Parser Expr
parseExpr = choice [parseLit, parseRef, parseCall, parsePrim]

-- Parse a primitive operation
primOpList :: [String]
primOpList = ["add", "eq"]

parsePrim :: Parser Expr
parsePrim = do
    string "op "
    op <- choice (map string primOpList)
    skipMany1 space
    char '('
    e1 <- parseExpr
    char ','
    skipMany1 space
    e2 <- parseExpr
    char ')'
    return (Prim op e1 e2)
