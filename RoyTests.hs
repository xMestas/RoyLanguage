module RoyTests where

import RoySyntax
import RoySemantics

-- | Expression Evaluation Function Tests
--
--   >>> eval (Lit (DA (4::Int))) []
--   4
--
--   >>> eval (Prim "add" (Lit (DA (3::Int))) (Lit (DA (4::Int)))) []
--   7
--
--   >>> eval (Ref "x") [("x",DA (5::Int))]
--   5
--
--   >>> eval (Prim "add" (Lit (DA (3::Int))) (Ref "x")) [("x",DA (5::Int))]
--   8
