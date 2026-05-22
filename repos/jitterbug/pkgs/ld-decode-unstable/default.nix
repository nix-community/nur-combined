{
  fetchFromGitHub,
  ld-decode,
  ...
}:
let
  pname = "ld-decode-unstable";
  version = "7.2.1-unstable-2025-05-03";

  rev = "44f2528dda10bacc292ab0c7386a3203e3071a07";
  hash = "sha256-4J+fv0OSHWS/sLpwUXTSkLss4GdLXF0XKDoEIjOoLf4=";
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
