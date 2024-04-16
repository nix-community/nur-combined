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

  ldflags = [
    "-X github.com/anywherelan/awl/config.Version=v${version}"
  ];

  vendorHash = "sha256-3UY92eLHC9xG93JVT/Zv0Vd58z4jf2Njz5ktPPPgZww=";

  meta = with lib; {
    description = "Securely connect your devices into a private network";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
