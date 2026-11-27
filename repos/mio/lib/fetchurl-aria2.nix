# `fetchurlAria2` keeps Nixpkgs' fetchurl parsing and fixed-output derivation
# setup, but replaces its curl transfer builder with the repository's aria2
# wrapper. This has to be a separate fetcher because aria2 is not a drop-in
# replacement for the curl command line used by Nixpkgs' fetchurl builder.
{
  fetchurl,
  aria2,
  ...
}:

args:
let
  aria2Opts = args.aria2Opts or [ ];
  checkedAria2Opts =
    if builtins.isList aria2Opts && builtins.all builtins.isString aria2Opts then
      aria2Opts
    else
      throw "fetchurlAria2: aria2Opts must be a list of strings";
  fetchArgs = builtins.removeAttrs args [ "aria2Opts" ];
  derivationArgs = (fetchArgs.derivationArgs or { }) // {
    aria2Opts = checkedAria2Opts;
  };
  fetched = fetchurl (fetchArgs // { inherit derivationArgs; });
in
fetched.overrideAttrs (old: {
  builder = ./fetchurl-aria2-builder.sh;
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ aria2 ];
  impureEnvVars = (old.impureEnvVars or [ ]) ++ [ "NIX_ARIA2_FLAGS" ];
})
