# pi-web (agegr): Web UI for persistent Pi Coding Agent sessions.
# Single-process `next start` server (no sessiond split like jmfederico);
# agent runs in-process via @earendil-works/pi-* 0.84.1, which are regular
# dependencies (not peers), so they survive npm prune — no patch needed.
# Built from source: `next build --webpack` runs in the sandbox.
{ lib, buildNpmPackage, fetchFromGitHub, fetchNpmDeps, nodejs_22, applyPatches }:

let
  src0 = fetchFromGitHub {
    owner = "agegr";
    repo = "pi-web";
    rev = "v0.8.8";
    hash = "sha256-wPNgxImAmy16IGrxt0uCD53RQU8388z/6Sh7ipnG0Qc=";
  };
  # the source repo's package-lock.json omits `integrity` on six nested peer
  # deps of pi-coding-agent, which fetchNpmDeps' parser rejects (same issue as
  # the jmfederico pi-web — the six @earendil-works/pi-* 0.84.1 tarballs).
  src = applyPatches {
    src = src0;
    patches = [
      ./integrity.patch
      # next/font/google fetches Noto Sans Mono from Google Fonts at build
      # time (no network in the nix sandbox). Drop the font — globals.css's
      # --font-mono stack falls back to JetBrains Mono/Consolas/etc.
      ./next-font-offline.patch
    ];
  };
in
buildNpmPackage rec {
  pname = "pi-web";
  version = "0.8.8";

  inherit src;

  nodejs = nodejs_22;

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-EwitzOHPV7KCGc9V+OYHTKUc+c1MNMnieTsHT6jV/DY=";
  };

  # npm's cacache index.compact needs write access (lock file); the npmDeps
  # store is read-only, so requests that take the make-fetch-happen path fail
  # with ENOTCACHED. Copy the cache to a writable dir (same as upstream).
  makeCacheWritable = true;

  # The lockfile carries a stale peer range (@emoji-mart/react wants react
  # ^16.8-^18 while the lockfile pins 19.2.4); npm 10 re-resolves peers during
  # `npm ci` and hits ENOTCACHED offline. Skip peer auto-install — the tree in
  # the lockfile is what agegr ships and runs.
  npmFlags = [ "--legacy-peer-deps" ];

  meta = with lib; {
    description = "Web UI for persistent Pi Coding Agent sessions (agegr)";
    homepage = "https://github.com/agegr/pi-web";
    license = licenses.mit;
    maintainers = [ ];
  };
}
