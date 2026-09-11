{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go_1_27 ? null,
  go_1_25,
  bun2nix,
  nodejs,
  runCommand,
  sqlite,
}:
let
  version = "0.19.3";
  # go.mod requires go 1.27.0. Nixpkgs stable channels (e.g. nixos-25.11)
  # don't package it yet, so fall back to the newest available toolchain.
  go = if go_1_27 != null then go_1_27 else go_1_25;
in
(buildGoModule.override { inherit go; }) {
  pname = "msgvault";
  inherit version;

  # Upstream dropped its Nix flake packaging in kenn-io/msgvault#767
  # (2026-09-04). This derivation is vendored from the last commit that
  # still carried nix/package.nix, pinned so nixpkgs/bun2nix updates alone
  # don't drift the msgvault source out from under it.
  src = fetchFromGitHub {
    owner = "kenn-io";
    repo = "msgvault";
    rev = "aaff9f867c148516dc607655d3e014f091cbdb74";
    hash = "sha256-i6Ngbz6au9CbbP+ERy2e6xa12n89jBuoGpFvE5qMJfg=";
  };

  vendorHash = "sha256-mywedDZlx89nFjHuZmSqRxLnPMzVVNR4dqM2RwGWYbI=";
  proxyVendor = true;

  # Bun's copyfile backend can install incomplete packages when fetchBunDeps'
  # cache entries are backed by symlinks. Materialize the cache as regular
  # files before the sandboxed install consumes it.
  bunDeps =
    let
      base = bun2nix.fetchBunDeps { bunNix = ./bun.nix; };
    in
    runCommand "msgvault-bun-deps" { } ''
      mkdir -p "$out/share/bun-cache"
      cp -RL ${base}/share/bun-cache/. "$out/share/bun-cache/"
      chmod -R u+w "$out/share/bun-cache"
    '';
  bunRoot = "web";
  bunInstallFlags = [
    "--linker=hoisted"
    "--backend=copyfile"
  ];
  # The frontend dependencies do not need install scripts. A second Linux Bun
  # install can remove package binaries created by the offline install.
  dontRunLifecycleScripts = true;
  dontUseBunBuild = true;
  dontUseBunCheck = true;
  dontUseBunInstall = true;

  nativeBuildInputs = [
    bun2nix.hook
    nodejs
  ];
  overrideModAttrs = _: previous: {
    nativeBuildInputs = builtins.filter (
      input: (input.name or "") != "bun2nix-hook"
    ) previous.nativeBuildInputs;
    preBuild = "";
  };

  preBuild = ''
    pushd web
    bun node_modules/openapi-typescript/bin/cli.js ../api/openapi.yaml --output src/lib/api/generated/schema.d.ts
    bun node_modules/vite/bin/vite.js build
    popd
    mkdir -p internal/web/dist
    find internal/web/dist -mindepth 1 -maxdepth 1 ! -name stub.html -exec rm -rf {} +
    cp -R web/dist/. internal/web/dist/
    bun scripts/check-web-assets.mjs
  '';

  subPackages = [ "cmd/msgvault" ];

  # mattn/go-sqlite3, marcboeker/go-duckdb, and asg017/sqlite-vec-go-bindings
  # all link C code. buildGoModule defaults CGO_ENABLED to 1, but be explicit.
  env.CGO_ENABLED = 1;

  # sqlite-vec-go-bindings does `#include "sqlite3.h"` but ships no sqlite
  # source — provide the system header via buildInputs.
  buildInputs = [ sqlite ];

  tags = [
    "fts5"
    "sqlite_vec"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X go.kenn.io/msgvault/cmd/msgvault/cmd.Version=${version}"
  ];

  doCheck = false;

  meta = {
    description = "Offline Gmail archive with full-text search";
    homepage = "https://github.com/kenn-io/msgvault";
    license = lib.licenses.asl20;
    mainProgram = "msgvault";
  };
}
