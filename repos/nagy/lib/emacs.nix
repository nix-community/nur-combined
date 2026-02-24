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
      lib.readFile
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
            lines = lib.splitString "\n" x;
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
  # map (name: epkgs.${name}) (emacsParsePackagesFromPackageRequires (lib.readFile src))
  ;

  emacsMakeSingleFilePackage =
    {
      src,
      pname ? lib.removeSuffix ".el" (baseNameOf src),
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
      paths,
      epkgs ? pkgs.emacs.pkgs,
    }:
    let
      allFiles = lib.flatten (map lib.filesystem.listFilesRecursive paths);
      elFiles = lib.filter (x: lib.hasSuffix ".el" x) allFiles;
      final = lib.listToAttrs (
        map (filepath: {
          name = lib.removeSuffix ".el" (baseNameOf filepath);
          value = emacsMakeSingleFilePackage {
            src = filepath;
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
      isStrEmpty = s: (lib.replaceStrings [ " " ] [ "" ] s) == "";
      splitString = _sep: _s: lib.filter (x: lib.typeOf x == "string") (lib.split _sep _s);
      lines = splitString "\r?\n" packageElisp;
      requires = lib.concatMapStrings (
        line:
        let
          match = lib.match ";;;* *[pP]ackage-[rR]equires *: *\\((.*)\\) *" line;
        in
        if match == null then "" else lib.head match
      ) lines;
      parseReqList =
        s:
        let
          matchAndRest = lib.match " *\\(? *([^ \"\\)]+)( +\"[^\"]+\" *\\)| *\\))?(.*)" s;
        in
        if isStrEmpty s then
          [ ]
        else if matchAndRest == null then
          throw "Failed to parse package requirements list: ${s}"
        else
          [ (lib.head matchAndRest) ] ++ (parseReqList (lib.elemAt matchAndRest 2));
    in
    parseReqList requires;

  convertOrgToJson = pkgs.writeShellApplication {
    name = "convert-org-to-json";
    runtimeInputs = [ pkgs.emacs ];
    runtimeEnv = {
      emacsOrgExportJsonCleanup = pkgs.writeText "emacsOrgExportJsonCleanup.org" ''
        (defun my/org-export-sanitize-value (val)
          (cond
           ((bufferp val) (buffer-name val))
           ((markerp val) (marker-position val))
           ((listp val)
            (if (keywordp (car val))
                (my/org-export-clean-plist val)
              (mapcar #'my/org-export-sanitize-value val)))
           ((or (stringp val) (numberp val) (booleanp val) (symbolp val)) val)
           (t (format "%s" val))))
        (defun my/org-export-clean-plist (plist)
          (let (result)
            (while plist
              (let ((key (pop plist))
                    (val (pop plist)))
                (push key result)
                (push (my/org-export-sanitize-value val) result)))
            (nreverse result)))
      '';

    };
    text = ''
      exec emacs -Q -nw -f package-initialize --batch "$@" \
        --load "$emacsOrgExportJsonCleanup" \
        --eval "(setq json-encoding-pretty-print t)" \
        --eval "(setq json-encoding-object-sort-predicate #'string<)" \
        --eval "(princ (json-encode (my/org-export-clean-plist (org-export-get-environment))))" \
        --eval "(princ \"\\n\")"
    '';
  };

  importOrg = {
    check = lib.hasSuffix ".org";
    __functor =
      _self: filename:
      lib.pipe filename [
        (
          it:
          pkgs.runCommandLocal "output.json" { nativeBuildInputs = [ convertOrgToJson ]; } ''
            convert-org-to-json ${it} > $out
          ''
        )
        lib.importJSON
      ];
  };
}
