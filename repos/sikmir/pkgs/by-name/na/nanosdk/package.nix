{ fetchFromGitHub, nng }:

nng.overrideAttrs (super: rec {
  version = "0.10.5";

  src = fetchFromGitHub {
    owner = "emqx";
    repo = "NanoSDK";
    tag = version;
    hash = "sha256-LSXYK8O2Y/PoaqzanIpM1DKTHvgL0kkULY48/SkW4ZY=";
    fetchSubmodules = true;
  };

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
})
