#!/usr/bin/env nu

def checked [label: string] {
  let result = $in
  if $result.exit_code != 0 {
    error make { msg: $"($label) failed: ($result.stderr)" }
  }
  $result.stdout | str trim
}

def changed-files [] {
  let tracked = (^git diff --name-only -z HEAD | split row (char nul) | where {|p| $p != "" })
  let untracked = (^git ls-files --others --exclude-standard -z | split row (char nul) | where {|p| $p != "" })
  $tracked | append $untracked | uniq
}

def rollback [baseline: list<string>] {
  let changes = (changed-files | where {|path| $path not-in $baseline })
  let tracked = (^git ls-files -z | split row (char nul))
  let restore = ($changes | where {|path| $path in $tracked })
  if not ($restore | is-empty) {
    ^git restore --source=HEAD --staged --worktree -- ...$restore | complete | checked "rollback" | ignore
  }
  for path in ($changes | where {|path| $path not-in $tracked }) {
    if ($path | path exists) { rm $path }
  }
}

def print-output [result: record] {
  if not ($result.stdout | is-empty) { print $result.stdout }
  if not ($result.stderr | is-empty) { print -e $result.stderr }
}

# Exported separately so transaction behavior can be tested without contacting upstreams.
export def run-package [package: record, args: list<string> = [], --commit] {
  let baseline = (changed-files)
  let directory = $"pkgs/($package.attribute)/"
  print $"[($package.attribute)] running updateScript"
  try {
    let program = ($package.command | first)
    let arguments = ($package.command | skip 1 | append $args)
    let result = (with-env {
      NIXPKGS_ALLOW_UNFREE: "1"
      UPDATE_NIX_NAME: $package.name
      UPDATE_NIX_PNAME: $package.pname
      UPDATE_NIX_OLD_VERSION: $package.oldVersion
      UPDATE_NIX_ATTR_PATH: $package.attrPath
    } { ^$program ...$arguments | complete })
    print-output $result
    $result | checked "updateScript" | ignore

    let changes = (changed-files | where {|path| $path not-in $baseline })
    if ($changes | is-empty) {
      print $"[($package.attribute)] unchanged"
      return
    }
    if ($changes | any {|path| not ($path | str starts-with $directory) }) {
      error make { msg: "updateScript changed files outside its package directory" }
    }

    let build = (with-env { NIXPKGS_ALLOW_UNFREE: "1" } {
      ^nix build --impure --no-link $".#($package.attrPath)" | complete
    })
    print-output $build
    $build | checked "package build" | ignore
    if $commit {
      ^git add -- ...$changes | complete | checked "git add" | ignore
      ^git commit -m $"($package.attribute): update" | complete | checked "git commit" | print
    }
    print $"[($package.attribute)] updated and verified"
  } catch {|err|
    rollback $baseline
    error make { msg: $err.msg }
  }
}

# After the package name, use `--` to forward flags to its updateScript.
export def main [package?: string, ...args: string, --all, --list, --commit] {
  let root = (^git rev-parse --show-toplevel | complete | checked "repository discovery")
  cd $root
  let names = (^nix eval --json .#update.packageNames | complete | checked "updater discovery" | from json)
  if $list { $names | each {|name| print $name }; return }
  if ($all and ($package != null or not ($args | is-empty))) or (not $all and $package == null) {
    error make { msg: "Select one package, --all, or --list" }
  }
  let selected = (if $all { $names } else { [$package] })
  for name in $selected {
    if $name not-in $names { error make { msg: $"No updateScript declared for ($name)" } }
  }
  if not (changed-files | is-empty) {
    error make { msg: "Commit or stash existing changes before running package updates" }
  }

  mut failures = []
  for name in $selected {
    let failure = (try {
      let manifest = (^nix build --no-link --print-out-paths $".#update.commands.($name)"
        | complete | checked "updateScript dependencies")
      run-package (open $manifest) $args --commit=$commit
      null
    } catch {|err|
      print -e $"[($name)] FAILED: ($err.msg)"
      $name
    })
    if $failure != null { $failures = ($failures | append $failure) }
  }
  if not ($failures | is-empty) {
    error make { msg: $"Updates failed: ($failures | str join ', ')" }
  }
}
