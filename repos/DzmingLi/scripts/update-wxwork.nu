#!/usr/bin/env nu

# 企业微信 / WeCom macOS (Apple Silicon) 自动更新 darwin.nix。
# mac arm64 入口 commdownload?platform=mac_arm64 会 302 到
#   https://dldir1.qq.com/foxmail/wecom-mac/updatebzl/WeCom_<ver>_Apple.dmg
# 版本就在文件名里，无轮换 hash，跟一次重定向即可拿到最新版本与 URL。
def update-darwin [] {
  let pkg_file = "pkgs/wxwork/darwin.nix"
  let entry = "https://work.weixin.qq.com/wework_admin/commdownload?platform=mac_arm64"

  let content = open $pkg_file --raw
  let old_ver  = ($content | parse -r 'version = "(?<v>[^"]+)";' | first | get v)
  let old_hash = ($content | parse -r 'hash = "(?<h>[^"]+)";' | first | get h)
  print $"[darwin] current: ($old_ver) / ($old_hash)"

  # 跟 302 拿到最终 dmg URL（文件名里带版本）。
  let location = (^curl -sIL $entry
    | lines
    | where ($it | str downcase | str starts-with "location:")
    | where ($it | str contains "WeCom_")
    | last)
  if ($location | is-empty) {
    print -e "[darwin] could not resolve dmg redirect"
    return
  }
  let url = ($location | str replace --regex '(?i)^location:\s*' '' | str trim)
  let new_ver = ($url | parse -r 'WeCom_(?<v>[^_]+)_Apple\.dmg' | first | get v)
  print $"[darwin] latest:  ($new_ver)"

  if $old_ver == $new_ver {
    print "[darwin] up-to-date"
    return
  }

  let new_hash = (^nix store prefetch-file --json $url | from json | get hash | str trim)
  let updated = ($content
    | str replace --regex 'version = "[^"]+";' $'version = "($new_ver)";'
    | str replace --regex 'hash = "[^"]+";' $'hash = "($new_hash)";')
  $updated | save -f $pkg_file
  print $"[darwin] updated ($pkg_file): ($new_ver) / ($new_hash)"
}

update-darwin
