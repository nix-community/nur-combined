{
  fetchFromGitHub,
  tbc-tools,
  ...
}:
let
  pname = "tbc-tools-unstable";
  version = "3.2.0-unstable-2026-06-06";

  rev = "04c48de75b4f84b0d528186cd57e02a1fb100c1b";
  hash = "sha256-dxAv05TdwnJY52FVq/o+yl+I+QPHrn2bI6Yn+4sQs2o=";
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
