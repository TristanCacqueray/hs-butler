{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Data.Maybe
import Data.Text as T
import Network.URI
import Options.Applicative
import qualified Turtle

data Opts = Opts
  { optGlobalFlag :: !Bool,
    optCommand :: !Command
  }

data Command
  = Clone String

main :: IO ()
main = do
  (opts :: Opts) <- execParser optsParser
  home <- Turtle.need "HOME"
  case optCommand opts of
    Clone url -> clone (fromMaybe "" home <> "/src/") (pack url)
  where
    optsParser :: ParserInfo Opts
    optsParser =
      info
        (helper <*> programOptions)
        ( fullDesc <> progDesc "optparse subcommands example"
            <> header "Butler"
        )
    programOptions :: Parser Opts
    programOptions =
      Opts <$> switch (long "debug" <> help "TBD: add debug")
        <*> hsubparser cloneCommand
    cloneCommand :: Mod CommandFields Command
    cloneCommand =
      command
        "clone"
        (info cloneOptions (progDesc "Clone a thing"))
    cloneOptions :: Parser Command
    cloneOptions =
      Clone
        <$> strArgument (metavar "NAME" <> help "Name of the thing to clone")

-- The clone command

-- | Strip scheme, port, auth and query fragments
urlToDir :: Text -> Maybe Text
urlToDir url = do
  uri <- parseURI (unpack (replace "/r/" "/" url))
  uriAuth <- uriAuthority uri
  return (pack (uriRegName uriAuth <> uriPath uri))

clone :: Text -> Text -> IO ()
clone base url = do
  case urlToDir url of
    Nothing -> fail "Invalid url"
    Just urlDir -> do
      gitDirExist <- Turtle.testdir (Turtle.fromText (dest <> "/.git"))
      Turtle.unless gitDirExist (Turtle.procs "git" ["clone", url, dest] mempty)
      Turtle.echo (Turtle.unsafeTextToLine dest)
      where
        dest = base <> fromMaybe urlDir (stripSuffix ".git" urlDir)
