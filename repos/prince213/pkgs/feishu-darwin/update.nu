#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

let platforms = {
  aarch64-darwin: 9
  x86_64-darwin: 6
}

const sources = './pkgs/feishu-darwin/sources.json'

$platforms
| transpose system id
| par-each { |platform|
    let data: record = http get $'https://www.feishu.cn/api/package_info?platform=($platform.id)'
      | get data

    let version: string = $data
      | get version_number
      | parse '{_}@V{version}'
      | get 0.version

    let url: string = $data
      | get download_link
      | url parse
      | get path
      | each {|path| 'https://sf3-cn.feishucdn.com/obj' ++ $path}

    let hash: string = ^nix store prefetch-file --json $url | from json | get hash

    [
      $platform.system
      {
        version: $version
        src: {
          url: $url
          hash: $hash
        }
      }
    ]
  }
| into record
| to json
| save -f $sources
