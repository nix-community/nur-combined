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
  ghPkg "matrix-org" "synapse-s3-storage-provider"
  ghPkg "trojan-gfw" "trojan"
  ghPkg "Wind4" "vlmcsd"
  gitPkg "aws-sigv4-proxy" "https://github.com/awslabs/aws-sigv4-proxy.git"
  gitPkg "rime-bopomofo" "https://github.com/rime/rime-bopomofo.git"
  gitPkg "rime-cangjie" "https://github.com/rime/rime-cangjie.git"
  gitPkg "rime-essay" "https://github.com/rime/rime-essay.git"
  gitPkg "rime-ice" "https://github.com/iDvel/rime-ice.git"
  gitPkg "rime-luna-pinyin" "https://github.com/rime/rime-luna-pinyin.git"
  gitPkg "rime-prelude" "https://github.com/rime/rime-prelude.git"
  gitPkg "rime-stroke" "https://github.com/rime/rime-stroke.git"
  gitPkg "rime-terra-pinyin" "https://github.com/rime/rime-terra-pinyin.git"
  gitPkg "telegram-send" "https://github.com/rahiel/telegram-send.git"
  fishPlugins
  commitNotifier
  tgSend
  dotTar
  clashForWindows
  icalinguaPlusPlus
  mstickereditor
  wemeet
  yacd
  zeronsd

fishPlugins :: PackageSet ()
fishPlugins = do
  gitPkg "plugin-git" "https://github.com/jhillyerd/plugin-git"
  gitPkg "plugin-bang-bang" "https://github.com/oh-my-fish/plugin-bang-bang"
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
  [ ("aarch64-linux", "linux-arm64"),
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

icalinguaPlusPlus :: PackageSet ()
icalinguaPlusPlus =
  define $
    package "icalingua-plus-plus"
      `sourceGitHub` ("icalingua-plus-plus", "icalingua-plus-plus")
      `fetchUrl` url
  where
    url (Version v) = "https://github.com/icalingua-plus-plus/icalingua-plus-plus/releases/download/" <> v <> "/app-x86_64.asar"

mstickereditor :: PackageSet ()
mstickereditor =
  define $
    package "mstickereditor"
      `fromGitHub` ("LuckyTurtleDev", "mstickereditor")
      `hasCargoLocks` ["Cargo.lock"]

tgSend :: PackageSet ()
tgSend =
  define $
    package "tg-send"
      `sourceGit` url
      `fetchGit` url
      `hasCargoLocks` ["Cargo.lock"]
  where
    url = "https://github.com/linyinfeng/tg-send.git"

wemeet :: PackageSet ()
wemeet =
  define $
    package "wemeet"
      `sourceAur` "wemeet-bin"
      `fetchUrl` url
  where
    md5 = "e078bf97365540d9f0ff063f93372a9c" -- TODO auto update md5
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
