module Test.HUnit.Plus
(
    assertMaybeDouble
  , assertOnFunction
  , assertVector
)
where

import Control.Monad
import Test.HUnit
import Test.HUnit.Approx
import Numeric.LinearAlgebra

assertMaybeDouble :: Maybe Double -> Maybe Double -> Double -> Assertion
assertMaybeDouble Nothing Nothing _ = assertString ""
assertMaybeDouble expected Nothing _ = assertString msg
  where msg = "expected: " ++ show expected ++ "\nbut got: Nothing"
assertMaybeDouble Nothing actual _ = assertString msg
  where msg = "expected: Nothing\nbit got: " ++ show actual
assertMaybeDouble (Just expected) (Just actual) eps = assertApproxEqual "Maybe Double" eps expected actual

assertOnFunction :: (Eq b, Show b) => (a -> b) -> a -> a -> Assertion
assertOnFunction func expected actual = func expected @=? func actual

assertVector :: R -> Vector R -> Vector R -> Assertion
assertVector eps expected actual =
  let diff = norm_2 (expected-actual)
      msg = "expected: " ++ show expected ++ "\nbut got" ++ show actual
  in unless (diff < eps) (assertFailure msg)

