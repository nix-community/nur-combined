{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Foldable
import Data.Text
import NvFetcher

main :: IO ()
main = runNvFetcher packageSet

packageSet :: PackageSet ()
packageSet = do
  traverse_ (uncurry clashPremium) clashPremiumSystems
  ghPkg "janten" "dpt-rp1-py"
  ghPkg "TimothyYe" "godns"
  ghPkg "trojan-gfw" "trojan"
  ghPkg "Wind4" "vlmcsd"
  clashForWindows
  clashForWindowsIcon
  icalingua
  icalinguaIcon

ghPkg :: Text -> Text -> PackageSet ()
ghPkg owner repo = define $ package repo `fromGitHub` (owner, repo)

clashPremium :: Text -> Text -> PackageSet ()
clashPremium sys goSys =
  define $
    package ("clash-premium-" <> sys)
      `sourceAur` "clash-premium-bin"
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/Dreamacro/clash/releases/download/premium/clash-" <> goSys <> "-" <> v <> ".gz"

clashPremiumSystems :: [(Text, Text)]
clashPremiumSystems =
  [ ("aarch64-linux", "linux-armv8"),
    ("i686-linux", "linux-386"),
    ("x86_64-darwin", "darwin-amd64"),
    ("x86_64-linux", "linux-amd64")
  ]

clashForWindows :: PackageSet ()
clashForWindows =
  define $
    package "clash-for-windows"
      `sourceGitHub` ("Fndroid", "clash_for_windows_pkg")
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/Fndroid/clash_for_windows_pkg/releases/download/" <> v <> "/Clash.for.Windows-" <> v <> "-x64-linux.tar.gz"

clashForWindowsIcon :: PackageSet ()
clashForWindowsIcon =
  define $
    package "clash-for-windows-icon"
      `sourceManual` "0"
      `fetchUrl` (const "https://docs.cfw.lbyczf.com/favicon.ico")

icalingua :: PackageSet ()
icalingua =
  define $
    package "icalingua"
      `sourceGitHub` ("Clansty", "icalingua")
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/Clansty/Icalingua/releases/download/" <> v <> "/app-x86_64.asar"

icalinguaIcon :: PackageSet ()
icalinguaIcon =
  define $
    package "icalinguaIcon"
      `sourceManual` "0"
      `fetchUrl` (const "https://aur.archlinux.org/cgit/aur.git/plain/512x512.png?h=icalingua")
