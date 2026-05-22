{
  fetchFromGitHub,
  nodeeditor,
  ...
}:
let
  pname = "nodeeditor-unstable";
  version = "3.0.16-unstable-2026-03-25";

  rev = "bcb0b35f21a0cbec95dd1e5f7dc6a9a7a7530252";
  hash = "sha256-jBFPyaEwk2SF/YJOslwFtGyfH5Lrc82p9JAYEVMG3fw=";
in
(nodeeditor.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo;
    };
  }
))
