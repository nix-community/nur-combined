{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text
import Data.Foldable
import NvFetcher

main :: IO ()
main = runNvFetcher packageSet

packageSet :: PackageSet ()
packageSet = do
    traverse_ (uncurry clashPremium) clashPremiumSystems
    ghPkg "janten" "dpt-rp1-py"
    ghPkg "TimothyYe" "godns"
    ghPkg "darknessomi" "musicbox"
    ghPkg "trojan-gfw" "trojan"
    ghPkg "Wind4" "vlmcsd"

ghPkg :: Text -> Text -> PackageSet ()
ghPkg owner repo = define $ package repo `fromGitHub` (owner, repo)

clashPremium :: Text -> Text -> PackageSet ()
clashPremium sys goSys = define $
    package ("clash-premium-" <> sys)
      `sourceAur` "clash-premium-bin"
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/Dreamacro/clash/releases/download/premium/clash-" <> goSys <> "-" <> v <> ".gz"

clashPremiumSystems :: [(Text, Text)]
clashPremiumSystems = [
    ("aarch64-linux", "linux-armv8"),
    ("i686-linux", "linux-386"),
    ("x86_64-darwin", "darwin-amd64"),
    ("x86_64-linux", "linux-amd64")
  ]
