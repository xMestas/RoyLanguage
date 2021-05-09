{-# LANGUAGE ExistentialQuantification #-}

module RoyTests where

import RoySyntax
import RoySemantics

-- | Expression Evaluation Function Tests
--
--   >>> eval (Lit (4::Int))
--   4
--
--   >>> eval (Prim add (Lit (3::Int)) (Lit (4::Int)))
--   7
