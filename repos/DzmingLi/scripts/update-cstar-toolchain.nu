#!/usr/bin/env nu

const release_api = "https://gitee.com/api/v5/repos/cstarlang/cstar_docs/releases/latest"
const archive_name = "cstar_linux-x64.tar.xz"
const package_file = "pkgs/cstar-toolchain/default.nix"

def main [] {
  let release = (http get
    --max-time 30sec
    --headers {
      "Accept": "application/json"
      "User-Agent": "nur-packages-cstar-updater"
    }
    $release_api)

  let tag = ($release | get tag_name)
  if $release.prerelease {
    error make { msg: $"latest CStar release is marked as a prerelease: ($tag)" }
  }

  let parsed_version = ($tag | parse -r '^v(?<version>[0-9]+\.[0-9]+\.[0-9]+)$')
  if ($parsed_version | is-empty) {
    error make { msg: $"unexpected CStar release tag: ($tag)" }
  }
  let latest_version = ($parsed_version | first | get version)

  let linux_assets = ($release.assets | where name == $archive_name)
  if ($linux_assets | length) != 1 {
    error make { msg: $"release ($tag) must contain exactly one ($archive_name) asset" }
  }
  let expected_url = $"https://gitee.com/cstarlang/cstar_docs/releases/download/($tag)/($archive_name)"
  let asset_url = ($linux_assets | first | get browser_download_url)
  if $asset_url != $expected_url {
    error make { msg: $"unexpected download URL for ($archive_name): ($asset_url)" }
  }

  let current_version = (open $package_file --raw
    | parse -r '(?m)^\s*version = "(?<version>[^"]+)";'
    | first
    | get version)

  print $"[cstar-toolchain] current: ($current_version)"
  print $"[cstar-toolchain] latest:  ($latest_version)"

  if $current_version == $latest_version {
    print "[cstar-toolchain] up-to-date"
    return
  }

  let result = (^nix-update cstar-toolchain
    --flake
    $"--version=($latest_version)"
    --subpackage unwrapped
    | complete)

  if not ($result.stdout | str trim | is-empty) {
    print $result.stdout
  }
  if not ($result.stderr | str trim | is-empty) {
    print -e $result.stderr
  }
  if $result.exit_code != 0 {
    error make { msg: $"nix-update failed with exit code ($result.exit_code)" }
  }
}
