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
  inherit (sources.beta) version;
  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "MaaAssistantArknights";
    rev = "v${sources.beta.version}";
    hash = sources.beta.hash;
  };

  passthru.updateScript = ./update.sh;

  meta = oldAttrs.meta // {
    # https://github.com/NixOS/nixpkgs/issues/306042
    broken = true;
  };
}))
