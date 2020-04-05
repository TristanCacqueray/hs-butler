{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Data.Text as T
import Options.Applicative
import Data.Semigroup ((<>))
import Network.URI
import qualified Turtle

data Opts = Opts
    { optGlobalFlag :: !Bool
    , optCommand :: !Command
    }

data Command
    = Clone String

main :: IO ()
main = do
    (opts :: Opts) <- execParser optsParser
    case optCommand opts of
        Clone url -> clone url
  where
    optsParser :: ParserInfo Opts
    optsParser =
        info (helper <*> programOptions)
             (fullDesc <> progDesc "optparse subcommands example" <>
             header "Butler")
    programOptions :: Parser Opts
    programOptions =
        Opts <$> switch (long "debug" <> help "TBD: add debug") <*>
        hsubparser (cloneCommand)
    cloneCommand :: Mod CommandFields Command
    cloneCommand =
        command "clone"
                (info cloneOptions (progDesc "Clone a thing"))
    cloneOptions :: Parser Command
    cloneOptions =
        Clone <$>
        strArgument (metavar "NAME" <> help "Name of the thing to clone")


-- The clone command
urlToDir :: String -> Maybe String
urlToDir url = do
  uri <- parseURI url
  uriAuth <- uriAuthority uri
  case uriPath uri of
    ""   -> Nothing
    path -> Just $ uriRegName uriAuth ++ stripGitSuffix path
  where stripGitSuffix s =
          case stripSuffix ".git" (pack s) of
            Just p -> unpack p
            _      -> s

unsafeStringToLine :: String -> Turtle.Line
unsafeStringToLine = Turtle.unsafeTextToLine . T.pack

clone :: String -> IO ()
clone url = clone' url dir
  where
    dir = case urlToDir url of
      Just path -> path
      Nothing   -> error "Invalid url" ++ url
    clone' url dir = Turtle.echo $ unsafeStringToLine $
      "Running: mkdir -p ~/git/" ++ dir ++ "; git clone " ++ url ++ " " ++ dir
