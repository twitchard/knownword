module Skill where

import Prelude

import Amazon.Alexa.Types (AlexaRequest(..), AlexaResponse, BuiltInIntent(..), Speech(..), readBuiltInIntent)
import Control.Monad.Aff (Aff)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Foreign (Foreign)
import Data.Int (fromString)
import Data.Maybe (Maybe(..), isNothing, maybe)
import Simple.JSON (class ReadForeign, class WriteForeign, read, write)

data Game
  = Unstarted
  | Guessed GuessedRec

type GuessedRec = { guess :: String, prevGuesses :: Array Guess }

instance wfGame :: WriteForeign Game where
  writeImpl Unstarted = write { name : "Unstarted" }
  writeImpl (Guessed rec) = write { name: "Guessed", rec }

instance rfGame :: ReadForeign Game where
  readImpl json = read json <#> \(x :: { name :: String, rec :: Maybe GuessedRec }) ->
    case x.rec of
      Nothing → Unstarted
      Just rec → Guessed rec

type Session = Maybe Game

type Guess = { word :: String, n :: Int }

data Input
  = Start
  | End
  | Help
  | Stop
  | Cancel
  | Ready
  | Noop
  | Number Int
  | CorrectGuess
  | ErrorInput String

type Output =
  { speech :: String
  , reprompt :: Maybe String
  , session :: Session
  }

readIntent :: String → Foreign → Input
readIntent intentName slots =
  case readBuiltInIntent intentName of
    Just AmazonHelpIntent → Help
    Just AmazonStopIntent → Stop
    Just AmazonCancelIntent → Cancel
    Just _ → ErrorInput $ "Unsupported built-in intent: " <> intentName
    Nothing → readCustomIntent
    where
      readCustomIntent
        | otherwise = ErrorInput $ "Unrecognized intent: " <> intentName
      number = case runExcept (read slots) of
        Right (r :: {"Num" :: { value :: String } }) → case fromString r."Num".value of
          Just n → n
          Nothing → 1
        Left _ → 1

handle :: ∀ e. Foreign → Foreign → Aff e (AlexaResponse Session)
handle event _ = do
  output <- case runExcept (read event) of
    Left _ → runSkill (ErrorInput "Couldn't read event") Nothing
    Right (LaunchRequest r) → runSkill Start Nothing
    Right (SessionEndedRequest r) → runSkill End Nothing
    Right (IntentRequest r) → runSkill (parsedIntent r) (parsedSession r.session.attributes)
  pure 
    { version : "1.0"
    , response : 
      { card : Nothing
      , outputSpeech : Just (Text output.speech)
      , reprompt : output.reprompt <#> \x → { outputSpeech : Text x }
      , shouldEndSession : isNothing output.session
      }
    , sessionAttributes: output.session
    }
  where
    parsedIntent r = readIntent r.request.intent.name r.request.intent.slots
    parsedSession attrs = case runExcept (read attrs) of
      Left _ → Nothing
      Right sess → sess

runSkill :: ∀ e. Input → Session → Aff e (Output)
runSkill = run
  where
    run Start _ = greet

    run _ _ = noop

    greet = pure
      { session : Just Unstarted
      , speech: "Yay! I love this game. " <>
                "Ok, pick a 5-letter word for me to guess. " <>
                "Say \"I'm ready\" when you're ready for me to start guessing."
      , reprompt : Just $ "Say, \"I'm ready\" when you're ready for me to start guessing. " <>
                   "If you need more time to think, say \"I'm not ready\"."
      }

    noop = pure
      { session : Nothing
      , speech: "Talk to the hand, the face isn't listening"
      , reprompt : Nothing
      }
