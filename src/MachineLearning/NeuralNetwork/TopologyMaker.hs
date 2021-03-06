{-|
Module: MachineLearning.NeuralNetwork.TopologyMaker
Description: Topology Maker
Copyright: (c) Alexander Ignatyev, 2017
License: BSD-3
Stability: experimental
Portability: POSIX

Topology Maker.
-}

module MachineLearning.NeuralNetwork.TopologyMaker
(
  Activation(..)
  , Loss(..)
  , makeTopology
)

where


import qualified MachineLearning.NeuralNetwork.Topology as T
import MachineLearning.NeuralNetwork.Layer (Layer(..), affineForward, affineBackward)
import MachineLearning.NeuralNetwork.WeightInitialization (nguyen)
import qualified MachineLearning.NeuralNetwork.ReluActivation as Relu
import qualified MachineLearning.NeuralNetwork.TanhActivation as Tanh
import qualified MachineLearning.NeuralNetwork.SigmoidActivation as Sigmoid
import qualified MachineLearning.NeuralNetwork.SoftmaxLoss as Softmax
import qualified MachineLearning.NeuralNetwork.MultiSvmLoss as MultiSvm
import qualified MachineLearning.NeuralNetwork.LogisticLoss as Logistic


data Activation = ASigmoid | ARelu | ATanh

data Loss = LLogistic | LSoftmax | LMultiSvm


-- | Creates toplogy. Takes number of inputs, number of outputs and list of hidden layers.
makeTopology :: Activation -> Loss -> Int -> Int -> [Int] -> T.Topology
makeTopology a l nInputs nOutputs hlUnits = T.makeTopology nInputs hiddenLayers outputLayer (loss l)
  where hiddenLayers = map (mkAffineLayer a) hlUnits
        outputLayer = mkOutputLayer l nOutputs


mkAffineLayer a nUnits = Layer {
  lUnits = nUnits
  , lForward = affineForward
  , lActivation = hiddenActivation a
  , lBackward = affineBackward
  , lActivationGradient = hiddenGradient a
  , lInitializeThetaM = nguyen
  }


mkOutputLayer l nUnits = Layer {
  lUnits = nUnits
  , lForward = affineForward
  , lActivation = outputActivation l
  , lBackward = affineBackward
  , lActivationGradient = outputGradient l
  , lInitializeThetaM = nguyen
  }


hiddenActivation ASigmoid = Sigmoid.sigmoid
hiddenActivation ARelu = Relu.relu
hiddenActivation ATanh = Tanh.tanh


hiddenGradient ASigmoid = Sigmoid.gradient
hiddenGradient ARelu = Relu.gradient
hiddenGradient ATanh = Tanh.gradient


outputActivation LLogistic = Logistic.scores
outputActivation LSoftmax = Softmax.scores
outputActivation LMultiSvm = MultiSvm.scores


outputGradient LLogistic = Logistic.gradient
outputGradient LSoftmax = Softmax.gradient
outputGradient LMultiSvm = MultiSvm.gradient


loss LLogistic = Logistic.loss
loss LSoftmax = Softmax.loss
loss LMultiSvm = MultiSvm.loss
