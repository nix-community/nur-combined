# "baseRom" (previously) / "sm64baserom" (in the future) is used by `sm64coopdx`, `sm64ex-coop`: braindead packages which use `requireFile` instead of fetching their sources.
{ fetchurl, ... }:
let
  baserom = fetchurl {
    url = "https://github.com/jb1361/Super-Mario-64-AI/raw/development/Super%20Mario%2064%20(USA).z64";
    hash = "sha256-F84Hc0PGEz+Mny1tbZpKtiyM0qpXxArqH0kLTIuyHZE=";
  };
in {
  romPath = "${baserom}";
}
