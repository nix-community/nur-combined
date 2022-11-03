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
  gitPkg "aws-sigv4-proxy" "https://github.com/awslabs/aws-sigv4-proxy.git"
  gitPkg "telegram-send" "https://github.com/rahiel/telegram-send.git"
  fishPlugins
  commitNotifier
  dotTar
  clashForWindows
  clashForWindowsIcon
  icalinguaPlusPlus
  icalinguaPlusPlusAur
  wemeet
  yacd
  zeronsd

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
  define $
    package "commit-notifier"
      `sourceGit` url
      `fetchGit` url
      `hasCargoLocks` ["Cargo.lock"]
  where
    url = "https://github.com/linyinfeng/commit-notifier.git"

dotTar :: PackageSet ()
dotTar =
  define $
    package "dot-tar"
      `sourceGit` url
      `fetchGit` url
      `hasCargoLocks` ["Cargo.lock"]
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
      `fetchUrl` (const "https://web.archive.org/web/20211210004725if_/https://docs.cfw.lbyczf.com/favicon.ico")

icalinguaPlusPlus :: PackageSet ()
icalinguaPlusPlus =
  define $
    package "icalingua-plus-plus"
      `sourceGitHub` ("icalingua-plus-plus", "icalingua-plus-plus")
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/icalingua-plus-plus/icalingua-plus-plus/releases/download/" <> v <> "/app-x86_64.asar"

icalinguaPlusPlusAur :: PackageSet ()
icalinguaPlusPlusAur = gitPkg "icalingua-plus-plus-aur" "https://aur.archlinux.org/icalingua++.git"

wemeet :: PackageSet ()
wemeet =
  define $
    package "wemeet"
      `sourceAur` "wemeet-bin"
      `fetchUrl` url
  where
    md5 = "9b74d4127a16a011db8cb6300fa5fbc9" -- TODO auto update md5
    url (Version v) = "https://updatecdn.meeting.qq.com/cos/" <> md5 <> "/TencentMeeting_0300000000_" <> v <> "_x86_64_default.publish.deb"

yacd :: PackageSet ()
yacd =
  define $
    package "yacd"
      `sourceGitHub` ("haishanh", "yacd")
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/haishanh/yacd/releases/download/" <> v <> "/yacd.tar.xz"

zeronsd :: PackageSet ()
zeronsd =
  define $
    package "zeronsd"
      `fromGitHub` ("zerotier", "zeronsd")
      `hasCargoLocks` ["Cargo.lock"]
