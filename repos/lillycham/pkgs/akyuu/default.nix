{
  lib,
  haskell,
  haskellPackages,
  fetchFromGitHub,
}:
let
  # The dependencies come from akyuu.nix of the project (cabal2nix output).
  # Update them from that file when the project changes them.
  akyuu = haskellPackages.callPackage (
    {
      mkDerivation,
      aeson,
      base,
      base16-bytestring,
      bytestring,
      containers,
      cryptohash-sha256,
      directory,
      file-embed,
      filelock,
      filepath,
      http-types,
      network,
      optparse-applicative,
      process,
      sqlite-simple,
      streaming-commons,
      tasty,
      tasty-hunit,
      tasty-quickcheck,
      text,
      time,
      transformers,
      unix,
      wai,
      warp,
    }:
    mkDerivation {
      pname = "akyuu";
      version = "0.2.0.0";
      src = fetchFromGitHub {
        owner = "lillycham";
        repo = "akyuu";
        rev = "92ee544334bdde2021b1009a4396db479ac234f8"; # v0.2.0.0
        hash = "sha256-6Xtq+WCBFibdVarhZpnfYelEPx1Zdz6dhN805+X3SDE=";
      };
      isLibrary = true;
      isExecutable = true;
      libraryHaskellDepends = [
        aeson
        base
        base16-bytestring
        bytestring
        containers
        cryptohash-sha256
        directory
        file-embed
        filelock
        filepath
        http-types
        network
        optparse-applicative
        process
        sqlite-simple
        streaming-commons
        text
        time
        transformers
        unix
        wai
        warp
      ];
      executableHaskellDepends = [ base ];
      testHaskellDepends = [
        aeson
        base
        base16-bytestring
        bytestring
        containers
        directory
        filelock
        filepath
        http-types
        optparse-applicative
        sqlite-simple
        tasty
        tasty-hunit
        tasty-quickcheck
        text
        time
        wai
      ];
      description = "A content-addressed memory store for AI agents";
      homepage = "https://github.com/lillycham/akyuu";
      license = lib.licenses.mit;
      mainProgram = "akyuu";
    }
  ) { };
in
# Only the executable: no references to GHC or to the Haskell libraries, so
# the closure is the binary and a few system libraries.
haskell.lib.justStaticExecutables (haskell.lib.dontHaddock akyuu)
