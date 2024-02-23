{ lib, sane-lib, ... }:

let
  sane-path = sane-lib.path;
in rec {
  wanted = lib.attrsets.unionOfDisjoint { wantedBeforeBy = [ "multi-user.target" ]; };
  wantedDir = wanted { dir = {}; };
  wantedSymlink = symlink: wanted { inherit symlink; };
  wantedSymlinkTo = target: wantedSymlink { inherit target; };
  wantedText = text: wantedSymlink { inherit text; };

  # Type: derefSymlinkOrNul :: config.sane.fs.type -> str -> (str|null)
  derefSymlinkOrNull = fs: logical: let
    symlinkedPrefixes = lib.filter
      (p: ((fs."${p}" or {}).symlink or null) != null)
      (sane-path.walk "/" logical);
    firstSymlink = builtins.head symlinkedPrefixes;
    firstSymlinkDest = "${firstSymlink}".symlink.target;
    firstSymlinkParent = sane-path.parent firstSymlink;
    firstSymlinkDestAbs = if lib.hasPrefix "/" firstSymlinkDest then
      firstSymlinkDest
    else
      sane-path.join [ firstSymlinkParent firstSymlinkDest ];
  in
    if symlinkedPrefixes != [] then
      firstSymlinkDestAbs
    else
      null
  ;
  derefSymlink = fs: logical:
    if derefSymlinkOrNull fs logical != null then
      derefSymlinkOrNull fs logical
    else
      logical
  ;
}

