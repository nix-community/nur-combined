{
  fetchFromGitHub,
  decode-orc,
  ...
}:
let
  pname = "decode-orc-unstable";
  version = "1.1.13-unstable-2026-05-16";

  rev = "3f1293fc6d78028f577921d5831d153a3f457723";
  hash = "sha256-7bqi7Cdc3KkgHrmsIefFEY5AeOiEHG6MEEYGHqxBQXE=";
in
(decode-orc.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo;
    };
  }
))
