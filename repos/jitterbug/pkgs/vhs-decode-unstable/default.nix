{
  fetchFromGitHub,
  rustPlatform,
  vhs-decode,
  ...
}:
let
  pname = "vhs-decode-unstable";
  version = "0.3.9-unstable-2026-05-09";

  rev = "9d8af26f1417623345368b3c602829192a862c92";
  hash = "sha256-jgMNKpGSi3RljRB/WbCRHM3XTaSdcXU0z38VoTdwPZ0=";
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
