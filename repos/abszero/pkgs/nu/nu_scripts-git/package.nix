{
  lib,
  nu_scripts,
  fetchFromGitHub,
}:

let
  lock = lib.importJSON ./lock.json;
in

nu_scripts.overrideAttrs (prev: {
  version = lock.rev;
  src = fetchFromGitHub lock;
})
