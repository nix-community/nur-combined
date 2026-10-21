#!/usr/bin/env nu

const releases_url = "https://community.115.com/wap/lists/?cid=1456742919&commend=1&gid=115"

export def latest-release [html: string] {
  let releases = ($html
    | parse -r '(?s)<a\s+href="/t-115-(?<topic>\d+)\.html"[^>]*>(?<body>.*?)</a>'
    | each {|post|
      let author = ($post.body | parse -r '(?s)<em[^>]*>\s*<i[^>]*>\s*(?<author>\d+)\s*</i>' | get -o 0.author | default "")
      let title = ($post.body | parse -r '(?s)<strong[^>]*>(?<title>.*?)</strong>' | get -o 0.title | default "" | str replace -ar '\s+' '')
      let version = ($title | parse -r '^115生活[_－-]?Linux端[Vv](?<version>\d+\.\d+\.\d+(?:\.\d+)?)新版正式发布$' | get -o 0.version)
      # 11500 is the official publisher; exclude browser and test releases.
      if $author != "11500" or $version == null { return null }
      let parts = ($version | split row "." | into int)
      { version: $version, topic: $post.topic, major: $parts.0, minor: $parts.1, patch: $parts.2, build: ($parts | get -o 3 | default 0) }
    }
    | compact
    | sort-by major minor patch build)
  if ($releases | is-empty) {
    error make { msg: "No official stable Linux release found; review the release page" }
  }
  let latest = ($releases | last)
  { version: $latest.version, announcement: $"https://q.115.com/115/T($latest.topic).html" }
}

def fetch [url: string] {
  http get --raw --max-time 60sec --headers { "User-Agent": "nur-115life-updater/1.0" } $url
}

def checked [label: string] {
  let result = $in
  if $result.exit_code != 0 {
    error make { msg: $"($label) failed: ($result.stderr)" }
  }
  $result.stdout
}

export def newer-than [candidate: string, current: string] {
  let a = ($candidate | split row "." | into int | append 0 | first 4)
  let b = ($current | split row "." | into int | append 0 | first 4)
  for pair in ($a | zip $b) {
    if $pair.0 != $pair.1 { return ($pair.0 > $pair.1) }
  }
  false
}

export def main [--repo: path = ".", --check] {
  cd $repo
  let package_file = "pkgs/115life/default.nix"
  let original = (open $package_file --raw)
  let current = ($original | parse -r 'version = "(?<version>[^"]+)";' | first | get version)
  let latest = (latest-release (fetch $releases_url))
  print $"115life: current ($current), official ($latest.version) \(($latest.announcement)\)"
  if $check or not (newer-than $latest.version $current) { return }

  let download = $"https://down.115.com/client/115pc/lin/115Life_($latest.version).deb"
  if not (fetch $latest.announcement | str contains $download) {
    error make { msg: "Announcement no longer links the expected official Linux package" }
  }
  let prefetched = (^nix store prefetch-file --json $download | complete | checked "prefetch" | from json)
  let metadata = (^dpkg-deb --show '--showformat=${Package}\t${Version}\t${Architecture}' $prefetched.storePath | complete | checked "Debian metadata" | split row (char tab))
  if $metadata != [115life $latest.version amd64] {
    error make { msg: $"Unexpected Debian package: ($metadata | str join ' ')" }
  }
  let updated = ($original
    | str replace -r 'version = "[^"]+";' $'version = "($latest.version)";'
    | str replace -r 'hash = "[^"]+";' $'hash = "($prefetched.hash)";'
    | str replace -r 'downloadPage = "[^"]+";' $'downloadPage = "($latest.announcement)";')
  try {
    $updated | save -f $package_file
    let build = (with-env { NIXPKGS_ALLOW_UNFREE: "1" } { ^nix build --impure --no-link .#115life | complete })
    $build | checked "build" | print
    if not ($build.stderr | is-empty) { print -e $build.stderr }
  } catch {|err|
    $original | save -f $package_file
    error make { msg: $err.msg }
  }
  print $"115life: updated to ($latest.version); build and install checks passed"
}
