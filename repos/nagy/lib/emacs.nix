{ pkgs, lib, ... }: rec {

  emacsParsePackageSet = pkgs.callPackage ({ src, emacs
    , epkgs ? pkgs.emacsPackagesFor emacs
    , parser ? pkgs.callPackage <emacs-overlay/parse.nix> { }, ... }:
    let
      parsedPkgs =
        parser.parsePackagesFromPackageRequires (builtins.readFile src);
      usePkgs = map (name: epkgs.${name}) parsedPkgs;
    in usePkgs);

  emacsShouldIgnoreWarnings = { src }:
    (builtins.match ".*NIX-IGNORE-WARNINGS.*" (builtins.readFile src)) != null;

  emacsMakeSingleFilePackage = { src, pname, version ? "unstable", emacs
    , epkgs ? pkgs.emacsPackagesFor emacs
    , warnIsError ? !(emacsShouldIgnoreWarnings { inherit src; })
    , packageRequires ? [ ], }:
    let
      warnEvalStr = lib.optionalString warnIsError
        "--eval '(setq byte-compile-error-on-warn t)'";
    in (epkgs.trivialBuild {
      inherit pname version src packageRequires;

      buildPhase = ''
        runHook preBuild
        emacs -L . --batch ${warnEvalStr} -f batch-byte-compile *.el
        runHook postBuild
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    }).overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.git ];
    });
}
