{
  lib,
  fetchFromGitHub,
  haskell,
  haskellPackages,
  makeWrapper,
  nix-update-script,
  openssl,
  xdg-utils,
}:

let
  # Match upstream's Cabal dependency: 0.12.6 re-exports hSetCookie.
  # Override the entire local scope so HTTP libraries share the same types.
  neuHaskellPackages = haskellPackages.override {
    overrides = self: super: {
      http-types = haskell.lib.overrideCabal super.http-types (old: {
        version = "0.12.6";
        sha256 = "sha256-togEKstOU/H17+0mBWzx/cOuXca4XPvjIe3/wwecEGw=";
        libraryHaskellDepends = with self; [
          base
          bytestring
          case-insensitive
          text
        ];
        testHaskellDepends = old.testHaskellDepends ++ [
          self.case-insensitive
          self.filepath
          self.hspec-golden
        ];
        testToolDepends = [ self.hspec-discover ];
      });
    };
  };
in
haskell.lib.justStaticExecutables (
  (neuHaskellPackages.callPackage (
    { mkDerivation }:
    mkDerivation {
      pname = "neu-cli";
      version = "0.1.0.0-unstable-2026-10-12";

      src = fetchFromGitHub {
        owner = "silicalet";
        repo = "neu-cli";
        rev = "031e32abd83bd39cb5721fe90634d61ab4159932";
        hash = "sha256-iUxlcj61BXEDjfsKpR+0wtB6h1O+m7mcDYsNriqhdoQ=";
      };

      isLibrary = true;
      isExecutable = true;

      libraryHaskellDepends = with neuHaskellPackages; [
        aeson
        base
        base64-bytestring
        bytestring
        containers
        crypton
        directory
        filepath
        http-client
        http-client-tls
        http-types
        memory
        network-uri
        optparse-applicative
        process
        scientific
        tagsoup
        text
        time
        unix
      ];
      executableHaskellDepends = [ neuHaskellPackages.base ];
      testHaskellDepends = with neuHaskellPackages; [
        aeson
        base
        base64-bytestring
        bytestring
        containers
        directory
        filepath
        http-types
        network-uri
        process
        scientific
        temporary
        text
        time
        unix
        wai
        warp
      ];
      testToolDepends = [ openssl ];
      doCheck = true;
      # Setup test does not add the package's own build-tool-depends to PATH.
      preCheck = ''
        export PATH="$PWD/dist/build/neu:$PATH"
      '';

      executableToolDepends = [ makeWrapper ];
      postInstall = ''
        wrapProgram "$out/bin/neu" --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };

      description = "Command-line tools for Northeastern University campus services";
      homepage = "https://github.com/silicalet/neu-cli";
      license = lib.licenses.mpl20;
      mainProgram = "neu";
      platforms = lib.platforms.unix;
    }
  ) { })
)
