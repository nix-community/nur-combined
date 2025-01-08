{
  lib,
  maa-assistant-arknights,
  fetchFromGitHub,
  fetchpatch,
  stdenv,
}:

let
  sources = lib.importJSON ./pin.json;
in
(maa-assistant-arknights.overrideAttrs (oldAttrs: {
  pname = "maa-assistant-arknights";
  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "MaaAssistantArknights";
    rev = "v${sources.beta.version}";
    sha256 = sources.beta.hash;
  };

  env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";

  passthru.updateScript = ./update.sh;

  meta = oldAttrs.meta // {
    # https://github.com/NixOS/nixpkgs/issues/306042
    broken = stdenv.buildPlatform != stdenv.hostPlatform;
  };
}))
