{
  fetchFromGitHub,
  hsdaoh,
  ...
}:
let
  pname = "hsdaoh-misrc";
  version = "0-unstable-2025-08-15";

  rev = "02e72ac62262a1144bfe067287e93b9853562c44";
  hash = "sha256-s9U1CGEce3BCREfvDnOTu23tFlT0z6C6sfTAojQptQ4=";
in
(hsdaoh.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit pname version;

    src = fetchFromGitHub {
      inherit hash rev;
      inherit (prevAttrs.src) owner repo;
    };

    meta.homepage = "https://github.com/Stefan-Olt/hsdaoh";
  }
))
