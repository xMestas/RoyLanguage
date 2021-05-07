module RoyTests where

import RoySyntax
import RoySemantics

-- | Expression Evaluation Function Tests
--
--   >>> eval (Lit 4)
--   4
--
--   >>> eval (Prim add 3 4)
--   7
