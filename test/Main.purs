module Test.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Except (runExcept)
import Data.Array (head)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Simple.JSON (read, write)
import Skill (Game(..))
import Test.Unit (failure, success, suite, test)
import Test.Unit.Assert (equal) as Assert
import Test.Unit.Main (runTest)



main :: Eff _ Unit
main = runTest do
  suite "Game" do
     test "encodeUnstarted" do
        let result = read <<< write $ Unstarted
        case runExcept (result) of
          Right Unstarted → success
          Right _ → failure "Unstarted was decoded into the wrong Game"
          Left _ → failure "Unstarted could not be decoded into a Game"
     test "encodeGuessed" do
        let result = read <<< write $ Guessed { guess : "foo", prevGuesses : [{ n : 3, word: "bar"}]}
        case runExcept (result) of
          Left _ → failure "Guessed could not be decoded into a Game"
          Right (Guessed { guess : g, prevGuesses : p}) → do
            Assert.equal g "foo"
            case head p of
              Nothing → failure "Guessed was decoded into the wrong Game"
              Just g1 → do
                Assert.equal g1.n 3
                Assert.equal g1.word "bar"
          Right _ → failure "Guessed was decoded into the wrong Game"
