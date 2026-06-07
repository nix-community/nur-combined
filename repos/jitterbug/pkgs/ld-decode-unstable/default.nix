{
  fetchFromGitHub,
  ld-decode,
  ...
}:
let
  pname = "ld-decode-unstable";
  version = "7.2.1-unstable-2026-05-31";

  rev = "1bfe5230df110510c7fbc4334a6c3a969b296e46";
  hash = "sha256-kYqHNRJcxphDdW7yQ0K6CAVaZ2r3D00kEImjwB+d8a8=";
in
(ld-decode.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo;
    };
  }
))
