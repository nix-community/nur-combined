{
  pkgs,
  lib ? pkgs.lib,
}:

rec {
  emacsParsePackageSet =
    {
      src,
      epkgs ? pkgs.emacs.pkgs,
    }:
    lib.pipe src [
      builtins.readFile
      (
        x:
        (emacsParsePackagesFromPackageRequires x)
        ++ [
          "general"
          # "nagy-use-package" # this causes infinite recursion
        ]
        ++ (
          let
            prefix = ";; NIX-EMACS-PACKAGE: ";
            lines = (lib.splitString "\n" x);
            filtered = (lib.filter (y: lib.hasPrefix prefix y)) lines;
            mapped = map (z: lib.removePrefix prefix z) filtered;
          in
          mapped
        )
      )
      # lib.lists.unique
      # This step reduces the closure size of the derivation, because
      # it removes the emacs package itself.
      (x: lib.lists.remove "emacs" x)
      # also remove the "use-package" package because it is built into emacs
      (x: lib.lists.remove "use-package" x)
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
      turnCompilationWarningToError = true;
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

  emacsMakeDirectoryScope =
    {
      path,
      epkgs ? pkgs.emacs.pkgs,
    }:
    let
      elFiles = lib.filter (x: lib.hasSuffix ".el" x) (lib.filesystem.listFilesRecursive path);
      final = lib.listToAttrs (
        map (filepath: {
          name = lib.removeSuffix ".el" (builtins.baseNameOf filepath);
          value = emacsMakeSingleFilePackage {
            src = (path + "/${(builtins.baseNameOf filepath)}");
            epkgs = epkgs.overrideScope (_self: _super: final);
          };
        }) elFiles
      );
    in
    final;

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
