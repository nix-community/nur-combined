{
  source,
  lib,
  buildGoModule,
  callPackage,
}:

let
  common = callPackage ./common.nix { inherit source; };
in
buildGoModule rec {
  inherit (source.awl) pname version src;

  inherit (common) patches;

  preBuild = ''
    cp -r ${common.awl_flutter} static
    rm -r cmd/awl-tray
  '';

  ldflags = [
    "-X github.com/anywherelan/awl/config.Version=v${version}"
  ];

  doCheck = false;

  vendorHash = "sha256-/H4SNI8ogrvlc1MDJEGkDpV1mUOSqeWvymTqzZuF4nk=";

  meta = with lib; {
    description = "Securely connect your devices into a private network. Mesh VPN, socks5 proxy server/client";
    homepage = src.meta.homepage;
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
  };
}
