{ pkgs, lib, ... }: rec {

  emacsParsePackageSet = pkgs.callPackage
    ({ src, emacs, epkgs ? pkgs.emacsPackagesFor emacs, ... }:
      let
        parsedPkgs =
          emacsParsePackagesFromPackageRequires (builtins.readFile src);
        usePkgs = map (name: epkgs.${name}) parsedPkgs;
      in usePkgs);

  emacsMakeSingleFilePackage = { src, pname, version ? "unstable"
    , emacs ? pkgs.emacs, epkgs ? pkgs.emacsPackagesFor emacs
    , packageRequires ? emacsParsePackageSet { inherit emacs src epkgs; }, }:
    (epkgs.trivialBuild {
      inherit pname version src packageRequires;
      preferLocalBuild = true;
      allowSubstitutes = false;
    }).overrideAttrs ({ nativeBuildInputs ? [ ], ... }: {
      nativeBuildInputs = nativeBuildInputs ++ [ pkgs.git ];
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
