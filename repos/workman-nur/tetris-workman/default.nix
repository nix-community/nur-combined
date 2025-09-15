{
  haskellPackages,
  haskell,
}:

haskell.lib.compose.justStaticExecutables (
  haskellPackages.callPackage (
    {
      mkDerivation,
      fetchFromGitHub,
      lib,

      base,
      vty,
      lens,
      brick,
      linear,
      containers,
      random,
      transformers,
      directory,
      filepath,
      optparse-applicative,
      vty-crossplatform,
      mtl,
      extra,
    }:
    mkDerivation rec {
      pname = "tetris-workman";
      version = "0.1.6";
      src = fetchFromGitHub {
        repo = "tetris-workman";
        owner = "Oliper202020";
        tag = "v${version}";
        hash = "sha256-b8sqIab9+2WHjyJJxJsDKWpdrpG8witl4QkTdEHwkaU=";
      };
      libraryHaskellDepends = [
        base
        brick
        containers
        extra
        lens
        linear
        mtl
        random
        transformers
        vty
        vty-crossplatform
      ];
      executableHaskellDepends = [
        base
        directory
        filepath
        optparse-applicative
      ];
      homepage = "https://github.com/Oliper202020/tetris";
      changelog = "https://github.com/samtay/tetris/releases/tag/v${version}";
      license = lib.licenses.bsd3;
      mainProgram = "tetris";
      maintainers = [ lib.maintainers.Svenum ];
    }
  ) { }
)
