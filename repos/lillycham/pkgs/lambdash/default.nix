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
    rev = "77e5a0f9f3afe5001b4781421c090b018bd1bb8a";
    hash = "sha256-1npVgqVGEmXmi84orjnOZlN2ybzLHySIabQCw4K9GN4=";
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
      process,
      stm,
      text,
      transformers,
      unix,
    }:
    mkDerivation {
      pname = "lambdash";
      version = "0.1.0.0-unstable-2026-11-05";
      inherit src;
      isLibrary = true;
      isExecutable = true;
      libraryHaskellDepends = [
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
      executableHaskellDepends = [ base directory filepath isocline lsp lsp-types text unix ];
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
