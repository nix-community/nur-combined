#!/usr/bin/env nu

# Refresh the racket-langserver addon FOD hash.
#
# The addon is a fixed-output derivation that runs `raco pkg install
# racket-langserver` against Racket's live package catalog, so its content
# (and therefore `outputHash`) drifts whenever upstream or a transitive
# dependency moves. `nix-update` cannot recompute a `recursive` FOD hash,
# and simply building the derivation is also not enough: the stale, still
# correct-looking output is usually available from the binary cache and
# would be substituted instead of rebuilt.
#
# To force a rebuild we temporarily swap `outputHash` for Nix's fake hash
# (whose store path can never be cached), let the derivation fail with a
# hash mismatch, and read the actual content hash out of the error.

const package_file = "pkgs/racket-langserver/default.nix"
const hash_regex = 'outputHash = "[^"]+";'
const got_regex = 'got:\s+(?<hash>sha256-[A-Za-z0-9+/=]+)'
const fake_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

def main [] {
  let original = (open $package_file --raw)
  let old_hash = ($original
    | parse -r 'outputHash = "(?<h>[^"]+)";'
    | first
    | get h)

  print $"[racket-langserver] current: ($old_hash)"

  # Force the FOD to be rebuilt, ignoring any cached (stale) output.
  ($original | str replace --regex $hash_regex $'outputHash = "($fake_hash)";')
    | save -f $package_file

  let result = (^nix build .#racket-langserver --no-link | complete)
  let output = $"($result.stdout)\n($result.stderr)"

  # The derivation is expected to fail with the mismatch; anything else
  # means the package is broken for an unrelated reason.
  let matches = ($output | parse -r $got_regex)
  if ($matches | is-empty) {
    $original | save -f $package_file
    print -e "[racket-langserver] build did not report a hash mismatch:"
    print -e $output
    error make { msg: "could not determine a new racket-langserver addon hash" }
  }

  let new_hash = ($matches | last | get hash)

  if $new_hash == $old_hash {
    $original | save -f $package_file
    print "[racket-langserver] up-to-date"
    return
  }

  ($original | str replace --regex $hash_regex $'outputHash = "($new_hash)";')
    | save -f $package_file
  print $"[racket-langserver] updated: ($new_hash)"
}
