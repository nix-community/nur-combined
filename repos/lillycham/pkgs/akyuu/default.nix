{
  lib,
  haskell,
  haskellPackages,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  scdoc,
  bash,
  coreutils,
  git,
  openssh,
  zstd,
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
      temporary,
      text,
      time,
      toml-parser,
      transformers,
      unix,
      wai,
      warp,
    }:
    mkDerivation {
      pname = "akyuu";
      version = "0.5.0.0";
      src = fetchFromGitHub {
        owner = "lillycham";
        repo = "akyuu";
        rev = "8238d49ef94dfc48261a6b09613942e9b7545682"; # v0.5.0.0
        hash = "sha256-EziLoncLOOoWFMsuRD/J8yDdI72XqAT94mElF46ieGQ=";
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
        toml-parser
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
        process
        sqlite-simple
        tasty
        tasty-hunit
        tasty-quickcheck
        temporary
        text
        time
        unix
        wai
      ];
      testToolDepends = [
        bash
        coreutils
        git
        zstd
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
haskell.lib.overrideCabal (haskell.lib.justStaticExecutables (haskell.lib.dontHaddock akyuu))
  (drv: {
    buildTools = (drv.buildTools or [ ]) ++ [
      scdoc
      installShellFiles
      makeWrapper
    ];
    postInstall = (drv.postInstall or "") + ''
      for p in man/*.scd; do scdoc < "$p" > "''${p%.scd}"; done
      installManPage man/akyuu.1 man/akyuu.5
      installShellCompletion --cmd akyuu \
        --bash <($out/bin/akyuu --bash-completion-script $out/bin/akyuu) \
        --zsh <($out/bin/akyuu --zsh-completion-script $out/bin/akyuu) \
        --fish <($out/bin/akyuu --fish-completion-script $out/bin/akyuu)
      wrapProgram $out/bin/akyuu --prefix PATH : ${
        lib.makeBinPath [
          zstd
          git
          bash
          coreutils
          openssh
        ]
      }
    '';
  })
