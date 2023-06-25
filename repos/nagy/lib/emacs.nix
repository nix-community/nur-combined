{ pkgs, lib, ... }: rec {

  emacsParsePackageSet = pkgs.callPackage
    ({ src, emacs, epkgs ? pkgs.emacsPackagesFor emacs, ... }:
      let
        parsedPkgs =
          emacsParsePackagesFromPackageRequires (builtins.readFile src);
        usePkgs = map (name: epkgs.${name}) parsedPkgs;
      in usePkgs);

  emacsShouldIgnoreWarnings = { src }:
    (builtins.match ".*NIX-IGNORE-WARNINGS.*" (builtins.readFile src)) != null;

  emacsMakeSingleFilePackage = { src, pname, version ? "unstable"
    , emacs ? pkgs.emacs, epkgs ? pkgs.emacsPackagesFor emacs
    , warnIsError ? !(emacsShouldIgnoreWarnings { inherit src; })
    , packageRequires ? emacsParsePackageSet { inherit emacs src; }, }:
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

  # copied from https://github.com/nix-community/emacs-overlay/blob/master/parse.nix
  emacsParsePackagesFromPackageRequires = packageElisp:
    let
      isStrEmpty = s: (builtins.replaceStrings [ " " ] [ "" ] s) == "";
      splitString = _sep: _s:
        builtins.filter (x: builtins.typeOf x == "string")
        (builtins.split _sep _s);
      lines = splitString "\r?\n" packageElisp;
      requires = lib.concatMapStrings (line:
        let
          match =
            builtins.match ";;;* *[pP]ackage-[rR]equires *: *\\((.*)\\) *" line;
        in if match == null then "" else builtins.head match) lines;
      parseReqList = s:
        let
          matchAndRest =
            builtins.match " *\\(? *([^ \"\\)]+)( +\"[^\"]+\" *\\)| *\\))?(.*)"
            s;
        in if isStrEmpty s then
          [ ]
        else if matchAndRest == null then
          throw "Failed to parse package requirements list: ${s}"
        else
          [ (builtins.head matchAndRest) ]
          ++ (parseReqList (builtins.elemAt matchAndRest 2));
    in parseReqList requires;

}
