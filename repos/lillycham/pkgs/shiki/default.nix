{
  lib,
  haskell,
  haskellPackages,
  fetchFromGitHub,
  makeWrapper,
  gitMinimal,
  runtimeShell,
  coreutils,
}:
let
  # Keep these dependencies in sync with the upstream shiki.nix (cabal2nix output).
  shiki = haskellPackages.callPackage (
    {
      mkDerivation,
      aeson,
      async,
      base,
      bytestring,
      containers,
      directory,
      filepath,
      http-client,
      http-client-tls,
      http-types,
      optparse-applicative,
      process,
      stm,
      tasty,
      tasty-hunit,
      text,
      time,
      unix,
      vector,
      wai,
      warp,
    }:
    mkDerivation {
      pname = "shiki";
      version = "0.1.0.0";
      src = fetchFromGitHub (import ./source.nix);
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
        http-client
        http-client-tls
        http-types
        process
        stm
        text
        time
        unix
        vector
        wai
        warp
      ];
      executableHaskellDepends = [
        base
        optparse-applicative
        text
      ];
      testHaskellDepends = [
        aeson
        base
        containers
        directory
        filepath
        http-client
        tasty
        tasty-hunit
        text
        time
      ];
      # The launchd tests parse fixtures; they do not need a running launchd.
      doCheck = true;
      # The command tests must use sandbox tools, not host /bin executables.
      postPatch = ''
        substituteInPlace test/Main.hs \
          --replace-fail '"/bin/sh"' '"${runtimeShell}"' \
          --replace-fail '"/bin/sleep"' '"${lib.getExe' coreutils "sleep"}"'
      '';
      description = "Small probes that report back, as JSON for a dashboard";
      homepage = "https://github.com/lillycham/shiki";
      license = lib.licenses.mit;
      mainProgram = "shiki";
    }
  ) { };
in
# Keep GHC and the Haskell libraries out of the executable closure.
haskell.lib.overrideCabal (haskell.lib.justStaticExecutables (haskell.lib.dontHaddock shiki))
  (drv: {
    buildTools = (drv.buildTools or [ ]) ++ [ makeWrapper ];
    postInstall = (drv.postInstall or "") + ''
      wrapProgram $out/bin/shiki --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
    '';
  })
