{
  lib,
  pandoc,
  stdenv,
  swift,
  swiftpm,
  swiftpm2nix,
  swiftPackages,
  fetchFromGitHub,
  nix-update-script,
}: let
  generated = swiftpm2nix.helpers ./nix;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "mklaunchd";
    version = "2026-05-07";

    __structuredAttrs = true;
    strictDeps = true;

    src = fetchFromGitHub {
      owner = "uRadical";
      repo = "mklaunchd";
      rev = "8c67889fe85d297a915f11e48c13fc732faa179c";
      hash = "sha256-e2OdEhAW77bNKTak4/Admcq+y+uYsuJEzmzTX6zIZRc=";
    };

    nativeBuildInputs = [pandoc swift swiftpm];

    buildInputs = [
      swiftPackages.Dispatch
      swiftPackages.Foundation
    ];

    configurePhase = ''
      runHook preConfigure

      ${generated.configure}

      runHook postConfigure
    '';

    installFlags = ["INSTALL_BIN:=$(out)/bin" "INSTALL_MAN:=$(out)/share/man/man1"];

    preInstall = ''
      mkdir -p $out/{bin,share/man/man1}
    '';

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "Utility to create launchd services on MacOS";
      homepage = "https://github.com/uRadical/mklaunchd";
      license = lib.licenses.mit;
      mainProgram = "mklaunchd";
      platforms = lib.platforms.darwin;
    };
  })
