{-|
Module: MachineLearning.MultiSvmClassifier
Description: Multiclass Support Vector Machines Classifier.
Copyright: (c) Alexander Ignatyev, 2017.
License: BSD-3
Stability: experimental
Portability: POSIX

Multicalss Support Vector Machines Classifier.
-}

module MachineLearning.MultiSvmClassifier
(
  module MachineLearning.Model
  , module MachineLearning.Classification.MultiClass
  , MultiSvmModel(..)
)

where

import qualified Numeric.LinearAlgebra as LA
import Numeric.LinearAlgebra((<>), (<.>), (|||))
import qualified Data.Vector.Storable as V

import qualified MachineLearning as ML
import MachineLearning.Types (R, Vector, Matrix)
import MachineLearning.Model
import MachineLearning.Classification.MultiClass


-- | Multiclass SVM Classifier, takes delta and number of futures. Delta = 1.0 is good for all cases.
data MultiSvmModel = MultiSvm R Int


instance Classifier MultiSvmModel where
  cscore _ x theta = x <> (LA.tr theta)

  chypothesis m x theta = LA.vector predictions
    where scores = cscore m x theta
          scores' = LA.toRows scores
          predictions = map (fromIntegral . LA.maxIndex) scores'

  ccost m@(MultiSvm d _) lambda x y theta =
    let nSamples = fromIntegral $ LA.rows x
        scores = cscore m x theta
        correct_scores = LA.remap (LA.asColumn $ V.fromList [0..(fromIntegral $ LA.rows x)-1]) (LA.toInt $ LA.asColumn y) scores
        margins = scores - (correct_scores - (LA.scalar d))
        margins' = LA.cmap (\e -> max 0 e) margins
        loss = LA.sumElements(margins') / nSamples - d
        thetaReg = ML.removeBiasDimension theta
        reg = (LA.norm_2 thetaReg) * 0.5 * lambda / nSamples
    in loss + reg

  cgradient m@(MultiSvm d _) lambda x y theta =
    let nSamples = fromIntegral $ LA.rows x
        ys = processOutput m y
        scores = cscore m x theta
        correct_scores = LA.remap (LA.asColumn $ V.fromList [0..(fromIntegral $ LA.rows x)-1]) (LA.toInt $ LA.asColumn y) scores
        margins = scores - (correct_scores - (LA.scalar d))
        margins' = (1-ys)*(LA.step margins)  -- step == cmap (\x -> if x>0 then 1 else 0)
        k = sumByRows margins'
        margins'' = margins' - (ys * k)
        dw = ((LA.tr margins'') <> x) / nSamples
        thetaReg = 0 ||| (ML.removeBiasDimension theta)
        reg = ((LA.scalar lambda) * thetaReg) / nSamples
     in dw + reg

  cnumClasses (MultiSvm _ nLabels) = nLabels


sumByRows :: Matrix -> Matrix
sumByRows x = LA.asColumn . LA.vector $ map V.sum $ LA.toRows x
