module Main where

import System.IO
import System.Environment

import RoyParser
import RoySemantics

main :: IO ()
main = do
     args <- getArgs
     let fn = head args 
     f <- openFile fn ReadMode
     progString <- hGetContents f
     case parseProg progString of
         (Right ast) -> print (stmts ast ([],[]))
         (Left err) -> print (err)
     hClose f
