{-|
Module: MachineLearning.Regression.Model
Description: Regression Model
Copyright: (c) Alexander Ignatyev, 2016
License: BSD-3
Stability: experimental
Portability: POSIX

Regression Model type class.

-}

module MachineLearning.Regression.Model
(
  Model(..)
)

where

import Types

class Model a where
  -- | Hypothesis function.
  -- Takes X (m x n) and theta (n x 1), returns y (m x 1).
  hypothesis :: a -> Matrix -> Vector -> Vector
  
  -- | Cost function J(Theta)
  -- It takes regularizarion parameter lambda, matrix X (m x n), vector y (m x 1) and vector theta (n x 1).
  cost :: a -> R -> Matrix -> Vector -> Vector -> R

  -- | Gradient function.
  -- It takes regularizarion parameter lambda, X (m x n), y (m x 1) and theta (n x 1).
  -- Returns vector of gradients (n x 1).
  gradient :: a -> R -> Matrix -> Vector -> Vector -> Vector

