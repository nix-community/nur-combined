{ lib, stdenv, buildGoModule, callPackage }:

let
  common = callPackage ./common.nix {};
in buildGoModule rec {
  pname = "awl";

  inherit (common) version src;

  preBuild = ''
    cp -r ${common.awl_flutter} static
    rm -r cmd/awl-tray
  '';

  vendorHash = "sha256-2Ryggo61Lb6BUxIR7ilZ+7tT71y0PMZpIUkP6AP9dC0=";

  meta = with lib; {
    description = "Securely connect your devices into a private network";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
