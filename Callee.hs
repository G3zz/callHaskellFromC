{-# LANGUAGE ForeignFunctionInterface #-}
module Callee where

foreign export ccall helloFromHaskell :: IO ()

helloFromHaskell = print "Hello C, from Haskell!"
