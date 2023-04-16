{ pkgs, lib, ... }: {

  emacsParsePackageSet = pkgs.callPackage ({ path, emacs
    , epkgs ? pkgs.emacsPackagesFor emacs, emacs-overlay ? <emacs-overlay>, ...
    }:
    let
      parser = pkgs.callPackage (/. + emacs-overlay + /parse.nix) { };
      parsedPkgs =
        parser.parsePackagesFromPackageRequires (builtins.readFile path);
      usePkgs = map (name: epkgs.${name}) parsedPkgs;
    in usePkgs);

  emacsMakeSingleFilePackage = { pname, src ? ./., emacs
    , epkgs ? pkgs.emacsPackagesFor emacs, warnIsError ? true
    , packageRequires ? [ ] }:
    let
      warnEvalStr = lib.optionalString warnIsError
        "--eval '(setq byte-compile-error-on-warn t)'";
    in epkgs.trivialBuild {
      inherit pname src packageRequires;
      version = "unstable";
      dontUnpack = true;

      buildPhase = ''
        runHook preBuild
        cp $src .
        emacs -L . --batch ${warnEvalStr} -f batch-byte-compile *.el
        runHook postBuild
      '';
    };
}
