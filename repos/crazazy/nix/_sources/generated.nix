# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchzip, fetchFromGitHub, dockerTools }:
{
  cakeml = {
    pname = "cakeml";
    version = "v2702";
    src = fetchzip {
      url = "https://github.com/CakeML/cakeml/releases/download/v2702/cake-x64-64.tar.gz";
      sha256 = "sha256-twuTR2dpH11txd5IUQK9ilkSkqNJhBihvSbWxWOkVHU=";
    };
  };
  enso = {
    pname = "enso";
    version = "2024.4.2";
    src = fetchurl {
      url = "https://github.com/enso-org/enso/releases/download/2024.4.2/enso-linux-x86_64-2024.4.2.AppImage";
      sha256 = "sha256-pv74L5CYRF8KRYrggAbi0uzBiMAYkDl+10FTar229n4=";
    };
  };
  guile-config = {
    pname = "guile-config";
    version = "0.5.0";
    src = fetchzip {
      url = "https://gitlab.com/a-sassmannshausen/guile-config/-/archive/0.5.0/guile-config-0.5.0.tar.gz";
      sha256 = "sha256-8Ma2pzqR8il+8H6WVbYLpKBk2rh3aKBr1mvvzdpCNPc=";
    };
  };
  guile-hall = {
    pname = "guile-hall";
    version = "0.4.1";
    src = fetchzip {
      url = "https://gitlab.com/a-sassmannshausen/guile-hall/-/archive/0.4.1/guile-hall-0.4.1.tar.gz";
      sha256 = "sha256-TUCN8kW44X6iGbSJURurcz/Tc2eCH1xgmXH1sMOMOXs=";
    };
  };
  seamonkey = {
    pname = "seamonkey";
    version = "2.53.19";
    src = fetchzip {
      url = "https://archive.seamonkey-project.org/releases/2.53.19/linux-x86_64/en-US/seamonkey-2.53.19.en-US.linux-x86_64.tar.bz2";
      sha256 = "sha256-MFykDCX/XirWfMGtbP84mJM9/W01ZwueMrdHJcvSAkc=";
    };
  };
  trufflesqueak = {
    pname = "trufflesqueak";
    version = "24.0.2";
    src = fetchurl {
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/24.0.2/trufflesqueak-24.0.2-linux-amd64.tar.gz";
      sha256 = "sha256-J7kKnf8+3q9xrWaTEYVfRExLL0RmCKylzzDum24R2lg=";
    };
  };
  trufflesqueak-image = {
    pname = "trufflesqueak-image";
    version = "24.0.2";
    src = fetchurl {
      url = "https://github.com/hpi-swa/trufflesqueak/releases/download/24.0.2/TruffleSqueakImage-24.0.0.zip";
      sha256 = "sha256-K2uomtQY5TfUPq/7r7ax4Srs0Q6hYVdy0U68no7O1qs=";
    };
  };
  wasmfxtime = {
    pname = "wasmfxtime";
    version = "3f79f4725e460b33986e2729e04319b991c56b5f";
    src = fetchFromGitHub {
      owner = "wasmfx";
      repo = "wasmfxtime";
      rev = "3f79f4725e460b33986e2729e04319b991c56b5f";
      fetchSubmodules = true;
      sha256 = "sha256-1iOgiaHTePI3g2pSJQtk+NOksf8c+/+1es1Wyq8HyNg=";
    };
    cargoLock."./Cargo.lock" = {
      lockFile = ./wasmfxtime-3f79f4725e460b33986e2729e04319b991c56b5f/./Cargo.lock;
      outputHashes = {
        "wit-bindgen-0.35.0" = "sha256-7KwiI04ijpfeLFnOMUvCF9ZAY3ZbvlWSuFV0P1lBwLQ=";
        "wasm-encoder-0.220.0" = "sha256-gXwdY75tTx57khF52LfNTIbacP53uxr/+YSc2zFiGSk=";
      };
    };
    date = "2024-11-29";
  };
}
