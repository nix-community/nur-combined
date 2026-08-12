{
  fetchFromGitHub,
  decode-orc,
  ...
}:
let
  pname = "decode-orc-unstable";
  version = "1.1.14-unstable-2026-05-30";

  rev = "8f536842422c6b337993c59de62d5afe94a510c5";
  hash = "sha256-m1oF0y6frI7WbRmF+I9fL/3XFx5SQYMu855G5SYiL/4=";
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
