#!/usr/bin/env nu

def update-linux [] {
  let pkg_file = "pkgs/wechat/linux.nix"
  let appimage_urls = [
    "https://dldir1.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
    "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
  ]

  let content = open $pkg_file --raw
  let old_hash = ($content | parse -r 'hash = "(?<h>[^"]+)";' | first | get h)
  let old_ver  = ($content | parse -r 'version = "(?<v>[^"]+)";' | first | get v)

  print $"[linux] current: ($old_ver) / ($old_hash)"

  mut prefetched: any = null
  for url in $appimage_urls {
    let r = try {
      let lines = (^nix-prefetch-url --print-path $url | lines)
      { hash32: ($lines | first | str trim), path: ($lines | last | str trim), url: $url }
    } catch { null }
    if $r != null { $prefetched = $r; break }
  }
  if $prefetched == null {
    print -e "[linux] all download URLs failed"
    return
  }

  let new_hash = (^nix-hash --to-sri --type sha256 $prefetched.hash32 | str trim)
  let appimage = $prefetched.path
  print $"[linux] used URL: ($prefetched.url)"

  # AppImage type 2 = ELF stub + squashfs.
  # offset = e_shoff + e_shentsize * e_shnum
  let elf_info = (^nix shell nixpkgs#binutils -c readelf -h $appimage
    | parse -r '(?<key>Start of section headers|Size of section headers|Number of section headers):\s+(?<val>\d+)'
    | reduce -f {} {|row, acc| $acc | upsert $row.key ($row.val | into int) })
  let offset = ($elf_info | get "Start of section headers") + (($elf_info | get "Size of section headers") * ($elf_info | get "Number of section headers"))

  let workdir = (mktemp -d)
  ^nix shell nixpkgs#squashfsTools -c unsquashfs -q -o $offset -d $"($workdir)/sq" $appimage wechat.desktop
  let new_ver = (open $"($workdir)/sq/wechat.desktop" --raw
    | parse -r '(?m)^X-AppImage-Version=(?<v>.+)$'
    | first
    | get v
    | str trim)
  rm -rf $workdir
  print $"[linux] latest:  ($new_ver) / ($new_hash)"

  if $old_hash == $new_hash and $old_ver == $new_ver {
    print "[linux] up-to-date"
  } else {
    let updated = ($content
      | str replace --regex 'version = "[^"]+";' $'version = "($new_ver)";'
      | str replace --regex 'hash = "[^"]+";' $'hash = "($new_hash)";')
    $updated | save -f $pkg_file
    print $"[linux] updated ($pkg_file)"
  }
}

update-linux
