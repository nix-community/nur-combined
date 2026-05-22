{
  fetchFromGitHub,
  tbc-tools,
  ...
}:
let
  pname = "tbc-tools-unstable";
  version = "3.1.0-unstable-2026-05-20";

  rev = "d92b50ab55731c54e6a92bc0c157e3747273aa80";
  hash = "sha256-hUb/TMOqXS0s8ov4XbJfUnOSdz91sfwbLnl1ljKNE9A=";
in
(tbc-tools.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo sparseCheckout;
    };
  }
))
