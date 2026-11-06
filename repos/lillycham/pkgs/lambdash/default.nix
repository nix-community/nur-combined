{
  lib,
  haskell,
  haskellPackages,
  fetchFromGitHub,
}:
let
  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "lambdash";
    rev = "16f3cca4296c714aa0e6f732fd8468cace0a7648";
    hash = "sha256-rzjRcvP3dh5eKl3xwD6EGnpMQUnHRbgNLz88TTD0gyE=";
  };
  # Keep the shell's Ctrl-C, type-ahead and non-terminal input fixes.
  shellPackages = haskellPackages.override {
    overrides = _: super: {
      isocline = haskell.lib.appendPatch super.isocline (src + "/nix/isocline.patch");
    };
  };
  lambdash = shellPackages.callPackage (
    {
      mkDerivation,
      aeson,
      async,
      base,
      bytestring,
      containers,
      directory,
      filepath,
      isocline,
      lsp,
      lsp-types,
      megaparsec,
      mtl,
      optparse-applicative,
      process,
      stm,
      text,
      transformers,
      unix,
    }:
    mkDerivation {
      pname = "lambdash";
      version = "0.1.0.0-unstable-2026-11-06";
      inherit src;
      isLibrary = true;
      isExecutable = true;
      libraryHaskellDepends = [
        aeson
        async
        base
        bytestring
        containers
        directory
        filepath
        megaparsec
        mtl
        process
        stm
        text
        transformers
        unix
      ];
      executableHaskellDepends = [
        aeson
        base
        directory
        filepath
        isocline
        lsp
        lsp-types
        optparse-applicative
        text
        unix
      ];
      # Upstream runs the terminal and real-program suites in its dev shell.
      doCheck = false;
      postInstall = ''
        rm "$out/bin/spike-jobs"
      '';
      description = "A functional shell with composable environments";
      homepage = "https://github.com/lillycham/lambdash";
      license = lib.licenses.mit;
      mainProgram = "lambdash";
      platforms = lib.platforms.unix;
    }
  ) { };
in
haskell.lib.justStaticExecutables (haskell.lib.dontHaddock lambdash)
