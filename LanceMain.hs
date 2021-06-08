module Main where

import System.IO
import System.Environment

import LanceParser
import RoySemantics

main :: IO ()
main = do
     args <- getArgs
     let fn = head args
     case fn of
         "-getRet" -> do 
                        let fn = head (tail args)
                        f <- openFile fn ReadMode
                        progString <- hGetContents f
                        case parseProg progString of
                            Right ast -> print (getRet (stmts ast ([],[])))
                            Left err  -> print err
                        hClose f
         _        -> do 
                        f <- openFile fn ReadMode
                        progString <- hGetContents f
                        case parseProg progString of
                            Right ast -> print (stmts ast ([],[]))
                            Left err  -> print err
                        hClose f
     
