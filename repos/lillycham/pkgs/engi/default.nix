{
  lib,
  haskell,
  haskellPackages,
  fetchFromGitHub,
  makeWrapper,
  age,
}:
let
  # The dependencies come from engi.nix of the project (cabal2nix output).
  # Update them from that file when the project changes them.
  engi = haskellPackages.callPackage (
    {
      mkDerivation,
      aeson,
      base,
      base16-bytestring,
      bytestring,
      containers,
      cryptohash-sha256,
      directory,
      filepath,
      optparse-applicative,
      process,
      QuickCheck,
      tasty,
      tasty-hunit,
      tasty-quickcheck,
      temporary,
      text,
      time,
      zstd,
    }:
    mkDerivation {
      pname = "engi";
      version = "0.1.0.0-unstable-2026-11-07";
      src = fetchFromGitHub {
        owner = "lillycham";
        repo = "engi";
        rev = "e7a657d03b5aa2d329134cfd2d6bc942c470330d";
        hash = "sha256-tNKk86km9Zej1LT24z416O/0RIThlpgWl0EKgUXclgg=";
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
        filepath
        process
        text
        time
        zstd
      ];
      executableHaskellDepends = [
        base
        bytestring
        optparse-applicative
        text
        time
      ];
      testHaskellDepends = [
        base
        base16-bytestring
        bytestring
        cryptohash-sha256
        directory
        filepath
        process
        QuickCheck
        tasty
        tasty-hunit
        tasty-quickcheck
        temporary
        text
        time
        zstd
      ];
      description = "Archive closed agent sessions: strip, compress, verify, export with age";
      homepage = "https://github.com/lillycham/engi";
      license = lib.licenses.mit;
      mainProgram = "engi";
    }
  ) { };
in
# Only the executable: no references to GHC or to the Haskell libraries.
# `engi export` runs age, so the program has age on its PATH (a scheduled job
# does not have the PATH of a shell). The tests include a round trip with the
# real age, so age is a tool of the test run.
haskell.lib.overrideCabal (haskell.lib.justStaticExecutables (haskell.lib.dontHaddock engi)) (drv: {
  buildTools = (drv.buildTools or [ ]) ++ [ makeWrapper ];
  testToolDepends = (drv.testToolDepends or [ ]) ++ [ age ];
  postInstall = (drv.postInstall or "") + ''
    wrapProgram $out/bin/engi --prefix PATH : ${lib.makeBinPath [ age ]}
  '';
})
