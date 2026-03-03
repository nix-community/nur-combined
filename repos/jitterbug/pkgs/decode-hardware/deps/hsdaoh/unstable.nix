{
  fetchFromGitHub,
  hsdaoh,
  ...
}:
let
  pname = "hsdaoh-unstable";
  version = "0-unstable-2025-09-24";

  rev = "ecd5f835ffad911e7b0b73d905e70cddc898c1ab";
  hash = "sha256-qWVPQQo1RYhMe5UlTKbQllZ5ERxJa3aYToDKK/8GbTA=";
in
(hsdaoh.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo;
    };
  }
))
