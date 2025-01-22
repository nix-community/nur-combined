{
  pkgs,
  lib ? pkgs.lib,
  ...
}:

rec {
  emacsParsePackageSet =
    {
      src,
      epkgs ? pkgs.emacs.pkgs,
    }:
    lib.pipe src [
      builtins.readFile
      emacsParsePackagesFromPackageRequires
      # This step reduces the closure size of the derivation, because
      # it removes the emacs package itself.
      (x: lib.lists.remove "emacs" x)
      (x: map (name: epkgs.${name}) x)
    ]
  # map (name: epkgs.${name}) (emacsParsePackagesFromPackageRequires (builtins.readFile src))
  ;

  emacsMakeSingleFilePackage =
    {
      src,
      pname ? lib.removeSuffix ".el" (builtins.baseNameOf src),
      version ? "0.0.1",
      epkgs ? pkgs.emacs.pkgs,
      packageRequires ? emacsParsePackageSet { inherit src epkgs; },
    }:
    (epkgs.melpaBuild {
      inherit
        pname
        version
        src
        packageRequires
        ;
      # turnCompilationWarningToError = true;
      # ignoreCompilationError = false;
      preferLocalBuild = true;
      allowSubstitutes = false;
    }).overrideAttrs
      (
        {
          nativeBuildInputs ? [ ],
          ...
        }:
        {
          nativeBuildInputs = nativeBuildInputs ++ [ pkgs.git ];
        }
      );

  # copied from https://github.com/nix-community/emacs-overlay/blob/master/parse.nix
  emacsParsePackagesFromPackageRequires =
    packageElisp:
    let
      isStrEmpty = s: (builtins.replaceStrings [ " " ] [ "" ] s) == "";
      splitString = _sep: _s: builtins.filter (x: builtins.typeOf x == "string") (builtins.split _sep _s);
      lines = splitString "\r?\n" packageElisp;
      requires = lib.concatMapStrings (
        line:
        let
          match = builtins.match ";;;* *[pP]ackage-[rR]equires *: *\\((.*)\\) *" line;
        in
        if match == null then "" else builtins.head match
      ) lines;
      parseReqList =
        s:
        let
          matchAndRest = builtins.match " *\\(? *([^ \"\\)]+)( +\"[^\"]+\" *\\)| *\\))?(.*)" s;
        in
        if isStrEmpty s then
          [ ]
        else if matchAndRest == null then
          throw "Failed to parse package requirements list: ${s}"
        else
          [ (builtins.head matchAndRest) ] ++ (parseReqList (builtins.elemAt matchAndRest 2));
    in
    parseReqList requires;
}
