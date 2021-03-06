module LanceParser where

import Text.ParserCombinators.Parsec
import System.IO
import Data.Matrix

import RoySyntax
import RoyBase

import Lance

-- List of all info needed for the parser for each RoyDataType.
-- TODO: Currently the user must add their custom data types to this list here.
--   Would be better if this list was generated.
litParseList :: [(String, Parser DVal)]
litParseList = [litParserInfo (1::Int), litParserInfo True, litParserInfo (fromLists [[1::Int]])]

-- List of all prim ops in the current program for all RoyDataTypes.
-- TODO: Currently the user must add their custom data types to this list here.
--   Would be better if this list was generated.
primOpList :: [PrimOp]
primOpList = primOps (1::Int) ++ primOps True ++ primOps (fromLists [[1::Int]])

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
          -- string "op "
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

-- Parse function definitions
parseDef :: Parser Stmt
parseDef = do
         string "def "
         fn <- parseVar
         parseWhitespace
         string "{\n"
         inst <- parseStmts
         char '}'
         return (Def fn inst)

-- Parse an if statement 
parseIf :: Parser Stmt
parseIf = do
        string "if ("
        optional parseWhitespace
        cond <- parseExpr
        optional parseWhitespace
        char ')'
        optional parseWhitespace
        string "{\n"
        inst <- parseStmts
        char '}'
        return (If cond inst)

-- Parse a while statement 
parseWhile :: Parser Stmt
parseWhile = do
           string "while ("
           optional parseWhitespace
           cond <- parseExpr
           optional parseWhitespace
           char ')'
           optional parseWhitespace
           string "{\n"
           inst <- parseStmts
           char '}'
           return (While cond inst)

-- Parse a statement
parseStmt :: Parser Stmt
parseStmt = choice [parseSet, parseRet, parseDef, parseIf, parseWhile]

-- Parse multiple statements seperated by newlines
parseStmts :: Parser [Stmt]
parseStmts = optional parseWhitespace >> endBy (parseStmt) (optional parseWhitespace >> many1 (char '\n') >> optional parseWhitespace)

parseProg :: String -> (Either ParseError [Stmt])
parseProg s = runParse parseStmts s
