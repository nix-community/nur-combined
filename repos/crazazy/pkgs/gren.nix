{ pkgs, compiler ? "default", doBenchmark ? false }:

let
  f = { mkDerivation, ansi-terminal, ansi-wl-pprint, base
      , base64-bytestring, binary, bytestring, containers, directory
      , edit-distance, filelock, filepath, ghc-prim, haskeline, hspec
      , hspec-discover, indexed-traversable, lib, mtl, prettyprint-avh4
      , process, raw-strings-qq, scientific, text, time, utf8-string
      , vector
      }:
      mkDerivation {
        pname = "gren";
        version = "0.3.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          ansi-terminal ansi-wl-pprint base base64-bytestring binary
          bytestring containers directory edit-distance filelock filepath
          ghc-prim haskeline indexed-traversable mtl prettyprint-avh4 process
          raw-strings-qq scientific text time utf8-string vector
        ];
        testHaskellDepends = [
          ansi-terminal ansi-wl-pprint base base64-bytestring binary
          bytestring containers directory edit-distance filelock filepath
          ghc-prim haskeline hspec indexed-traversable mtl prettyprint-avh4
          process raw-strings-qq scientific text time utf8-string vector
        ];
        testToolDepends = [ hspec-discover ];
        homepage = "https://gren-lang.org";
        description = "The `gren` command line interface";
        license = lib.licenses.bsd3;
        mainProgram = "gren";
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
