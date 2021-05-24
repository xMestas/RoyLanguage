module RoyParser where

import Text.ParserCombinators.Parsec

import RoySyntax
import RoyBase

-- List of all info needed for the parser for each RoyDataType.
-- TODO: Currently the user must add their custom data types to this list here.
--   Would be better if this list was generated.
litParseList :: [(String, Parser DVal)]
litParseList = [litParserInfo (1::Int), litParserInfo True]

-- List of all prim ops in the current program for all RoyDataTypes.
-- TODO: Currently the user must add their custom data types to this list here.
--   Would be better if this list was generated.
primOpList :: [PrimOp]
primOpList = primOps (1::Int) ++ primOps True 

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

-- Parse whitespace
parseWhitespace :: Parser String
parseWhitespace = many1 (oneOf " \t")

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
          optional parseWhitespace
          vs <- sepBy (parseVar) (optional parseWhitespace >> char ',' >> optional parseWhitespace)
          optional parseWhitespace
          char ')'
          return (Call fn vs)

-- Parse a primitive op
parsePrim :: Parser Expr
parsePrim = do
    string "op "
    op <- choice (map (string . fst) primOpList)
    parseWhitespace
    char '('
    optional parseWhitespace
    e1 <- parseExpr
    optional parseWhitespace
    char ','
    optional parseWhitespace
    e2 <- parseExpr
    optional parseWhitespace
    char ')'
    return (Prim op e1 e2)

-- Parse an expression
parseExpr :: Parser Expr
parseExpr = choice [parseLit, parseRef, parseCall, parsePrim]


-- Parse a set statement
parseSet :: Parser Stmt
parseSet = do 
         string "set "
         var <- parseVar
         string " = "
         val <- parseExpr
         return (Set var val)

-- Parse a ret statement
parseRet :: Parser Stmt
parseRet = do
         string "ret "
         val <- parseExpr
         return (Ret val)

-- Parse a statement
parseStmt :: Parser Stmt
parseStmt = choice [parseSet, parseRet]

parseStmts :: Parser [Stmt]
parseStmts = sepBy (parseStmt) (optional parseWhitespace >> char '\n' >> optional parseWhitespace)
