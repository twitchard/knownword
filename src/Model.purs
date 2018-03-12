module Model where

import Amazon.Alexa.LanguageModel (LanguageModel)

model ::
  { interactionModel ::
    { languageModel :: LanguageModel }
  }
model =
  { interactionModel :
    { languageModel : americanEnglish }
  }

americanEnglish :: LanguageModel
americanEnglish =
  { invocationName: "known word"
  , intents:
      [ { name: "AMAZON.CancelIntent" , samples: [] , slots : [] }
      , { name: "AMAZON.HelpIntent" , samples: [] , slots : [] }
      , { name: "AMAZON.StopIntent" , samples: [] , slots : [] }
      , { name: "ReadyIntent"
        , samples: [ "I'm ready"
                   , "Ready"
                   , "Let's go"
                   , "I've got my word"
                   , "Start"
                   , "Begin"
                   , "Start playing"
                   , "Let's play"
                   , "Go ahead and guess"
                   , "Start guessing"
                   ]
        , slots : []
        }
      , { name: "NoopIntent"
        , samples: [ "I'm not ready"
                   , "Not ready"
                   , "Not yet"
                   , "Hold on"
                   , "Hold up"
                   , "Hold your horses"
                   , "Wait up"
                   , "Just a second"
                   , "Just a minute"
                   , "Patience"
                   , "I'm thinking"
                   ]
        , slots : []
        }
      , { name: "CorrectGuessIntent"
        , samples: [ "You got it"
                   , "That's it"
                   , "You got my word"
                   , "You guessed it"
                   , "You guessed my word"
                   , "Good job"
                   , "You win"
                   , "Congratulations. You win"
                   , "That's correct"
                   , "That's right"
                   , "You are correct"
                   , "You got it right"
                   , "You did it"
                   , "You're right"
                   , "Yes that's it"
                   ]
        , slots : []
        }
      , { name: "NumberIntent"
        , samples: [ "{Num}"
                   , "{Num} letters"
                   , "It has {Num} letters in common"
                   ]
        , slots : [ { "name": "Num"
                    , "type": "AMAZON.NUMBER"
                    }
                  ]
        }
      ]
  , types: [ ]
  }
