{
  fetchFromGitHub,
  nodeeditor,
  ...
}:
let
  pname = "nodeeditor-unstable";
  version = "3.0.16-unstable-2026-05-29";

  rev = "49c2f0ca8c76b4c3b8638acd1e2946b44098ac5e";
  hash = "sha256-90rIOeh7+rGkqvlKK1gVtgXZtAS/Mu5gbnJMy6+Lg8I=";
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
