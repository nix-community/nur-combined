#!/usr/bin/env nu
use std/assert
use ../update-packages.nu run-package

def fixture [] {
  let work = (mktemp -d | str trim)
  let root = ($work | path join repo)
  mkdir ($work | path join bin) ($work | path join manifests) ($root | path join pkgs foo) ($root | path join pkgs bar)
  "old" | save ($root | path join pkgs foo default.nix)
  "old" | save ($root | path join pkgs bar default.nix)
  "original" | save ($root | path join README.md)
  ^git -C $root init --quiet
  ^git -C $root config user.name "Updater test"
  ^git -C $root config user.email "test@example.invalid"
  ^git -C $root add .
  ^git -C $root commit --quiet -m initial
  let script = ($work | path join update.nu)
  'def main [--flag: string = ""] {
    let name = $env.UPDATE_NIX_ATTR_PATH
    if $env.NUR_UPDATE_TEST_MODE == "noop" { return }
    "new" | save -f $"pkgs/($name)/default.nix"
    ($flag | to json) | save -f $"pkgs/($name)/generated.json"
    if $env.NUR_UPDATE_TEST_MODE == "outside" { "changed" | save -f README.md }
    if $name == $env.NUR_UPDATE_TEST_FAIL_PACKAGE { exit 7 }
  }' | save $script
  '#!/usr/bin/env bash
set -eu
printf "%s\n" "$*" >> "$NUR_UPDATE_TEST_WORK/nix.log"
case "$*" in
  "eval --json .#update.packageNames") printf "%s\n" "[\"foo\",\"bar\"]" ;;
  *".#update.commands."*)
    attribute="${!#}"
    printf "%s/manifests/%s.json\n" "$NUR_UPDATE_TEST_WORK" "${attribute##*.}" ;;
  "build --impure --no-link .#"*)
    if [ "$NUR_UPDATE_TEST_MODE" = build-failure ]; then exit 9; fi ;;
  *) exit 20 ;;
esac' | str replace '#!/usr/bin/env bash' $"#!(which bash | first | get path)" | save ($work | path join bin nix)
  ^chmod +x ($work | path join bin nix)
  for name in [foo bar] {
    { attribute: $name, attrPath: $name, name: $"($name)-1.0", pname: $name, oldVersion: "1.0", command: [(which nu | first | get path) $script] }
      | to json | save ($work | path join manifests $"($name).json")
  }
  { work: $work, root: $root, package: (open ($work | path join manifests foo.json)) }
}

def assert-clean [root: path] {
  assert equal (^git -C $root status --porcelain | str trim) ""
}

def main [] {
  let runner = ($env.FILE_PWD | path join .. update-packages.nu | path expand)
  let original_directory = $env.PWD
  for mode in [noop success script-failure build-failure outside] {
    let f = (fixture)
    cd $f.root
    let failure = (with-env {
      PATH: ($env.PATH | prepend ($f.work | path join bin))
      NUR_UPDATE_TEST_WORK: $f.work
      NUR_UPDATE_TEST_MODE: $mode
      NUR_UPDATE_TEST_FAIL_PACKAGE: (if $mode == script-failure { "foo" } else { "" })
    } {
      try { run-package $f.package ["--flag" "value with spaces"] --commit; null } catch {|err| $err.msg }
    })
    assert-clean $f.root
    if $mode in [script-failure build-failure outside] {
      assert ($failure != null)
      assert equal (open pkgs/foo/default.nix --raw) "old"
      assert (not ("pkgs/foo/generated.json" | path exists))
      assert equal (open README.md --raw) "original"
    } else {
      assert equal $failure null
      if $mode == success {
        assert equal (open pkgs/foo/default.nix --raw) "new"
        assert equal (open pkgs/foo/generated.json) "value with spaces"
        assert equal (^git log -1 --format=%s | str trim) "foo: update"
      } else {
        assert (not ($f.work | path join nix.log | path exists))
      }
    }
    cd $original_directory
    rm -r $f.work
    print $"PASS: ($mode)"
  }

  let f = (fixture)
  cd $f.root
  let result = (with-env {
    PATH: ($env.PATH | prepend ($f.work | path join bin))
    NUR_UPDATE_TEST_WORK: $f.work
    NUR_UPDATE_TEST_MODE: success
    NUR_UPDATE_TEST_FAIL_PACKAGE: foo
  } { ^nu $runner --all --commit | complete })
  assert ($result.exit_code != 0)
  assert-clean $f.root
  assert equal (open pkgs/foo/default.nix --raw) "old"
  assert equal (open pkgs/bar/default.nix --raw) "new"
  assert equal (^git log -1 --format=%s | str trim) "bar: update"
  print "PASS: failed package is rolled back; later successful package is committed"
  cd $original_directory
  rm -r $f.work

  let f = (fixture)
  cd $f.root
  let result = (with-env {
    PATH: ($env.PATH | prepend ($f.work | path join bin))
    NUR_UPDATE_TEST_WORK: $f.work
    NUR_UPDATE_TEST_MODE: success
    NUR_UPDATE_TEST_FAIL_PACKAGE: ""
  } { ^nu $runner --commit foo -- --flag "forwarded value" | complete })
  assert equal $result.exit_code 0
  assert equal (open pkgs/foo/generated.json) "forwarded value"
  assert-clean $f.root
  print "PASS: CLI forwards script flags and arguments with spaces"
  "user edits" | save -f README.md
  let result = (with-env {
    PATH: ($env.PATH | prepend ($f.work | path join bin))
    NUR_UPDATE_TEST_WORK: $f.work
  } { ^nu $runner foo | complete })
  assert ($result.exit_code != 0)
  assert equal (open README.md --raw) "user edits"
  print "PASS: existing user changes are preserved"
  cd $original_directory
  rm -r $f.work
}
