#!/usr/bin/env nu

const nix_flags = [--verbose --print-build-logs --keep-going --show-trace --log-format multiline-with-logs --inputs-from .]
let current_system = uname | $"($in.machine)-($in.kernel-name)" | str downcase

def --wrapped nix [...rest] {
    print $"^nix ($rest) ($nix_flags)"
    ^nix ...$rest ...$nix_flags
}

def --wrapped nix-unstable [...rest] {
    print $"nix ($rest) --override-input nixpkgs nixpkgs"
    nix ...$rest --override-input nixpkgs nixpkgs
}

def --wrapped nix-stable [...rest] {
    print $"nix ($rest) --override-input nixpkgs nixpkgs-stable"
    nix ...$rest --override-input nixpkgs nixpkgs-stable
}

def "main build-all" [] {
    main build-all-unstable
    main build-all-stable
}

def "main build-all-unstable" [] {
    nix-unstable build --no-link --impure --expr 'import ./ci.nix { pkgs = import (builtins.getFlake "nixpkgs") { }; }' cacheOutputs
}

def "main build-all-stable" [] {
    nix-stable build --no-link --impure --expr 'import ./ci.nix { pkgs = import (builtins.getFlake "nixpkgs") { }; }' cacheOutputs
}

def "main build" [...packages: string] {
    main build-unstable ...$packages
    main build-stable ...$packages
}

def "main build-unstable" [...packages: string] {
    nix-unstable build ...($packages | each { $".#($in)" })
}

def "main build-stable" [...packages: string] {
    nix-stable build ...($packages | each { $".#($in)" })
}

def "main rebuild" [...packages: string] {
    main rebuild-unstable ...$packages
    main rebuild-stable ...$packages
}

def "main rebuild-unstable" [...packages: string] {
    nix-unstable build --rebuild ...($packages | each { $".#($in)" })
}

def "main rebuild-stable" [...packages: string] {
    nix-stable build --rebuild ...($packages | each { $".#($in)" })
}

def "main rebuild-all" [] {
    main rebuild-all-unstable
    main rebuild-all-stable
}

def "main rebuild-all-unstable" [] {
    nix-unstable build --rebuild --no-link --impure --expr 'import ./ci.nix { pkgs = import (builtins.getFlake "nixpkgs") { }; }' cacheOutputs
}

def "main rebuild-all-stable" [] {
    nix-stable build --rebuild --no-link --impure --expr 'import ./ci.nix { pkgs = import (builtins.getFlake "nixpkgs-stable") { }; }' cacheOutputs
}

def "main run-unstable" [package: string] {
    nix-unstable run $".#($package)"
}

def "main run-stable" [package: string] {
    nix-stable run $".#($package)"
}

def "main test" [] {
    main test-unstable
    main test-stable
}

def "main test-stable" [] {
    let tests = main run-stable tests | from json

    nix-stable build ...$tests
}

def "main test-unstable" [] {
    let tests = main run-unstable tests | from json

    nix-unstable build ...$tests
}

def "main path-info-unstable" [package: string] {
    main build-unstable $package
    nix-unstable path-info $".#($package)"
}

def "main path-info-stable" [package: string] {
    main build-stable $package
    nix-stable path-info $".#($package)"
}

def "main update" [] {
    nix flake update
    nix run ".#update"
}

def "main tree" [package: string] {
    nix-tree $".#($package)"
}

def "main inspect" [] {
    nix-inspect --path .
}

def "main lint" [] {
    statix check
    deadnix
}

def "main generate-readme" [] {
    nix run ".#generate-readme"
}

def main [] {}
