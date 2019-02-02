{-# LANGUAGE ForeignFunctionInterface #-}
module Callee where

import Control.Monad

foreign export ccall helloFromHaskell :: IO ()

helloFromHaskell = print "Hello C, from Haskell!"

f = mapM (return Nothing) [0..3]
