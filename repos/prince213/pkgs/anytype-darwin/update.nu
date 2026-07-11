#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

def get-github-api [url: string] {
  http get -H {
    Accept: 'application/vnd.github+json'
    X-GitHub-Api-Version: '2026-03-10'
  } $url
}

let platforms = {
  aarch64-darwin: '-mac-arm64.zip'
  x86_64-darwin: '-mac-x64.zip'
}

let release: record = get-github-api 'https://api.github.com/repos/anyproto/anytype-ts/releases'
  | select tag_name assets_url
  | where tag_name like '^v\d+\.\d+\.\d+$'
  | first

let version: string = $release.tag_name | parse 'v{version}' | get 0.version

let assets: list = get-github-api $release.assets_url

$platforms
| transpose system suffix
| par-each { |platform|
    let asset = $assets | where name ends-with $platform.suffix | get 0

    let hash: string = ^nix hash convert --to sri $asset.digest

    [
      $platform.system
      {
        url: $asset.browser_download_url
        hash: $hash
      }
    ]
  }
| into record
| insert version $version
| sort
| to json
| save -f ./pkgs/anytype-darwin/sources.json
