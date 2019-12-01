{
  stdenv,
  ammonite,
  dash,
  makeWrapper,
}:

# Stop-gap wrapper for ammonite while
# https://github.com/NixOS/nixpkgs/issues/68151 is being resolved.

stdenv.mkDerivation {
  inherit (ammonite) pname version meta;

  buildInputs = [
    ammonite
    makeWrapper
  ];

  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${dash}/bin/dash $out/bin/amm --add-flags ${ammonite}/bin/amm
  '';
}
