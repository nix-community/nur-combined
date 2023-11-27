{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text
import NvFetcher

main :: IO ()
main = runNvFetcher packageSet

packageSet :: PackageSet ()
packageSet = do
  -----------------------------------------------------------------------------
  ghTag "cockpit-project" "cockpit-podman"
  ghTag "cockpit-project" "cockpit-machines"
  -----------------------------------------------------------------------------

ghTag :: Text -> Text -> PackageSet ()
ghTag owner repo = define $
  package repo
    `sourceGitHub` (owner, repo)
    `fetchUrl` url
  where
  url (Version v) = "https://github.com/" <> owner <> "/" <> repo <> "/releases/download/" <> v <> "/" <> repo <> "-" <> v <> ".tar.xz"
