{ pkgs, lib, ... }: {

  emacsParsePackageSet = pkgs.callPackage ({ path, emacs
    , epkgs ? pkgs.emacsPackagesFor emacs
    , parser ? pkgs.callPackage <emacs-overlay/parse.nix> { }, ... }:
    let
      parsedPkgs =
        parser.parsePackagesFromPackageRequires (builtins.readFile path);
      usePkgs = map (name: epkgs.${name}) parsedPkgs;
    in usePkgs);

  emacsMakeSingleFilePackage = { src, pname, version ? "unstable", emacs
    , epkgs ? pkgs.emacsPackagesFor emacs, warnIsError ? true
    , packageRequires ? [ ], }:
    let
      warnEvalStr = lib.optionalString warnIsError
        "--eval '(setq byte-compile-error-on-warn t)'";
    in (epkgs.trivialBuild {
      inherit pname version src packageRequires;
      dontUnpack = true;

      buildPhase = ''
        runHook preBuild
        cp $src .
        emacs -L . --batch ${warnEvalStr} -f batch-byte-compile *.el
        runHook postBuild
      '';
    }).overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.git ];
    });
}
