{
  fetchFromGitHub,
  rustPlatform,
  vhs-decode,
  ...
}:
let
  pname = "vhs-decode-unstable";
  version = "0.3.9-unstable-2026-06-04";

  rev = "86c1fc3d85ce827aa7ac16413f25d1b422def87b";
  hash = "sha256-cDWccKaO28X6spUe9z5MYP5iviRJjacBr86ZfLESHGk=";
  cargoHash = "sha256-yryE7R0A95Uok6Pv6/UBsIG8p9pvaP3Nv8AGQugrEOc=";

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "oyvindln";
    repo = "vhs-decode";
  };
in
(vhs-decode.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo;
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit pname version src;
      hash = cargoHash;
    };
  }
))
