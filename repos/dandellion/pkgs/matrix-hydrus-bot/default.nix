{ lib, mkYarnPackage, fetchFromGitHub }:

mkYarnPackage {
  name = "matrix-hydrus-bot";
  src = fetchFromGitHub {
    owner = "dali99";
    repo = "matrix-hydrus-bot";
    rev = "f85919a96cb6b334f1a68e16609d378dece1e604";
    sha256 = "0lliw73446h0mc77n5sbp0vql7as0xvjbmqdgc55ajx76lgasj57";
  };
  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;

  preInstall = ''
    sed -i '1i#!/usr/bin/env node' deps/matrix-hydrus-bot/index.mjs
    chmod +x deps/matrix-hydrus-bot/index.mjs
  '';
}

