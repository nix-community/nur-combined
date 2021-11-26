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
  ghPkg "trojan-gfw" "trojan"
  ghPkg "Wind4" "vlmcsd"
  gitPkg "telegram-send" "https://github.com/rahiel/telegram-send.git"
  fishPlugins
  commitNotifier
  dotTar
  clashForWindows
  clashForWindowsIcon
  icalingua
  icalinguaIcon
  wemeet

fishPlugins :: PackageSet ()
fishPlugins = do
  gitPkg "plugin-git" "https://github.com/jhillyerd/plugin-git"
  gitPkg "plugin-bang-bang" "https://github.com/oh-my-fish/plugin-bang-bang"
  gitPkg "pisces" "https://github.com/laughedelic/pisces"
  define $ package "replay-fish" `fromGitHub` ("jorgebucaran", "replay.fish")

ghPkg :: Text -> Text -> PackageSet ()
ghPkg owner repo = define $ package repo `fromGitHub` (owner, repo)

ghPkgTag :: Text -> Text -> (ListOptions -> ListOptions) -> PackageSet ()
ghPkgTag owner repo f = define $ package repo `fromGitHubTag` (owner, repo, f)

gitPkg :: Text -> Text -> PackageSet ()
gitPkg name git = define $ package name `sourceGit` git `fetchGit` git

commitNotifier :: PackageSet ()
commitNotifier =
  define $ package "commit-notifier"
    `sourceGit` url
    `fetchGit` url
    `hasCargoLock` "Cargo.lock"
 where
   url = "https://github.com/linyinfeng/commit-notifier.git"

dotTar :: PackageSet ()
dotTar =
  define $ package "dot-tar"
    `sourceGit` url
    `fetchGit` url
    `hasCargoLock` "Cargo.lock"
 where
   url = "https://github.com/linyinfeng/dot-tar.git"

clashPremium :: Text -> Text -> PackageSet ()
clashPremium sys goSys =
  define $
    package ("clash-premium-" <> sys)
      `sourceWebpage` ("https://api.github.com/repos/Dreamacro/clash/releases/tags/premium", "clash-linux-amd64-([a-z0-9\\-\\.]+).gz", id)
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

wemeet :: PackageSet ()
wemeet =
  define $
    package "wemeet"
      `sourceAur` "wemeet-bin"
      `fetchUrl` url
  where
    url (Version v) = "https://updatecdn.meeting.qq.com/cos/196cdf1a3336d5dca56142398818545f/TencentMeeting_0300000000_" <> v <> "_x86_64.publish.deb"
